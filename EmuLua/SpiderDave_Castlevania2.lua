-- Castlevania 2 Lua script by SpiderDave
--
-- 2018.10.20
--
-- Changes:
--  * Message speed increased
--  * New patterns for Dracula (needs work and balancing)
--  * Improved Death boss
--  * Improved Carmilla boss
--  * Skeletons can turn around
--  * Improved skulls, ghosts, medusa heads
--  * Improved floating eyes
--  * All fireballs should now face proper direction
--  * Don't re-fight Bosses
--  * Locked boss rooms
--  * Fireballs (except those created by script) are destructable
--  * Equip Dracula's ring and dagger to use Banshee Boomerang
--  * Equip Dracula's ring and white dagger to use axes
--  * Fixed spelling "Prossess" -> "Possess"
--  * New GUI
--  * Holy water burn effect. The sprite for the bottle is now blue.
--  * Diamond sprite graphics are changed, and trail added.
--  * Changed lives display to mean "extra" lives (you can go down to 0)
--  * The period of invincibility when you get hit now starts when you land.
--    The player also flashes.
-- Debug and experimental stuff (may not be in the final version):
--  * Cheats
--  * Frame tester
--  * Bat mode
--  * Banshee boomerang instead of dagger
-- ToDo/Issues/Bugs:
--  * Snakes should turn before jumping
--  * Ferryman shouldn't bounce off the dock and leave
--  * Custom projectiles need a better hit method.  Currently
--    It simply creates holy fire where the projectile was.
--  * Custom projectiles may disappear on non-enemy objects
--    such as moving platforms.
--  * Blood Skeletons
--  * Don't get items you already have (Dracula's parts, etc)
--  * Improve sub screen cursor management
--  * Messages to fix: 0d 1e
--  * replace hp graphics when unloading script
--  * add mummy bandages
--  * overhaul menu system, make new sub screen
--    + select weapons, relics, equipment
--    + bestiary
--    + map
--  * change maximum hearts
--  * add gold system
--  * crystals all show as red crystal
--  * change color of new sub menu at night
--  * add slash character to font
--  * change exp display to show all exp from all levels
--  * add save system, remove lives?
--  * add production flag to remove all cheats/debug stuff
--  * add cross and bag to sub screen
--  * test for rom.writebyte and show message to upgrade fceux if not there
--  * make garlic throw a bunch of garlic
-- 3c6 00=render player 04=don't


require ".Spidey.TSerial"

spidey=require "Spidey.SpideyStuff"
local font=require "Spidey.default_font"
local messages = require "cv2.messages"
local cv2data=require("cv2.cv2data")


--local textMap = " ABCDEFGHIJKLMNOPQRSTUVWXYZ.'v,                       0123456789!     -         !            ?    ETL            :"
local textMap = " ABCDEFGHIJKLMNOPQRSTUVWXYZ.'v,                       0123456789!     -         !            ?    ETL            :"
local textMap2 = {}
for i=0,#textMap-1 do
    local c = textMap:sub(i+1,i+1)
    textMap2[c]=textMap2[c] or i
end



game = {}
game.paused = false

enableddisabled={[true]="enabled",[false]="disabled"}

if not messages then messages={} end


spidey.imgEdit.transparent = true
--spidey.imgEdit.transparentColor="#000000"
spidey.imgEdit.nobk=true


--current_font=2
current_font=1

font_selector=false
show_cursor = true
--quickmessages= true -- Displays idle messages; work in progress
game.paused = false
cheats={enabled=true,active=false,invincible=true,allitems=true,flamewhip=true,refightbosses=true,battest=false,bonetest=true,leftClick=""}
skeleton=false
bat=false
frame=0
frame_tester=false
simon_frame=0
spidey.debug.enabled=false

classMenu=spidey.classes.Menu
mnu=classMenu:new()
mnu.font=font[current_font]
mnu.background="small"
mnu.background_color="black"
mnu.items={}
mnu.items={
    {text=function() return string.format("Bat %s",spidey.prettyValue(bat)) end,
        action=function()
            bat=not bat;
            if bat then
                memory.writebyte(0x03b5,0xff) --help disable whip
            end
        end
    },
    {text=function() return string.format('Frame Test: %s',spidey.prettyValue(frame_tester)) end,
        action=function()
            frame_tester=not frame_tester
            emu.setrenderplanes(true, not frame_tester)
        end
    },
    {text='Save Messages',
        action=function()
            out='local messages={}\n'
            for k,v in pairs(messages) do
                out=out..string.format('messages[%s]=[[%s]]',k,v).."\n"
            end
            out=out.."return messages\n"
            writetofile('cv2/messages.lua', out)
            emu.message("saved.")
        end
    },
    {text="Save gfx",
    action=function()
        local t= TSerial.pack(gfx)
        writetofile('cv2/cv2.gfx', t)
        emu.message("saved.")
    end},
    {text="Save game data",
    action=function()
        local t= TSerial.pack(game.data)
        writetofile('cv2/cv2.dat', t)
        emu.message("saved.")
    end},
    {text=function() return string.format('Bat test: %s',spidey.prettyValue(cheats.battest)) end,
        action=function()
            cheats.battest=not cheats.battest
            if cheats.active and cheats.battest==true then
                emu.message("Click the screen to create a test bat boss.")
            end
        end
    }
}

mnu:addStandard()

cheatMenu=classMenu:new()
cheatMenu.background="small"
cheatMenu.background_color="black"
cheatMenu.font=font[current_font]

mnu.items[#mnu.items+1]=
    {text="Cheat Engine",
    action=function()
        spidey.cheatEngine.menuOpen=not spidey.cheatEngine.menuOpen
    end}
cheatMenu.items=spidey.cheatEngine.menu.main

local candles={}
--candles[1]={}
--candles[1].xo = 0

gfx={}
gfx.cv2heart=getfilecontents("cv2/images/cv2heart.gd")
gfx.arrowcursor=getfilecontents("cv2/images/arrowcursor.gd")
gfx.relics={}
gfx.relics[1]=getfilecontents("cv2/images/cv2_relic_rib.gd")
gfx.relics[2]=getfilecontents("cv2/images/cv2_relic_heart.gd")
gfx.relics[3]=getfilecontents("cv2/images/cv2_relic_eye.gd")
gfx.relics[4]=getfilecontents("cv2/images/cv2_relic_nail.gd")
gfx.relics[5]=getfilecontents("cv2/images/cv2_relic_ring.gd")
gfx.relics[6]=getfilecontents("cv2/images/cv2_relic_redcrystal.gd")
gfx.items = {}
gfx.items.bag = getfilecontents("cv2/images/bag.gd")
gfx.items.cross = getfilecontents("cv2/images/cross.gd")
gfx.weapons={}
gfx.weapons[1]=getfilecontents("cv2/images/cv2_dagger.gd")
gfx.weapons[2]=getfilecontents("cv2/images/cv2_dagger2.gd")
gfx.weapons[3]=getfilecontents("cv2/images/cv2_dagger3.gd")
gfx.weapons[4]=getfilecontents("cv2/images/cv2_holywater.gd")
--gfx.weapons[4]=getfilecontents("cv2/images/holywater.gd")
gfx.weapons[5]=getfilecontents("cv2/images/cv2_diamond.gd")
gfx.weapons[6]=getfilecontents("cv2/images/cv2_flame.gd")
gfx.weapons[7]=getfilecontents("cv2/images/cv2_stake.gd")
gfx.weapons[8]=getfilecontents("cv2/images/cv2_laurel.gd")
gfx.weapons[9]=getfilecontents("cv2/images/cv2_garlic.gd")
gfx.holyfire={}
gfx.holyfire.test=getfilecontents("cv2/images/holyfire.gd")
gfx.holyfire[0]=getfilecontents("cv2/images/holyfire0.gd")
gfx.holyfire[1]=getfilecontents("cv2/images/holyfire1.gd")
gfx.holyfire[2]=getfilecontents("cv2/images/holyfire2.gd")
gfx.holyfire[3]=getfilecontents("cv2/images/holyfire3.gd")
gfx.holyfire[4]=getfilecontents("cv2/images/holyfire4.gd")
gfx.holywater={}
gfx.holywater.test=getfilecontents("cv2/images/holywater.gd")
gfx.boomerang={}
gfx.boomerang[0]=getfilecontents("cv2/images/boomerang1.gd")
gfx.boomerang[1]=getfilecontents("cv2/images/boomerang2.gd")
gfx.boomerang[2]=getfilecontents("cv2/images/boomerang3.gd")
gfx.bigbat={}
gfx.bigbat[0]=getfilecontents("cv2/images/cv1_bigbat1.gd")
gfx.bigbat[1]=getfilecontents("cv2/images/cv1_bigbat2.gd")
gfx.bigbat[2]=getfilecontents("cv2/images/cv1_bigbat3.gd")
gfx.bone = {}
gfx.bone[0]=getfilecontents("cv2/images/cv2_bone1.gd")
gfx.bone[1]=getfilecontents("cv2/images/cv2_bone2.gd")
gfx.bone[2]=getfilecontents("cv2/images/cv2_bone3.gd")
gfx.axe = {}
gfx.axe[0]=getfilecontents("cv2/images/cv1axe1.gd")
gfx.axe[1]=getfilecontents("cv2/images/cv1axe2.gd")
gfx.axe[2]=getfilecontents("cv2/images/cv1axe3.gd")
gfx.axe[3]=getfilecontents("cv2/images/cv1axe4.gd")
gfx.candles = {}
gfx.candles[0]=getfilecontents("cv2/images/cv1candle1_1.gd")
gfx.candles[1]=getfilecontents("cv2/images/cv1candle1_2.gd")

gfx.block = getfilecontents("cv2/images/block.gd")

mnu.cursor_image=gfx.cv2heart

local subScreen = {}

local ignoreErrors = false
local useGD = false

if useGD then
    if not pcall(function()
        require "gd"
    end) then
        if ignoreErrors then
            --pass
        else
            spidey.error = function()
                gui.drawrect(0,8,spidey.screenWidth-1,spidey.screenHeight-1, "#00000080")
                gui.text(0+8*2, 8+8*10, "Error: gd not loaded.\n\nWindows: Put the lua-GD .dll files in the FCEUX \nfolder, and restart FCEUX.","white","clear")
            end
        end
    end
end

if gd then
    --gfx.items.bag = gd.createFromPng("cv2/images/bag.png"):gdStr()
    --gfx.items.cross = gd.createFromPng("cv2/images/cross.png"):gdStr()
    gfx.block = gd.createFromPng("cv2/images/block.png"):gdStr()
    --spidey.writeToFile('cv2/images/bag.gd', gfx.items.bag)
    --spidey.writeToFile('cv2/images/cross.gd', gfx.items.cross)
    spidey.writeToFile('cv2/images/block.gd', gfx.block)
end

if false then
    temp=getfilecontents('cv2/cv2.gfx')
    if temp then
        temp=TSerial.unpack(temp)
        gfx=temp
        emu.message("loaded.")
     else
        --emu.message("Error: could not load data.")
     end
end

temp=getfilecontents('cv2/cv2.dat')
if temp then
    temp=TSerial.unpack(temp)
    game.data=temp
else
    --emu.message("Error: could not load data.")
end
game.data = game.data or {}
game.data.enemies=game.data.enemies or {}


refight_bosses=false
relics={}
relics.names = cv2data.relics.names

weapons={}
weapons.gfx={}

map={x=4,y=8*4,linkx=0,linky=0,scale=2,data=''}
map.colors={'red','white','blue','grey','purple'}
map.linkcolor={[0]='#0f0',[1]='#080',[2]='#00bf00'}
map.overworld_colors={[0x04]="#fcbcb0", [0x05]="#80d010",[0x06]="#009400", [0x07]="#548554", [0x08]="#f7dd9d", [0x09]="#F0BC3C", [0x0a]="#ff0c0c", [0x0b]="#c84c0c", [0x0c]="#3cbcfc", [0x0d]="#3cbcfc"}

local locations = cv2data.locations

o={}
o.count=12
o.player = {}
o.boss={}

o.player.gold = 0
o.player.maxHearts = 99

for i=0,o.count-1 do
    o[i]={}
end


o.player.bossdoor=function()
    --Don't let player leave room
    n=0x17
    if o.player.x<0+n then o.player.x=0+n end
    if o.player.x>255-n then o.player.x=255-n end
    if o.player.y<0+n then o.player.y=0+n end
    if o.player.y>255-n then o.player.y=255-n end
    memory.writebyte(0x0348, o.player.x)
    memory.writebyte(0x0324, o.player.y)
    o.player.inBossRoom=true
end

o.whip={}
o.whip[0]={}
o.whip[1]={}
o.weapons={}
o.weapons[0]={}
o.weapons[1]={}
o.weapons[2]={}

o.custom={}
o.custom.count=500
o.custom.destroyall=function() for _i=0,o.custom.count-1 do o.custom[_i].active=0 end end
for i=0,o.custom.count-1 do
    o.custom[i]={type='',active=0,x=0,y=0}
end

o.custom.isOnScreen=function(i)
    if not o.custom[i].area then return false end
    return (area1==o.custom[i].area[1] and area2==o.custom[i].area[2] and area3==o.custom[i].area[3])
end

o.custom.createCandles = function()
    for k,v in ipairs(candles) do
        i=getunusedcustom()
        if i then
            o.custom[i].type = v.type
            --o.custom[i].area = v.area
            o.custom[i].area = {
                [1]=v.area[1],
                [2]=v.area[2],
                [3]=v.area[3],
            }
            o.custom[i].x = v.x
            o.custom[i].y = v.y
            o.custom[i].outscreen = v.outscreen
            o.custom[i].active = v.active
        end
    end
end


--converts unsigned 8-bit integer to signed 8-bit integer
function signed8bit(_b)
if _b>255 or _b<0 then return false end
if _b>127 then return (255-_b)*-1 else return _b end
end

function getunusedcustom()
    for _i=1,o.custom.count-1 do
        if o.custom[_i].active==0 then
            o.custom[_i] = {x=0,y=0}
            
            o.custom[_i].outscreen=nil
            o.custom[_i].alivetime=0
            o.custom[_i].xs=0
            o.custom[_i].ys=0
            --o.custom[_i].textIndex=0
            
            return _i
        end
    end
    return false
end

function getCustomCount(t)
    local count=0
    for k,v in ipairs(o.custom) do
        if v.active==1 and v.type==t then
            count=count+1
        end
    end
    return count
end


--Still sort of experimental
function getenemydata(objnum)
    local ret={}
    ret.count=0x0c
    --ret.count=0x11
    local i=0
    for i=0,ret.count-1 do
        ret[i]=memory.readbyte(0x300+(0x24*i)+objnum)
    end
    return ret
end
function setenemydata(objnum,edata)
    local i=0
    for i=0,edata.count-1 do
        memory.writebyte(0x300+(0x24*i)+objnum,edata[i])
    end
end

function getExtraData()
    if memory.readbyte(0x7000) ~= 0x42 then
        -- initialize
        for i=1,100 do
            memory.writebyte(0x7000+i,0)
        end
        memory.writebyte(0x7000,0x42)
    end
    o.player.gold = memory.readword(0x7000+1)
end

function getunused()
    for _i=0,o.count-1 do
        if o[_i].type==0 then
            return _i
        end
    end
    return -1
end

function hideHP()
        -- Hide graphics for HP
        memory.writebyte(0x0203,0xff)
        memory.writebyte(0x0207,0xff)
        memory.writebyte(0x020b,0xff)
        memory.writebyte(0x020f,0xff)
end

function drawSubScreen()
    if not subScreen.cursorX then
        enterSubScreen()
    end
    
    --if msgstatus ~= 0x03 then return end
    if msgstatus == 0 then return end
    
    local x=-4
    local y=0
    local h = 14+2
    local w = 14+10
    local subScreenFont = 2
    local itemFont = 2
    gui.drawbox(x+28-9, y+28+1-8,x+ 24+8*w+10, 28+24+h*08+8+4, "black", "black")
    gui.drawbox(x+28-5, y+28-4, x+24+8*w+6,28+ 24+h*08+4+1+4, "black", borderColor)
    gui.drawbox(x+28-5-1, y+28-4+1, x+24+8*w+4+3, 28+24+h*08+4+1-1+4, "clear", borderColor)
    
    drawfont(x+28,y+28+8*1,font[subScreenFont], "Simon")
    drawfont(x+28+8*15,y+28+8*1,font[subScreenFont], string.format("Level %02d", o.player.level))
    
    drawfont(x+28+8*0,y+28+8*18,font[subScreenFont], string.format("Day %d",day+1))
    drawfont(x+28+8*12,y+28+8*18,font[subScreenFont], string.format("Time: %s",time))
    
    drawfont(x+28+8*11,y+28+8*4,font[subScreenFont], string.format(" HP: %3d %3d", o.player.hp, o.player.maxHp))
    
    --drawfont(x+28+8*11,y+28+8*5,font[subScreenFont], "Exp:    1234")
    
    drawfont(x+28+8*11,y+28+8*5,font[subScreenFont], string.format("Exp:  %6d", getCurrentExp()))
    drawfont(x+28+8*10,y+28+8*6,font[subScreenFont], string.format("Next:  %6d", o.player.expNext))
    
    gui.drawbox(x+28+8*0, y+28+8*7+3, x+28+8*23+6,y+28+8*7+4, "clear", borderColor)
    
    drawfont(x+28,y+28+8*8,font[itemFont], cv2data.whips.names[o.player.whip])
    
    -- draw relics
    for i=1,6 do
        if hasRelic(i) then
            gui.gdoverlay(x+28+16*i-16,y+28+8*10,gfx.relics[i])
        end
    end
    
    
--    gui.gdoverlay(x+28+8*0,y+28+8*10,gfx.relics[1])
--    gui.gdoverlay(x+28+8*2,y+28+8*10,gfx.relics[2])
--    gui.gdoverlay(x+28+8*4,y+28+8*10,gfx.relics[3])
--    gui.gdoverlay(x+28+8*6,y+28+8*10,gfx.relics[4])
--    gui.gdoverlay(x+28+8*8,y+28+8*10,gfx.relics[5])
--    gui.gdoverlay(x+28+8*10,y+28+8*10,gfx.relics[6])
    
    --gui.gdoverlay(x+28+(relics.current*16-16),y+28+8*9,gfx.arrowcursor)
    
    -- draw cursors
    --if subScreen.cursorY==1 or spidey.counter % 3==0 then
    if subScreen.relic > 0 then
        gui.drawbox(x+28+(subScreen.relic*16-16)-2,y+28+8*10-2,x+28+(subScreen.relic*16-16)+8+1,y+28+8*10+8+1,"clear","#0070ec")
    end
    --if subScreen.cursorY==0 or spidey.counter % 3==0 then
    if subScreen.weapon > 0 then
        gui.drawbox(x+28+(subScreen.weapon*16-16)-2,y+28+8*12-2,x+28+(subScreen.weapon*16-16)+8+1,y+28+8*12+8+1,"clear","#0070ec")
    end
    
    if spidey.counter %3<2 then
        gui.drawbox(x+28+(subScreen.cursorX*16-16)-2,y+28+8*8-2+16*subScreen.cursorY,x+28+(subScreen.cursorX*16-16)+8+1,y+28+8*8+8+1+16*subScreen.cursorY,"clear","blue")
    end
    
    --if subScreen.cursorY == 0 then subScreen.relic = subScreen.cursorX end
    --if subScreen.cursorY == 1 then subScreen.weapon = subScreen.cursorX end
    
    -- laurels count
    gui.gdoverlay(x+28+8*19,y+28+8*8,gfx.weapons[8])
    drawfont(x+28+8*20,y+28+8*8,font[itemFont], string.format(":%02d",o.player.laurels or 0))
    
    -- garlic count
    gui.gdoverlay(x+28+8*19,y+28+8*9,gfx.weapons[9])
    drawfont(x+28+8*20,y+28+8*9,font[itemFont], string.format(":%02d",o.player.garlic or 0))
    
    --gui.gdoverlay(x+28+8*19,y+28+8*11,gfx.items.bag)
    
    -- hearts count
    gui.gdoverlay(x+28,y+28+8*4,gfx.cv2heart)
    drawfont(x+28+8*1,y+28+8*4,font[itemFont], string.format(":%02d",o.player.hearts or 0))
    
    drawfont(x+28+8*0,y+28+8*5,font[itemFont], string.format("G:%d",o.player.gold or 0))
    
    drawfont(x+28+8*14,y+28+8*17,font[itemFont], string.format("Lives: %02d",o.player.lives-1))
    
    -- draw weapons and items
    for i,v in ipairs(gfx.weapons) do
        if hasItem(i) then
            gui.gdoverlay(x+28+8*(i*2-2),y+28+8*12,v)
        end
    end
    --if o.player.hascross then
    if hasItem(8) then
        gui.gdoverlay(x+28+8*(10*2-2),y+28+8*12,gfx.items.cross)
    end
    if hasItem(7) then
        gui.gdoverlay(x+28+8*(11*2-2),y+28+8*12,gfx.items.bag)
    end

    
    --drawfont(8*22,8*4+4,font[current_font], string.format('%s',relics.currentname))
    
    if not hasItem(subScreen.weapon) then
        weapons.current=0
        subScreen.weapon = 0
        memory.writebyte(0x0090, weapons.current or 0)
    end
    if not hasRelic(subScreen.relic) then
        relics.current=0
        subScreen.relic = 0
        memory.writebyte(0x004F, relics.current or 0)
    end
    
    if spidey.debug.enabled then
        drawfont(28+8*0-4,28+8*22,font[subScreenFont], string.format("%02X %02X",subScreen.cursorX or 0,subScreen.cursorY or 0))
    end
    --drawfont(28+8*0-4,28+8*22,font[subScreenFont], string.format("%02X %02X",subScreen.relic or 0,subScreen.weapon or 0))
end


function enterSubScreen()
    subScreen.relic = relics.current
    subScreen.weapon = weapons.current
    
    memory.writebyte(0x33, 0)
    subScreen.realCursorY = 0
    subScreen.cursorY = 1
    
    if subScreen.cursorY==1 then subScreen.cursorX = subScreen.cursorX or relics.current end
    if subScreen.cursorY==2 then subScreen.cursorX = subScreen.cursorX or weapons.current end


--  if subScreen.cursorY == 0 then subScreen.cursorX = subScreen.relic end
--  if subScreen.cursorY == 1 then subScreen.cursorX = subScreen.weapon end
end

function exitSubScreen()
    if hasItem(subScreen.weapon) or (hasItem(8) and subScreen.weapon==10) then
        if subScreen.weapon == 10 then
            weapons.current=subScreen.weapon
            memory.writebyte(0x0090, 1)
        else
            weapons.current=subScreen.weapon
            memory.writebyte(0x0090, weapons.current or 0)
        end
    else
        weapons.current=0
        subScreen.weapon = 0
        memory.writebyte(0x0090, weapons.current or 0)
    end
    if hasRelic(subScreen.relic) then
        relics.current=subScreen.relic
        memory.writebyte(0x004F, relics.current or 0)
    else
        relics.current=0
        subScreen.relic = 0
        memory.writebyte(0x004F, relics.current or 0)
    end
end


function drawHUD()
        locations[area1]=locations[area1] or {}
        locations[area1][area2]=locations[area1][area2] or {}
        locations[area1][area2][area3]=locations[area1][area2][area3] or string.format('%s %s %s',area1,area2,area3)
        --gui.text(8,8*8, string.format("%s",locations[area1][area2][area3] or ''))
        displayarea=string.format("%s",locations[area1][area2][area3] or '')
        displayarea=string.gsub(displayarea, '.(Pt[1234])','') -- trim the " (Pt1)" etc.
        
        if spidey.debug.enabled then
            --spidey.debug.font=font[6]
            --spidey.debug.font=font[current_font]
            spidey.debug.font=font[5]
            gui.drawbox(8*16, 8*5+5, 8*16+8*16, 8*5+5+8*4, "#40404080", "#40404080")
            drawfont(8*16,8*5+5,spidey.debug.font, string.format("Area: %02x %02x %02x",area1,area2,area3))
            drawfont(8*16,8*6+5,spidey.debug.font, string.format("Scroll: %02x %02x",scrollx, scrolly))
            drawfont(8*16,8*7+5,spidey.debug.font, string.format("Player: %02x %02x",o.player.x, o.player.y))
            drawfont(8*16,8*8+5,spidey.debug.font, string.format("Mouse: %02x %02x ",spidey.inp.xmouse,spidey.inp.ymouse))
        end
        
        name = "^aH^ai"
        string.gsub(name, "^a", "")
        
        gui.drawbox(0, 0, 256, 20+8*3, "black", "black")
        drawfont(0+1,8+4,font[current_font], displayarea)
        
        drawfont(0+1,8*2+4,font[current_font], "PLAYER")
        drawfont(0+1,8*3+4,font[current_font], "ENEMY")
        o.player.hp=o.player.hp or 0
        o.player.maxHp=o.player.maxHp or 0
        if o.player.inBossRoom==true then
            --drawfont(0,40,font[current_font], "yep")
            o.boss.maxHp=o.boss.maxHp or 140
            o.boss.hp=memory.readbyte(0x4c8)
        else
            --drawfont(0,40,font[current_font], "nope")
            o.boss.maxHp=nil
            o.boss.hp=nil
        end
        -- Draw new life bar; Always shows 16 bars.
        for x=1,16 do
            if x<=math.floor((o.player.hp/o.player.maxHp)*16) then
                gui.drawbox((x-1)*4+8*7, 8*2+4+1,(x-1)*4+8*7+  2, 8*2+4+1+  5, "#d82800", "#d82800")
            else
                gui.drawbox((x-1)*4+8*7, 8*2+4+1,(x-1)*4+8*7+  2, 8*2+4+1+  5, "black", "white")
            end
        end
        
        for x=1,16 do
            if (not o.player.inBossRoom) or x<=math.floor((o.boss.hp/o.boss.maxHp)*16) then
                gui.drawbox((x-1)*4+8*7, 8*3+4+1,(x-1)*4+8*7+  2, 8*3+4+1+  5, "#fc7460", "#fc7460")
            else
                gui.drawbox((x-1)*4+8*7, 8*3+4+1,(x-1)*4+8*7+  2, 8*3+4+1+  5, "black", "white")
            end
        end
        
        gui.gdoverlay(8*21-1,8*2+4,gfx.cv2heart)
        drawfont(8*22,8*2+4,font[current_font], string.format('-%02s',o.player.hearts or 0))
        drawfont(8*21,8*3+4,font[current_font], string.format('P-%02s',(o.player.lives or 1) - 1))
        
        drawfont(8*21-1,8+4,font[current_font], "time:"..time)
        --drawfont(256-4-8*5,8+4,font[current_font], time)
        
        if relics.currentname then
            if gfx.relics[relics.current] then gui.gdoverlay(8*21-1,35,gfx.relics[relics.current]) end
            drawfont(8*22,8*4+4,font[current_font], string.format('%s',relics.currentname))
        end
        
        if testgfx then gui.gdoverlay(4+8*15,11+8,testgfx) end
        
        --sp weapon box
        gui.drawbox(128,20,148+11,20+21, "clear", "#d82800")
        gui.drawbox(128+1,20+1,148+11-1,20+21-1, "clear", "#d82800")
        
        --if relics.currentname=="ring" and weapons.currentname=="Golden Dagger" then
        if weapons.currentname=="Dagger" and subScreen.weapon == 10 then
            gui.gdoverlay(145-9,11+12,gfx.boomerang[2])
        elseif relics.currentname=="ring" and weapons.currentname=="Silver Dagger" then
            gui.gdoverlay(145-13,11+11,gfx.axe[0])
        elseif weapons.currentname then
            if gfx.weapons[weapons.current] then gui.gdoverlay(145-5,11+16,gfx.weapons[weapons.current]) end
        end
end

function getheart()
    simon_x= memory.readbyte(0x0348)
    simon_y= memory.readbyte(0x0324)

--        if memory.readbyte(0x03ba)==0 then
--            simon_x= memory.readbyte(0x0348)
--            simon_y= memory.readbyte(0x0324)
--            memory.writebyte(0x03ba,0x37)
--            memory.writebyte(0x034e,simon_x)
--            memory.writebyte(0x032a,simon_y)
--            memory.writebyte(0x03f0,0x01) --helps to init it; frame?
--            memory.writebyte(0x0396,0x00) --x speed
--            memory.writebyte(0x044a,0x18) --make fire disappear faster
--        end

--n=0
--for i=0,o.count-1 do
--    if memory.readbyte(0x03ba+i)==0 then
--        n=i
--        break
--    end
--end


n=getunused()
if n==-1 then n=0 end
local type = 0x37
--type = 0x05
memory.writebyte(0x3ba+n,type)
memory.writebyte(0x3de+n,0x40)
memory.writebyte(0x4c8+n,0x63) --hp
memory.writebyte(0x44a+n,0x00)
memory.writebyte(0x46e+n,0x00)

memory.writebyte(0x0306+n, 0x9c) -- frame

memory.writebyte(0x34e+n,simon_x)
memory.writebyte(0x32a+n,simon_y)
--            o[n].type=memory.readbyte(0x03ba+n)
--            o[i].frame=memory.readbyte(0x0306+n)
--            o[i].x=memory.readbyte(0x0348+6+i)
--            o[i].y=memory.readbyte(0x0324+6+i)
--            o[i].ys=memory.readbyte(0x036c+6+i)
--            o[i].xs=memory.readbyte(0x0396+i)
--            o[i].team=memory.readbyte(0x03de+i) --00=uninitialized 01=enemy 40=friendly+talks 80=friendly 08=move with player
--            o[i].facing=memory.readbyte(0x0420+6+i)
--            o[i].stun=memory.readbyte(0x04fe+i)
--            o[i].state=memory.readbyte(0x044a+i) --sometimes it's counter
--            o[i].state2=memory.readbyte(0x046e+i)
--            o[i].statecounter=memory.readbyte(0x04b6+i) --used with drac, carmilla, others?
--            o[i].xdist=math.abs(o.player.x-o[i].x)
--            o[i].ydist=math.abs(o.player.y-o[i].y)
--            o[i].facingplayer=((o[i].x<o.player.x and o[i].facing==1) or (o[i].x>o.player.x and o[i].facing==0))
--            o[i].hp=memory.readbyte(0x04c8+i) --note: if hp==0, it can't be hit


end


function hurtplayer()
    --atm, we hurt the player by creating an unfriendly heart on top of him
    if o.player.inv>0 then return end --if he's invincible, don't bother.
    onum = getunused()
    if not onum then return false end --should create an alternate method if it fails
    --memory.writebyte(0x03b7+3+onum,0x36) --burn
    memory.writebyte(0x03b7+3+onum,0x37) --heart
    memory.writebyte(0x034b+3+onum,o.player.x)
    memory.writebyte(0x0327+3+onum,o.player.y)
    memory.writebyte(0x03de+onum,0x01) --not friendly
    memory.writebyte(0x03ed+3+onum,0x01) --helps to init it; frame?
    memory.writebyte(0x0393+3+onum,0x00) --x speed
    memory.writebyte(0x044a+onum,0x18) --make fire disappear faster
    return true
end

function hurtenemy(ii)
    if o[ii].stun>0 then return end --if he's invincible, don't bother.
    onum = 2
    --memory.writebyte(0x03b7+onum,0x36) --burn
    --memory.writebyte(0x03b7+onum,0x37) --heart
    --memory.writebyte(0x03b7+onum,0x01) --dagger
    --memory.writebyte(0x03b7+onum,0x05) --crystal
    --memory.writebyte(0x03b7+onum,0x06) --sacred flame
    --memory.writebyte(0x03b7+onum,0x02) -- ?
    --memory.writebyte(0x03b7+onum,0x37) -- heart
    memory.writebyte(0x03b7+onum,0x48)
    
    memory.writebyte(0x034b+onum,o[ii].x)
    memory.writebyte(0x0327+onum,o[ii].y)
    memory.writebyte(0x03de-3+onum,0x00) -- player team
    --memory.writebyte(0x03ed+onum,0x01) --helps to init it; frame?
    memory.writebyte(0x03ed+onum,0x80) --helps to init it; frame?
    --memory.writebyte(0x0303+onum,0x00) --frame
    --memory.writebyte(0x04c8-3+onum, 0x00) --hp
    memory.writebyte(0x0393+onum,0x00) --x speed
    memory.writebyte(0x036f+onum,0xff) --y speed
--    memory.writebyte(0x0411+onum,0x22) --flame frame thing
--    memory.writebyte(0x04c5+onum,0x00) --flame frame thing 2
    
    --memory.writebyte(0x0447+onum,0x18) --make fire disappear faster
    --memory.writebyte(0x04a1+onum,0x01) --make dagger disappear faster
    --memory.writebyte(0x040e+3+onum,0x00) --state0 (neutral frame thing)
    return true
end

function _hurtenemy(ii)
    if o[ii].stun>0 then return end --if he's invincible, don't bother.
    --onum = getunused()
    onum = 2
    if not onum then return false end --should create an alternate method if it fails
    --memory.writebyte(0x03b7+onum,0x36) --burn
    --memory.writebyte(0x03b7+onum,0x37) --heart
    --memory.writebyte(0x03b7+onum,0x01) --dagger
    --memory.writebyte(0x03b7+onum,0x05) --crystal
    --memory.writebyte(0x03b7+onum,0x06) --sacred flame
    memory.writebyte(0x03b7+onum,0x02)
    
    memory.writebyte(0x034b+onum,o[ii].x)
    memory.writebyte(0x0327+onum,o[ii].y)
    memory.writebyte(0x03de-3+onum,0x00) -- player team
    memory.writebyte(0x03ed+onum,0x01) --helps to init it; frame?
    memory.writebyte(0x0303+onum,0x00) --frame
    memory.writebyte(0x04c8-3+onum, 0x00) --hp
    memory.writebyte(0x0393+onum,0x00) --x speed
    memory.writebyte(0x0411+onum,0x22) --flame frame thing
    memory.writebyte(0x04c5+onum,0x00) --flame frame thing 2



    --memory.writebyte(0x0447+onum,0x18) --make fire disappear faster
    --memory.writebyte(0x04a1+onum,0x01) --make dagger disappear faster
    --memory.writebyte(0x040e+3+onum,0x00) --state0 (neutral frame thing)
    return true
end



cv2fire = getfilecontents("cv2/images/cv2fire.gd")

bigbat={}
bigbat.xo={}
bigbat.yo={}
bigbat.xo[0]=0;bigbat.yo[0]=0
bigbat.xo[1]=24;bigbat.yo[1]=8
bigbat.xo[2]=15;bigbat.yo[2]=4

bone={xo={},yo={}}
bone.xo[0]=8;bone.yo[0]=8
bone.xo[1]=8;bone.yo[1]=8
bone.xo[2]=3;bone.yo[2]=8

bone.xo[3]=3;bone.yo[3]=8
msg=''


--inp = input.read()
inp = input_read()

emu.registerexit(function(x)
    emu.message("")
end)
savestate.registerload(o.custom.destroyall) --destroy custom objects if state loaded

--function onRestart()
--end
--memory.registerexec(0xc521,1,onRestart)

--memory.registerexec(0xdf4f,1,spWeaponBreak)
memory.registerexec(0xda69,1,
    function()
        local a,x,y,s,p,pc=memory.getregisters()
        local currentWeapon=memory.readbyte(0x03b7+x-3)
        if spWeaponBreak then spWeaponBreak(currentWeapon, x-3) end
    end
)

-- triggers when an enemy takes damage from whip
--memory.registerexec(0x8920,1,
--    function()
--        local a,x,y,s,p,pc=memory.getregisters()
--        memory.writebyte(0x4c2+x,40)
--        memory.setregister("a",0x10)
--        memory.setregister("y",0x00)
--        local i=x-6
--        emu.message(string.format("%02X %02X",o[i].type,a))
--    end
--)

function addExp(n)
    local e = tonumber(string.format("%02x%02x", memory.readbyte(0x47), memory.readbyte(0x46)))
    e=math.min(9999, e+n)
    
    
    o.player.gold = o.player.gold+5
    memory.writeword(0x7000+1, o.player.gold)
    
    need = getExpNeeded()


    if e>=need then
        --getheart()
        
        --emu.message("level up!")
        
        createLevelUpText()
        
        e=e-need
        o.player.level = math.min(o.player.level+1, 99)
        memory.writebyte(0x008b, o.player.level)
    end
    
    e = tonumber(string.format("%04d",e),16)
    memory.writebyte(0x46, e % 0x100)
    memory.writebyte(0x47, (e-(e % 0x100))/0x100)
end

function setHearts(n)
    o.player.hearts = n
    if o.player.hearts > o.player.maxHearts then
        o.player.hearts = o.player.maxHearts
    end
    if o.player.hearts < 0 then o.player.hearts=0 end
    memory.writebyte(0x48, tonumber(string.format("%02d",o.player.hearts % 100),16))
    memory.writebyte(0x49, tonumber(string.format("%02d",(o.player.hearts-(o.player.hearts % 100))/100),16))
end


-- buying (cost)
-- changes sp weapon cost too, but we fix that elsewhere
memory.registerexec(0xd86b,1, function()
    local a,x,y,s,p,pc=memory.getregisters()
    local h1=memory.readbyte(0x05)
    local h2=memory.readbyte(0x09)
    
    
    local cost = tonumber(string.format("%02x%02x",h1,h2))
    if o.player.gold >= cost then
        -- free
        memory.writebyte(0x05, 0)
        memory.writebyte(0x09, 0)
        
        -- deduct from gold here
        o.player.gold = o.player.gold-cost
        memory.writeword(0x7000+1, o.player.gold)
    else
        -- not buyable
        memory.writebyte(0x05, 0xaa)
        memory.writebyte(0x09, 0xaa)
    end
end)

-- buying (deduct)
-- changes sp weapon cost too, but we fix that elsewhere
memory.registerexec(0xd888,1, function()
    -- don't deduct hearts
    memory.setregister("a", memory.readbyte(0x48))
end)
memory.registerexec(0xd88c,1, function()
    -- don't deduct hearts
    memory.setregister("a", memory.readbyte(0x49))
end)

-- triggers when an enemy dies from whip
memory.registerexec(0x8927,1,
    function()
        do return end -- disable
        if not spidey.debug.enabled then return end
        local a,x,y,s,p,pc=memory.getregisters()
        local t = memory.readbyte(0x03b4+x)
        if cv2data.enemies[t] then
            emu.message(string.format("%02X %s",x,cv2data.enemies[t].name or "?"))
        else
            emu.message(string.format("%02X %02x",x,t))
        end
    end
)

-- triggers when an enemy dies from anything
memory.registerexec(0x8948,1, function()
        local a,x,y,s,p,pc=memory.getregisters()
        local t = memory.readbyte(0x03b4+x)
        
        if cv2data.enemies[t] then
            local e = cv2data.enemies[t].exp or 0
            -- extra exp at night, but not for town zombies
            if night and e>0 and t~=0x17 then e=e+1 end
            addExp(e)
        end
        
        if not spidey.debug.enabled then return end
        if cv2data.enemies[t] then
            emu.message(string.format("%02X %s",t,cv2data.enemies[t].name or "?"))
        else
            emu.message(string.format("%02X %02x",x,t))
        end
end)

memory.registerexec(0x8918,1,
    function()
        local a,x,y,s,p,pc=memory.getregisters()
        --local currentWeapon=memory.readbyte(0x03b7+x-3)
        --if spWeaponBreak then spWeaponBreak(currentWeapon, x-6) end
        --emu.pause()
        --memory.writebyte(0x4c2+x,40)
--        memory.setregister("a",0x10)
--        memory.setregister("y",0x00)
        --local i=x-6
        --emu.message(string.format("%02X %02X",o[i].type or 0,a))
    end
)

-- create a callback for manipulating initial hp values of enemies
memory.registerexec(0x8147,1,
    function()
        local a,x,y,s,p,pc=memory.getregisters()
        local t=memory.readbyte(0x03ba+x-6)
        local night=(memory.readbyte(0x82)==0x01)
        if initEnemyHp then
            local a=initEnemyHp(x-6,t,a,night)
            if a then memory.setregister("a",a) end
        end
    end
)

function initEnemyHp(i, t, hp, night)
    --if game.night then hp=hp*.5 end
    --if t==0x03 then hp=50 end
    --emu.message(string.format("Enemy %02X Type %02X hp set to %02X",i,t,hp))
    return hp
end


-- ********** start of map stuff **********
-- This section is stuff related to the map in this hack:
-- http://www.romhacking.net/hacks/1032/
--
memory.registerexec(0xff1a,1,
    function()
        local a,x,y,s,p,pc=memory.getregisters()
        mapmenu=true
    end
)

-- map exit
memory.registerexec(0xff3c,1,
    function()
        local a,x,y,s,p,pc=memory.getregisters()
        mapmenu=false
        specialPause=true
        if exitSpecialPause then
            specialPause = false
            exitSpecialPause = false
        else
            specialPause=true
            memory.writebyte(0x007a,2) -- Prevent exit, but now we can use our cheat menu
        end
        
    end
)
-- ********** end of map stuff **********

-- create a callback for manipulating enemy damage
memory.registerexec(0x883a,1,
    function()
        local a,x,y,s,p,pc=memory.getregisters()
        local t=memory.readbyte(0x03ba+x-6)
        if enemyDamage then
            local a = enemyDamage(x-6,t,a)
            --a=20
            if a then memory.setregister("a",a) end
        end
    end
)

function enemyDamage(i,t,damage)
    --if game.night then damage = 99 else damage = 1 end
    game.data.enemies[t] = game.data.enemies[t] or {}
    game.data.enemies[t].damage = game.data.enemies[t].damage or {}
    if night then
        game.data.enemies[t].damage[2]=damage
    else
        game.data.enemies[t].damage[1]=damage
    end
    
    --emu.message(string.format("Damage %02X",damage))
    return damage
end


memory.registerexec(0x8a5f,1,
    function()
        local a,x,y,s,p,pc=memory.getregisters()
        local t=memory.readbyte(0x03ba+y-6)
        memory.setregister("x",0)
--        if enemyDamage then
--            local a = enemyDamage(x-6,t,a)
--            if a then memory.setregister("a",a) end
--        end
    end
)

-- remove heart use from sp weapons
memory.registerexec(0xd858,1, function()
    memory.setregister("a", 0)
end)


memory.registerexec(0xd7ea,1,
    function()
        local a,x,y,s,p,pc=memory.getregisters()
        local t=memory.readbyte(0x03ba+y-6)
        
        local w = weapons.current
        if subScreen.weapon == 10 then w=10 end
        
        local cost = cv2data.weapons[w].cost
        local abort = false
        if cost > o.player.hearts then
            -- abort weapon
            memory.setregister("a",0)
            memory.writebyte(0x40e,0)
            abort = true -- use this to cancel axes/boomerang
        else
            -- spend hearts
            setHearts(o.player.hearts - cost)
        end
        
--        if o.player.hearts==0 then
--            memory.setregister("a",0)
--            memory.writebyte(0x40e,0)
--        end
        
        -- abort throwing of holy water if fire is on ground
        if getCustomCount("holyfire")>0 then
            memory.setregister("a",0)
            memory.writebyte(0x40e,0)
        end
        if relics.currentname=="ring" and not abort then
            if a==0x02 then
                memory.setregister("a",0)
                if getCustomCount("axe")<3 then
                    createAxe(o.player.x,o.player.y)
                end
            elseif a==0x03 then
--                memory.setregister("a",0)
--                if getCustomCount("bansheeboomerang")<3 then
--                    createBoomerang(o.player.x,o.player.y)
--                end
            end
        end
        -- equippable cross (real item is the dagger)
        if subScreen.weapon == 10 and a==0x01 and not abort then
            memory.setregister("a",0)
            if getCustomCount("bansheeboomerang")<3 then
                createBoomerang(o.player.x,o.player.y)
            end
        end
    end
)

-- create a callback for manipulating enemy creation
memory.registerexec(0x80ec,1,
    function()
        local a,x,y,s,p,pc=memory.getregisters()
        if createEnemy then
            local a = createEnemy(x-6,a)
            if a then memory.setregister("a",a) end
        end
    end
)
function createEnemy(i,t)
    --if t==0x43 then t=0x3a end
    --if t==0x03 then t=0x13 end
    
    --if t==0x03 then t=0x3a end --turn skeletons into mummies
    
    --pattern1=6
    --pattern2=7
    --memory.writebyte(0x101,pattern1)
    --memory.writebyte(0x102,pattern2)
    
    
    --t=0
    --emu.message(string.format("Create enemy %02X",t))
    return t
end

-- create a callback for manipulating enemy projectile creation
memory.registerexec(0xde7b,1,
    function()
        local a,x,y,s,p,pc=memory.getregisters()
        if createEnemyProjectile then
            local t=x-6
            local xPos=memory.readbyte(0x0348+6+y-6)
            local yPos=memory.readbyte(0x0324+6+y-6)
            --emu.message(string.format("%02X (%02X,%02X)",y-6,xPos,yPos))
            local a = createEnemyProjectile(x-6,a,xPos,yPos)
            if a then memory.setregister("a",a) end
        end
    end
)
function createEnemyProjectile(i,t,x,y)
    if t==0x0c then
        t=0
        --createBone(o[i].x-scrollx,o[i].y-scrolly)
        for j=1, 2 do
            createBone(x,y)
        end
        --createBoomerang(x,y)
    end
    --if t==0x03 then t=0x13 end
    
    --if t==0x03 then t=0x3a end --turn skeletons into mummies
    
--    pattern1=6
--    pattern2=7
--    memory.writebyte(0x101,pattern1)
--    memory.writebyte(0x102,pattern2)
    
    
    --t=0
    --emu.message(string.format("Create enemy %02X",t))
    return t
end

function createDiamondTrail(x,y)
    i=getunusedcustom()
    if (i) then
        o.custom[i].type="diamondtrail"
        o.custom[i].x=x+scrollx
        o.custom[i].y=y+scrolly
--        o.custom[i].xs=math.random(-5,5)*.2
--        o.custom[i].ys=math.random(-5,5)*.1-2.8
        o.custom[i].xs=0
        o.custom[i].ys=0
        o.custom[i].active=1
    end
end

function createLevelUpText()
    i=getunusedcustom()
    if i then
        o.custom[i].type="levelup"
        o.custom[i].x=o.player.x+scrollx
        o.custom[i].y=o.player.y+scrolly-32
        o.custom[i].active=1
    end
end

function createBone(x,y)
    i=getunusedcustom()
    if (i) then
        o.custom[i].type="bone"
                --o.custom[i].x=inp.xmouse+scrollx
        --o.custom[i].y=inp.ymouse+scrolly
        o.custom[i].x=x+scrollx
        o.custom[i].y=y+scrolly
        o.custom[i].xs=math.random(-5,5)*.2
        --o.custom[i].xs=1
        o.custom[i].ys=math.random(-5,5)*.1-2.8
        --o.custom[i].ys=0
        --o.custom[i].xs=0
        --o.custom[i].ys=0
        o.custom[i].active=1
    end
end

function createAxe(x,y)
    i=getunusedcustom()
    if (i) then
        o.custom[i].type="axe"
        o.custom[i].x=x+scrollx
        o.custom[i].y=y+scrolly
        --o.custom[i].xs=math.random(-5,5)*.2
        --o.custom[i].ys=math.random(-5,5)*.1-2.8
        o.custom[i].hasHit=false
        o.custom[i].xs=4*.2
        o.custom[i].ys=-5*.1-2.8
        o.custom[i].facing=o.player.facing
        if o.custom[i].facing==1 then 
        else 
            o.custom[i].xs=o.custom[i].xs*-1
        end
        o.custom[i].active=1
    end
end

function createBoomerang(x,y)
    i=getunusedcustom()
    if (i) then
        o.custom[i].type="bansheeboomerang"
        o.custom[i].rebound = false
        o.custom[i].x=x+scrollx
        o.custom[i].y=y+scrolly
        --o.custom[i].rnd=math.random(0,90000)
        --o.custom[i].xs=math.random(-5,5)*.2
        --o.custom[i].xs=1
        o.custom[i].facing=o.player.facing
        if o.custom[i].facing==1 then 
            o.custom[i].xs=1.5 
        else 
            o.custom[i].xs=-1.5 
        end
        o.custom[i].ys=0
        o.custom[i].active=1
        o.custom[i].active=1
    end
end

--memory.registerexec(0xc5ad,1,
--    function()
--        local a,x,y,s,p,pc=memory.getregisters()
--        memory.setregister("a",a)
--        memory.setregister("x",x)
--        memory.setregister("y",y)
--    end
--)

-- set area after restart
memory.registerexec(0xc521,1, function()
    local a,x,y,s,p,pc=memory.getregisters()
    if o.player.inBossRoom == true then
        if area1==0x01 and area2==0x06 and area3==0x02 then
            -- Camille
            area3=0x01
            scrollx=0x200
            scrolly=0x66c
            o.player.x=0xd8
            o.player.y=0xbd
        elseif area1==0x01 and area2==0x09 and area3==0x02 then
            -- Death
            area3=0x01
            scrollx=0
            scrolly=0x66c
            o.player.x=0x1a
            o.player.y=0xbd
        else
            return
        end
        
        a=area3
        memory.setregister("a",a)
        memory.writebyte(0x0053, scrollx % 0x100)
        memory.writebyte(0x0054, (scrollx-(scrollx % 0x100))/0x100)
        memory.writebyte(0x0056, scrolly % 0x224)
        memory.writebyte(0x0057, (scrolly-(scrolly % 0x224))/0x224)
        memory.writebyte(0x0348, o.player.x)
        memory.writebyte(0x0324, o.player.y)
--        for i=0,o.count-1 do
--            memory.writebyte(0x03ba+i,0) -- enemy type
--            memory.writebyte(0x0306+i,0) -- enemy frame
--        end

    end
end)


-- start position after death
-- if player dies on a boss, start inside door
-- to push them out to left.
memory.registerexec(0xc50b,1,
    function()
        local a,x,y,s,p,pc=memory.getregisters()
        
        if o.player.inBossRoom == true then
            --o.player.x = 10
            --emu.pause()
            --a=0x00
            --memory.setregister("a",a)
        end
        
        if area1==0x01 and area2==0x09 and area3==0x02 then
--            area1=memory.readbyte(0x0030)
--            area2=memory.readbyte(0x0050)
--            area3=memory.readbyte(0x0051) % 0x80 --adds 0x80 if starting on right side
            --memory.writebyte(0x051, 01)
        end
        
        
    end
)

-- Modify the lives display by intercepting the 
-- given value to print and subtracting 1.
-- This will make it more like other CastleVania
-- games, where the lives are "extra" lives.
memory.registerexec(0xcc77,1,
    function()
        local a,x,y,s,p,pc=memory.getregisters()
        memory.setregister("a",a-1)
    end
)

-- experience gain from hearts
memory.registerexec(0xd4f7,1,
    function()
        local a,x,y,s,p,pc=memory.getregisters()
        y=0
        --y=0x50
        memory.setregister("y",y)
    end
)


function getExpNeeded(level)
    level = level or o.player.level
    --do return 10 end
    return level*50+100
end


function getCurrentExp()
    local exp = o.player.exp
    if i==0 then return exp end
    for i=0, o.player.level-1 do
       exp=exp + getExpNeeded(i)
    end
    return exp
end

-- intercept exp needed for level (low byte
memory.registerexec(0xd554+3,1, function(address)
        local a,x,y,s,p,pc=memory.getregisters()
        local e = getExpNeeded()
        --emu.message(string.format("%04d",e))
        a = tonumber(string.format("%02d",e % 100),16)
        memory.setregister("a",a)
end)

-- intercept exp needed for level (high byte)
memory.registerexec(0xd55e+3,1, function(address)
        local a,x,y,s,p,pc=memory.getregisters()
        local e = getExpNeeded()
        x = tonumber(string.format("%02d",(e - e % 100) / 100),16)
        --emu.message(string.format("%02x",x))
        memory.setregister("x",x)
end)

-- Fix level in sub screen so it displays decimal, not hex
memory.registerexec(0xf13f+2,1, function(address)
        local a,x,y,s,p,pc=memory.getregisters()
        a = tonumber(string.format("%02d",a),16)
        memory.setregister("a",a)
end)


-- intercept getting pointer to level data stuff
local f = function(address)
    local a,x,y,s,p,pc=memory.getregisters()
    
    if o.player.level>6 then -- for now, use stats for level 6 at levels > 6
        if address == 0x881c+3 then
            a = 0x3b
        else
            a = 0x8c
        end
    end
    
--    if address == 0x881c+3 then
--        a = 0xff
--    else
--        a = 0x8b
--    end
    memory.setregister("a",a)
end
memory.registerexec(0x881c+3,1, f)
memory.registerexec(0x8821+3,1, f)

-- change solid blocks (not visually)
-- *disabled* (second parameter is 0)
memory.registerexec(0xe8a2,0, function()
    local a,x,y,s,p,pc=memory.getregisters()
    local address = memory.readbyte(0x0a)+y
    --aa = block, ac=swamp ad=some are breakable
    if a==0xaa then a=0xae end
    a=0
    
    memory.setregister("a",a)
end)


memory.registerexec(0xe38d,1,
    function()
        do return end
        if not spidey.debug.enabled then return end
        local newMessage = "HELLO WORLD"
        local fontstr=" ABCDEFGHIJKLMNOPQRSTUVWXYZ.'v,                       0123456789!     -         !            ?    ETL            :"
        local msg=""
        msg=msg..fontstr:sub(msgchar+1,msgchar+1)
        
        local a,x,y,s,p,pc=memory.getregisters()
        local messageCounter = memory.readbyte(0x007c)
        if x==0x03 then
            --emu.message(string.format("msg=%02X msgindex=%02x x=%02x a=%02x",game.messageNum, messageCounter,x,a))
            --emu.pause()
        end
        if x==0x03 then
            if game.messageNum==0x0b then
                local fontstr=" ABCDEFGHIJKLMNOPQRSTUVWXYZ.'v,                       0123456789!     -         !            ?    ETL            :"
                --msg=msg..fontstr:sub(msgchar+1,msgchar+1)
                msg=msg..fontstr:sub(msgchar+1,msgchar+1)
            end
            --emu.message(string.format("%02X %02x",game.messageNum, messageCounter))
            --emu.pause()
            a=0x01
            
            local c = messages[game.messageNum]:sub(messageCounter+1, messageCounter+1)
            
            
local m = [[TURN RIGHT
FOR CAMILLA
CEMETERY,
LEFT FOR THE
ALJIBA WOODS.]]

local m = [[THE QUICK,
BROWN FOX  
JUMPS    
OVER THE    
LAZY DOG.    ]]
            
local m = "THE QUICK, BROWN FOX JUMPS OVER THE LAZY DOG."

            
            local c = m:sub(messageCounter, messageCounter)
            if textMap2[0x10] then
                emu.message('yep')
            end
            if textMap2[c] or true then
                c=textMap2[c] or 0
                --c=0x18
                memory.setregister("a",c)
                memory.writebyte(0x700+x,c)
            else
                --c=0x18
                --memory.setregister("a",c)
            end
            
            

        end
        
    end
)


-- Triggered when a sp weapon breaks
function spWeaponBreak(currentWeapon, i)
    if currentWeapon == 4 then
--        a = 0x09
--        memory.setregister("a", a)
        --emu.pause()
        
        
        for j=0,0 do
            local onum=getunusedcustom()
            if (onum) then
                o.custom[onum].type="holyfire"
                o.custom[onum].x=o.weapons[i].x+scrollx
                o.custom[onum].y=o.weapons[i].y+scrolly
                --o.custom[onum].xs=math.random(-5,5)*.4
                --o.custom[onum].ys=-j*.2-2
                o.custom[onum].xs=0
                o.custom[onum].ys=0
                o.custom[onum].active=1
                o.custom[onum].outscreen=true
            end
        end
    end
end

--dereg={0xda69,0x8918,0x8147,0x883a,0x8a5f,0xd7ea,0x80ec,0xde7b,0xc5ad,0xc50b,0xcc77,0xd4f7,0xe38d}
--for i=1,#dereg do
--    memory.registerexec(dereg[i],1,nil)
--end


function romPatch()
    -- remove hp graphics
    rom.writebytes(0x21600+0x10, string.rep(string.char(0x00), 0x60))
    rom.writebytes(0x23600+0x10, string.rep(string.char(0x00), 0x60))
    rom.writebytes(0x25600+0x10, string.rep(string.char(0x00), 0x60))
    rom.writebytes(0x27600+0x10, string.rep(string.char(0x00), 0x60))
    rom.writebytes(0x29600+0x10, string.rep(string.char(0x00), 0x60))
    rom.writebytes(0x2a600+0x10, string.rep(string.char(0x00), 0x60))
    rom.writebytes(0x2c600+0x10, string.rep(string.char(0x00), 0x60))
    
    -- remove exp cap thing based on area
    rom.writebyte(0x1d518+0x10, 0xc9)
    rom.writebyte(0x1d519+0x10, 0x00)
    
    --increase level cap to 99
    rom.writebyte(0x1d53c+0x10, 0xc9)
    rom.writebyte(0x1d53d+0x10, 0x63)
    
    --don't increase hp for level up
    rom.writebyte(0x1d57f+0x10, 0xea)
    rom.writebyte(0x1d580+0x10, 0xea)

    -- Change golden dagger throw sfx
    rom.writebyte(0x1d90c+0x10, 0x11)
    
end

function hasRelic(n)
    return (relics.main == bit.bor(relics.main, 2^(n-1)))
end
function hasItem(n)
    return (o.player.items == bit.bor(o.player.items, 2^(n-1)))
end


emu.registerexit(function(x) emu.message("") end)
function spidey.update(inp,joy)
    lastinp=inp
    
    --map.data=memory.readbyterange(0x05b0,0x100)
    game.paused=(memory.readbyte(0x0026)==02)
    pausemenu=(memory.readbyte(0x0026)==01)
    subScreen.realCursorY = memory.readbyte(0x33)
    subScreen.cursorY = subScreen.cursorY or (subScreen.realCursorY+1)
    --cursorY = memory.readbyte(0x33)
    -- see callback above for mapmenu info
    if not game.paused then mapmenu = false end
    
    actionval=memory.readbyte(0x001c)
    actionval2=memory.readbyte(0x001a)
    action=(actionval==0x01 or (actionval==02 and actionval2==01) or (actionval==04 and actionval2==01))
    if action and memory.readbyte(0x002c)==0x02 then
        action = false
    end
    --action=(memory.readbyte(0x001c)==0x01) -- not perfect; sometimes it can be 02 or 04
    area1=memory.readbyte(0x0030)
    area2=memory.readbyte(0x0050)
    area3=memory.readbyte(0x0051) % 0x80 --adds 0x80 if starting on right side
    screenload=(memory.readbyte(0x0021)>01) --not perfect yet; goes off on some non-screen loads
    scrollx=memory.readbyte(0x0053)+memory.readbyte(0x0054)*0x100
    --scrolly=memory.readbyte(0x0056)+memory.readbyte(0x0057)*0x224
    scrolly=memory.readbyte(0x0056)+memory.readbyte(0x0057)*0xe0
    msgnum=memory.readbyte(0x007f)
    game.messageNum=msgnum
    msgstatus=memory.readbyte(0x007a) --04 = printing
    subScreen.enter = false
    subScreen.exit = false
    if pausemenu and joy[1].start_press and msgstatus == 04 then
        if msgstatus == 0 then subScreen.enter = true end
        if msgstatus == 4 then subScreen.exit = true end
    end
    lastmsgindex=msgindex or -1
    msgindex=memory.readbyte(0x007c)
    msgchar=memory.readbyte(0x0703) -- currently printing character
    lastmsgy=msgy or 0
    lastmsgx=msgx or 0
    msgy=memory.readbyte(0x0077)
    msgx=memory.readbyte(0x0078)
    weapons.current=memory.readbyte(0x0090)
    if cv2data.weapons[weapons.current] then
        weapons.currentname=cv2data.weapons[weapons.current].name
    end
    night=(memory.readbyte(0x0082)==0x01)
    borderColor = "#0070ec"
    if night then borderColor = "#24188c" end
    
    relics.main = memory.readbyte(0x0091)
    relics.current=memory.readbyte(0x004F)
    relics.currentname=relics.names[relics.current]
    relics.list = {}
    relics.list.rib = (relics.main == bit.bor(relics.main, 0x01))
    relics.list.heart = (relics.main == bit.bor(relics.main, 0x02))
    relics.list.eye = (relics.main == bit.bor(relics.main, 0x04))
    relics.list.nail = (relics.main == bit.bor(relics.main, 0x08))
    relics.list.ring = (relics.main == bit.bor(relics.main, 0x10))
    relics.nParts = 0
    for k,v in pairs(relics.list) do
        if v== true then relics.nParts = relics.nParts + 1 end
    end
    time=string.format('%02X:%02X',memory.readbyte(0x0086),memory.readbyte(0x0085))
    --timeWithDays =string.format("%02X:", memory.readbyte(0x0087), time)
    day = memory.readbyte(0x0083)
    game.night=(memory.readbyte(0x82)==0x01)
    hearts=string.format('%01X%02X',memory.readbyte(0x0049),memory.readbyte(0x0048))
    pattern1=memory.readbyte(0x0101)
    pattern2=memory.readbyte(0x0102)
    
    romPatch()
    
    if spidey.debug.enabled then gui.text(4,4+8*4,string.format('Pattern tables: %02X %02X',pattern1,pattern2)) end
    
    if quickmessages==true and action and messages[msgnum] and memory.readbyte(0x003f)~=0 then --if close to message
        quickMessagePopupWait = (quickMessagePopupWait or 0) + 1
        if quickMessagePopupWait >=40 then
            --gui.text(20,20,messages[msgnum])
            local x=0
            local y=32
            gui.drawbox(x+28-8, y+28+1-8,x+ 24+8*13+8, y+24+8*08+8, "black", "black")
            gui.drawbox(x+28-4, y+28-4, x+24+8*13+4,y+ 24+8*08+4+1, "black", "#0070EC")
            gui.drawbox(x+28-4-1, y+28-4+1, x+24+8*13+4+1, y+24+8*08+4+1-1, "clear", "#0070EC")
            drawfont(x+28,y+28,font[current_font], messages[msgnum])
        end
    else
        quickMessagePopupWait = 0
    end

    if msgstatus==08 then
        msg=''
    elseif msgstatus==04 then
        --emu.message(string.format("%02x",game.messageNum))
        if msgy~=lastmsgy and msgindex~=0 then
        msg=msg..'\n'
        end

        if msgy~=lastmsgy then
        else
            if msgindex~=lastmsgindex then
                fontstr=" ABCDEFGHIJKLMNOPQRSTUVWXYZ.'v,                       0123456789!     -         !            ?    ETL            :"
                msg=msg..fontstr:sub(msgchar+1,msgchar+1)
            else
            end
        end
        
        --[[
        if messages[msgnum] then
            gui.text(20,20,messages[msgnum])
        else
            gui.text(20,20,msg)
        end
        ]]--
        
        --drawfont(96,112,font[current_font], msg)
    elseif msgstatus==0x07 then
        messages[msgnum]=msg
        --emu.message(msg)
    end
    
    --if memory.readbyte(0x0056)==224 then
    --gui.text(20,20, "*******************"); -- force clear of previous text
    --end
    
    --gui.drawbox(0, 0, 256, 240, "black", "black")
    if action or pausemenu then
        o.player.hp=memory.readbyte(0x0080)
        o.player.maxHp=memory.readbyte(0x0081)
        --memory.writebyte(0x008b, 0x63) -- level 99
        o.player.level=memory.readbyte(0x008b)
        o.player.lives=memory.readbyte(0x0031)
        o.player.laurels = memory.readbyte(0x004c)
        o.player.garlic = memory.readbyte(0x004d)
        o.player.hearts = tonumber(string.format('%01X%02X',memory.readbyte(0x0049),memory.readbyte(0x0048)))
        
        if o.player.hearts > o.player.maxHearts then
            o.player.hearts = o.player.maxHearts
            memory.writebyte(0x48, tonumber(string.format("%02d",o.player.hearts % 100),16))
            memory.writebyte(0x49, tonumber(string.format("%02d",(o.player.hearts-(o.player.hearts % 100))/100),16))
        end
        
        o.player.whip = memory.readbyte(0x0434)
        o.player.items = memory.readbyte(0x004a)+memory.readbyte(0x0092)*0x100
        
        o.player.hasbag=hasItem(7)
        o.player.hascross=hasItem(8)
        
        
        -- new hp formula
        o.player.maxHp=0x30+1*o.player.level+4*relics.nParts
        memory.writebyte(0x0081, o.player.maxHp)
        
        o.player.exp = math.min(9999, tonumber(string.format("%02x%02x", memory.readbyte(0x47), memory.readbyte(0x46))))
        o.player.expNext = getExpNeeded()
        
        getExtraData()
    end
    if action then
        --[[
        for i=0,0x1FFF-1 do
            --memory.writebyte(0x2001,0x00) -- Turn off rendering
            memory.writebyte(0x2006,math.floor(i/0x100)) -- PPUADDR high byte
            memory.writebyte(0x2006,i % 0x100) -- PPUADDR low byte
            memory.writebyte(0x2007,0x00) -- PPUDATA
            --memory.writebyte(0x2001,0x1e) -- Turn on rendering
        end
        ]]--
        --gui.drawbox(0, 0, 256, 32, "black", "black")
--        o.player.hp=memory.readbyte(0x0080)
--        o.player.maxHp=memory.readbyte(0x0081)
--        o.player.level=memory.readbyte(0x008b)
--        o.player.lives=memory.readbyte(0x0031)
--        o.player.laurels = memory.readbyte(0x004c)
--        o.player.garlic = memory.readbyte(0x004d)


        o.player.inBossRoom = false
        if spidey.debug.enabled then
            drawfont(0,5+8*5,font[current_font],string.format('HP: %02X %02X',o.player.hp or 0,o.player.maxHp or 0) )
            drawfont(0,5+8*6,font[current_font],string.format('Relics: %02X',relics.nParts) )
        end
        
--         new hp formula
--        o.player.maxHp=0x30+1*o.player.level+4*relics.nParts
--        memory.writebyte(0x0081, o.player.maxHp)
    end
    
    gui.text(0,0, ""); -- force clear of previous text
    
    -- Hide graphics for HP
    if action or pausemenu then
        memory.writebyte(0x0203,0xff)
        memory.writebyte(0x0207,0xff)
        memory.writebyte(0x020b,0xff)
    end
    --if action or pausemenu then
    
    
    if subScreen.enter then enterSubScreen() end
    if subScreen.exit then exitSubScreen() end
    if pausemenu then
        if not subScreen.cursorX then enterSubScreen() end
        if joy[1].up_press then
            subScreen.cursorY = subScreen.cursorY - 1
        end
        if joy[1].down_press then
            subScreen.cursorY = subScreen.cursorY + 1
        end
        if joy[1].left_press then
            subScreen.cursorX = subScreen.cursorX - 1
        end
        if joy[1].right_press then
            subScreen.cursorX = subScreen.cursorX + 1
        end
        if joy[1].B_press then
            if subScreen.cursorY == 1 then subScreen.relic = subScreen.cursorX end
            if subScreen.cursorY == 2 then subScreen.weapon = subScreen.cursorX end
            if subScreen.cursorY == 0 and subScreen.cursorX == 1 then
                o.player.whip = o.player.whip + 1
                if o.player.whip > 4 then o.player.whip = 0 end
                memory.writebyte(0x0434, o.player.whip)
            end
        end
        if subScreen.cursorY == 0 and subScreen.cursorX > 1 then subScreen.cursorX = 1 end
        if subScreen.cursorY == 1 and subScreen.cursorX > 6 then subScreen.cursorX = 6 end
        if subScreen.cursorY == 2 and subScreen.cursorX > 10 then subScreen.cursorX = 10 end
        if subScreen.cursorX < 1 then subScreen.cursorX = 1 end
    end
    
    if (font_selector) then
        if (joy[1].left and joy[1].select_press) then
            current_font=(current_font-1)
            if current_font<1 then current_font=1 end
            emu.message(string.format('Font number: %s',current_font))
        end
        if (joy[1].right and joy[1].select_press) then
            current_font=(current_font+1)
            if current_font>10 then current_font=1 end
            emu.message(string.format('Font number: %s',current_font))
        end
    end
    
    if (action and skeleton) then
        memory.writebyte(0x040e,0x05)
        whipframe=memory.readbyte(0x0445)
        whipframe=04
        memory.writebyte(0x0445,whipframe)
    end
    
    if joy[1].down_press then
--        memory.writebyte(0x00b4,0x01)
--        memory.writebyte(0x00b5,0x01)
--        memory.writebyte(0x0169,0x60)
--        memory.writebyte(0x016a,0xff)
--        memory.writebyte(0x016b,0x03)
        
--        memory.writebyte(0x0113,0x80)
--        memory.writebyte(0x0122,0x80)
        
        --memory.writebyte(0x00e5,0x1f)
        --memory.writebyte(0x00b4,0x1f)
    end
    
    if (action and bat) then
        memory.writebyte(0x0445,0x05) --disable whip
        
        simon_frame=memory.readbyte(0x0300)
        if emu.framecount() % 20<10 then
            simon_frame=0xc8
        else
            simon_frame=0xc9
        end
        memory.writebyte(0x0300,simon_frame)
        
        memory.writebyte(0x037e,0x00) --no downward gravity
        
        memory.writebyte(0x036c,0x00)
        if joy[1].up then
            memory.writebyte(0x036c,0xfe)
        end
        if joy[1].down then
            memory.writebyte(0x036c,0x02)
        end

        memory.writebyte(0x006d,0x00)
        if joy[1].left then
            memory.writebyte(0x006c,0x00)
            memory.writebyte(0x006d,0xfe)
            memory.writebyte(0x0420,00) --face left
        end
        if joy[1].right then
            memory.writebyte(0x006c,0x00)
            memory.writebyte(0x006d,0x02)
            memory.writebyte(0x0420,01) --face right
        end
        
    end
    
    --destroy custom objects if going between screens
    if screenload then o.custom.destroyall() end
    
    
    if screenload then o.custom.createCandles() end
    
    
    if (action) then
        o.player.x=memory.readbyte(0x0348)
        o.player.y=memory.readbyte(0x0324)
        o.player.inv=memory.readbyte(0x04f8)
        o.player.frame = memory.readbyte(0x0300)
        
        -- Check if the player is in the in air hurt frame.  If so, reset 
        -- the invincible counter.  This way, you doesn't start flashing until
        -- you hit the ground.
        if o.player.inv > 0 and o.player.frame == 0x73 then
            o.player.inv=0x40
            memory.writebyte(0x04f8, o.player.inv)
        end
        
        -- Make player flash when hurt.
        if (o.player.inv > 0 and o.player.frame~=0x73 and o.player.frame~=0x74) and o.player.inv % 4 < 1 then
            --memory.writebyte(0x0300,0) --simon frame
            memory.writebyte(0x03c6,0x04) -- render player off
        else
            memory.writebyte(0x03c6,0x00) -- render player on
        end
        
        o.player.facing=memory.readbyte(0x0420)
        stuff=memory.readbyte(0x004a)
        o.player.hasgoldendagger=(stuff==bit.bor(stuff, 2^2))
        stuff=memory.readbyte(0x0092)
        --o.player.hascross=(stuff==bit.bor(stuff, 2^1))

        for i=0,1 do
            o.whip[i].type=memory.readbyte(0x03b5+i)
            o.whip[i].frame=memory.readbyte(0x0301+i)
            o.whip[i].x=memory.readbyte(0x0349+i)
            o.whip[i].y=memory.readbyte(0x0325+i)
            o.whip[i].ys=memory.readbyte(0x036d+i)
            o.whip[i].xs=memory.readbyte(0x0391+i)
            o.whip[i].hp=memory.readbyte(0x04c3+i)
            if o.whip[i].type ~=0 then
                if spidey.debug.enabled then gui.text(o.whip[i].x,o.whip[i].y, string.format("%u %02X\n(%3u,%3u) %2i %2i",i,o.whip[i].type,o.whip[i].x,o.whip[i].y,signed8bit(o.whip[i].xs),signed8bit(o.whip[i].ys)),"blue",'white') end
            end
        end
        
        for i=0,2 do
            o.weapons[i].type=memory.readbyte(0x03b7+i)
            o.weapons[i].frame=memory.readbyte(0x0303+i)
            o.weapons[i].x=memory.readbyte(0x0348+3+i)
            o.weapons[i].y=memory.readbyte(0x0324+3+i)
            o.weapons[i].ys=memory.readbyte(0x036c+3+i)
            o.weapons[i].xs=memory.readbyte(0x0396-3+i)
            o.weapons[i].hp=memory.readbyte(0x04c8-3+i)
            if o.weapons[i].type==0 then
                o.weapons[i].alivetime=0
            else
                o.weapons[i].alivetime=(o.weapons[i].alivetime or 0)+1
            end
            --o.weapons[i].hp=0x01
            
            if false and o.weapons[i].type==0x01 then
                o.weapons[i].type=0
                o.weapons[i].frame=0
                memory.writebyte(0x03ba-3+i,o.weapons[i].type)
                memory.writebyte(0x0303+i,o.weapons[i].frame)
                boomerangobj=getunusedcustom()
                if (boomerangobj) then
                    --o.custom[boomerangobj].type="fireball"
                    o.custom[boomerangobj].type="bansheeboomerang"
                    o.custom[boomerangobj].rebound=false
                    o.custom[boomerangobj].x=o.weapons[i].x+scrollx
                    o.custom[boomerangobj].y=o.weapons[i].y+scrolly
                    o.custom[boomerangobj].facing=o.player.facing
                    if o.custom[boomerangobj].facing==1 then 
                        o.custom[boomerangobj].xs=1.5 
                    else 
                        o.custom[boomerangobj].xs=-1.5 
                    end
                    o.custom[boomerangobj].ys=0
                    o.custom[boomerangobj].active=1
                end
            end
            
            memory.writebyte(0x04c8-3+i,o.weapons[i].hp)
            if o.weapons[i].type ~=0 then
                --gui.text(8,8+8*i, string.format("%02X (%3u, %3u) %2u",o[i].type,o[i].x,o[i].y,o[i].hp))
                --if debug then gui.text(o[i].x,o[i].y, string.format("%u %02X %2u\n(%3u,%3u) %2i %2i",i,o[i].type,o[i].hp,o[i].x,o[i].y,signed8bit(o[i].xs),signed8bit(o[i].ys))) end
                if spidey.debug.enabled then gui.text(o.weapons[i].x,o.weapons[i].y, string.format("%u %02X\n(%3u,%3u) %2i %2i",i,o.weapons[i].type,o.weapons[i].x,o.weapons[i].y,signed8bit(o[i].xs),signed8bit(o[i].ys)),"red") end
            end
            if o.weapons[i].type==0x04 then --holy water
                o.weapons[i].frame=0
                memory.writebyte(0x0303+i,o.weapons[i].frame)
                -- Replace old holy water sprite with blue bottle.
                gui.gdoverlay(o.weapons[i].x-8, o.weapons[i].y-9, gfx.holywater.test)
            elseif o.weapons[i].type==0x05 then --diamond
                o.weapons[i].frame=0
                memory.writebyte(0x0303+i,o.weapons[i].frame)
                drawfont(o.weapons[i].x, o.weapons[i].y,font[4], ".")
                --gui.line(o.weapons[i].x, o.weapons[i].y, o.weapons[i].x+1, o.weapons[i].y+1)
                createDiamondTrail(o.weapons[i].x, o.weapons[i].y)
            elseif o.weapons[i].type==0x09 then --garlic
                -- make disappear after a while
                if o.weapons[i].alivetime>400 then
                    o.weapons[i].type = 0
                    o.weapons[i].frame = 0
                    memory.writebyte(0x03b7+i, o.weapons[i].type)
                    memory.writebyte(0x0303+i, o.weapons[i].frame)
                end
            end
        end
        
        for i=0,o.count-1 do
            o[i] = {}
            o[i].type=memory.readbyte(0x03ba+i)
            o[i].frame=memory.readbyte(0x0306+i)
            o[i].x=memory.readbyte(0x0348+6+i)
            o[i].y=memory.readbyte(0x0324+6+i)
            o[i].ys=memory.readbyte(0x036c+6+i)
            o[i].xs=memory.readbyte(0x0396+i)
            o[i].team=memory.readbyte(0x03de+i) --00=uninitialized 01=enemy 40=friendly+talks 80=friendly 08=move with player
            o[i].facing=memory.readbyte(0x0420+6+i)
            o[i].stun=memory.readbyte(0x04fe+i)
            o[i].state=memory.readbyte(0x044a+i) --sometimes it's counter
            o[i].state2=memory.readbyte(0x046e+i)
            o[i].statecounter=memory.readbyte(0x04b6+i) --used with drac, carmilla, others?
            o[i].xdist=math.abs(o.player.x-o[i].x)
            o[i].ydist=math.abs(o.player.y-o[i].y)
            o[i].facingplayer=((o[i].x<o.player.x and o[i].facing==1) or (o[i].x>o.player.x and o[i].facing==0))
            o[i].hp=memory.readbyte(0x04c8+i) --note: if hp==0, it can't be hit
            if o[i].type ~=0 and o[i].hp>0 then
                --gui.text(8,8+8*i, string.format("%02X (%3u, %3u) %2u",o[i].type,o[i].x,o[i].y,o[i].hp))
                if spidey.debug.enabled then gui.text(o[i].x,o[i].y, string.format("%u %02X %2u\n(%3u,%3u) %2i %2i",i,o[i].type,o[i].hp,o[i].x+scrollx,o[i].y+scrolly,signed8bit(o[i].xs),signed8bit(o[i].ys))) end
                if spidey.debug.enabled then
                    if game.data and game.data.enemies and game.data.enemies[o[i].type] and game.data.enemies[o[i].type].damage then
                        local dnum=1
                        if game.night then dnum=2 end
                        gui.text(o[i].x,o[i].y+8*2, string.format("damage: %u",game.data.enemies[o[i].type].damage[dnum] or 0))
                    end
                end
            end
            
            if o[i].type==0x30 then
                o[i].hp=1 --give fireballs hp so they can be killed
                memory.writebyte(0x04c8+i,o[i].hp)
            end
            
            
            -- ferryman doesn't bounce off docks (needs work)
            if o[i].type == 0x3c then
                --gui.text(50,50, string.format("state: %02X %02X %02X",o[i].state,o[i].state2,o[i].statecounter))
                if o[i].x+scrollx==270 and o[i].facing==0 then
                    o[i].state=0x01; memory.writebyte(0x044a+i,o[i].state)
                    memory.writebyte(0x0396+i,0) --xs
                    memory.writebyte(0x0372+i,0) --ys
                end
                if o[i].x+scrollx==241 and o[i].facing==1 then
                    o[i].state=0x01; memory.writebyte(0x044a+i,o[i].state)
                    memory.writebyte(0x0396+i,0) --xs
                    memory.writebyte(0x0372+i,0) --ys
                end
            end
            
            
            -- custom heart object
            if false then
            --if o[i].type==0x37 and o[i].team~=01 and o[i].hp~=99 then
                o[i].type=0x00
                memory.writebyte(0x03ba+i,o[i].type)
                o[i].frame=0x00
                memory.writebyte(0x0306+i, o[i].frame)
                heartobj=getunusedcustom()
                if (heartobj) then
                    o.custom[heartobj].type="heart"
                    o.custom[heartobj].x=o[i].x+scrollx
                    o.custom[heartobj].y=o[i].y+scrolly
                    o.custom[heartobj].facing=o.player.facing
                    o.custom[heartobj].xs=0
                    o.custom[heartobj].ys=0
                    o.custom[heartobj].active=1
                end
            end
        end
    
    --do extra enemy stuff
    for i=0,o.count-1 do
        if o[i].type==0x03 and o[i].stun==0 and o[i].xdist < 40 and o[i].xdist > 16 and o[i].ydist<10 and o[i].facingplayer==false and (emu.framecount() % 48) then
            --skeletons turn to face player sometimes
            o[i].facing=1-o[i].facing; memory.writebyte(0x0420+6+i,o[i].facing)
            o[i].xs=255-o[i].xs; memory.writebyte(0x0396+i,o[i].xs)
            --gui.text(o[i].x,o[i].y-8, "*")
        end
        
        if o[i].type==0x30 then -- Fireballs
            if signed8bit(o[i].xs) >= 0 then
                if o[i].facing==0 then o[i].facing=1; memory.writebyte(0x0420+6+i, o[i].facing) end
            else
                if o[i].facing==1 then o[i].facing=0; memory.writebyte(0x0420+6+i, o[i].facing) end
            end
        end
        if o[i].type==0x32 then --Fire guy fireballs: 
            -- Fix it so they face the proper direction
            if o[i].xs ==bit.bor(o[i].xs, 2^7) then
                if o[i].facing==1 then o[i].facing=0; memory.writebyte(0x0420+6+i, o[i].facing) end
            else
                if o[i].facing==0 then o[i].facing=1; memory.writebyte(0x0420+6+i, o[i].facing) end
            end
            o[i].hp=1 --give fireballs hp so they can be killed
            memory.writebyte(0x04c8+i,o[i].hp)
        end
        
        if o[i].type==0x08 then --floating eyes
                o[i].skullc = ((o[i].skullc or 0) +1) % 1000
                o[i].y=o[i].y+math.cos(o[i].skullc *.04)*2
                o[i].x=o[i].x+math.sin(o[i].skullc *.01)*2
                memory.writebyte(0x0348+6+i,o[i].x)
                memory.writebyte(0x0324+6+i,o[i].y)
        end
        
        if o[i].type==0x0a then --medusa heads
                --needs work but at least they're wavy
--                emu.message(string.format("%02x",o[i].statecounter))
--                emu.pause()
                o[i].skullc = ((o[i].skullc or 0) +1) % 10000
                o[i].y=o[i].y+math.sin(o[i].skullc *.06)*2
                memory.writebyte(0x0324+6+i,o[i].y)
                
--                o[i].x = o[i].lastX or o[i].x
--                memory.writebyte(0x034e+i, o[i].x)
                

--                o[i].x = o[i].x + 1
                
                
--                o[i].xs=2
--                memory.writebyte(0x0396+i, o[i].xs)
                
--                o[i].xs=2
--                o[i].xs=o[i].lastXs or o[i].xs
--                memory.writebyte(0x0396+i, o[i].xs)
--                o[i].lastXs = o[i].xs
                
--                o[i].xs=memory.readbyte(0x0396+i)
--                o[i].team=memory.readbyte(0x03de+i) --00=uninitialized 01=enemy 40=friendly+talks 80=friendly 08=move with player
                
                o[i].facing=o[i].lastFacing or o[i].facing
                memory.writebyte(0x0420+6+i, o[i].facing)
                
                o[i].lastFacing=o[i].facing
                o[i].lastX = o[i].x
                
                
        end
        
        if o[i].type==0x10 then --skulls
                o[i].skullc = ((o[i].skullc or 0) +1) % 1000
                o[i].y=o[i].y+math.sin(o[i].skullc *.1)*2
                memory.writebyte(0x0324+6+i,o[i].y)
        end
        
        if o[i].type==0x38 then --hands
            --gui.text(8,8*2, string.format("%02x %02X %02X",i,o[i].state,o[i].state2,o[i].statecounter))
            if o[i].xdist>64 then o[i].frame=0 end
            --[[
            if o[i].xdist>64 then 
                o[i].frame=0x8e
                --o[i].y=180
                --o[i].state=1
                --o[i].state2=0
            end
            ]]--
            --memory.writebyte(0x0324+6+i,o[i].y)
            memory.writebyte(0x044a+i,o[i].state)
            memory.writebyte(0x046e+i,o[i].state2)
            memory.writebyte(0x0306+i,o[i].frame)
        end
        
        if o[i].type==0x39 then --ghosts
            o[i].skullc = ((o[i].skullc or 0) +1) % 1000
            o[i].y=o[i].y+math.cos(o[i].skullc *.05)*1
            o[i].frame=0x20 + (math.floor(o[i].skullc / 6) % 2)
            if (emu.framecount() % 4==0) then o[i].frame=0 end
            memory.writebyte(0x0324+6+i,o[i].y)
            memory.writebyte(0x0306+i,o[i].frame)
        end
        
        if o[i].type==0x44 then --Death
            o.boss.maxHp = 128
            if o.player.hasgoldendagger and not refight_bosses then
                --Only fight boss once
                o[i].type=0
                o[i].frame=0
            end
                o[i].skullc = ((o[i].skullc or 0) +1) % 1000
                o[i].y=o[i].y+math.cos(o[i].skullc *.03)*2
                o[i].x=o[i].x+math.sin(o[i].skullc *.01)*1
                o[i].y=o[i].y+math.cos(emu.framecount()*.09)*1
                o[i].x=o[i].x+math.sin(emu.framecount()*.09)*1
                n=40
                if o[i].x<0+n then o[i].x=0+n end
                if o[i].x>255-n then o[i].x=255-n end
                if o[i].y<0+n then o[i].y=0+n end
                if o[i].y>255-n then o[i].y=255-n end
                memory.writebyte(0x0348+6+i,o[i].x)
                memory.writebyte(0x0324+6+i,o[i].y)
                
                o.player.bossdoor()
                memory.writebyte(0x03ba+i,o[i].type)
                memory.writebyte(0x0306+i,o[i].frame)
        end
        
        if o[i].type==0x48 and false then --drac weapon
            o[i].frame=0x29
            o[i].type=0x30
            --29 fireball
            --ad knife
            --a8 holy fire
            --d3-d6 big flame (drac spawn)
            --e9-ec big flame (drac death)
            memory.writebyte(0x03ba+i,o[i].type)
            memory.writebyte(0x0306+i,o[i].frame)
        end
        
        if o[i].type==0x49 then -- magic cross item
            if o.player.hascross then
                o[i].type=0
                o[i].frame=0
                memory.writebyte(0x03ba+i,o[i].type)
                memory.writebyte(0x0306+i,o[i].frame)
            end
        end
        
        
        if o[i].type==0x25 then -- dracula part relic
            if area1==1 and area2==6 and area3==03 then -- Laruba
                if hasRelic(5) then -- ring
                    o[i].type=0
                    o[i].frame=0
                    memory.writebyte(0x03ba+i,o[i].type)
                    memory.writebyte(0x0306+i,o[i].frame)
                end
            end
        end
        
        if o[i].type==0x42 then --Carmilla (mask boss)
            o.boss.maxHp=240
            if o.player.hascross and not refight_bosses then
                --Only fight boss once
                o[i].destroy = true
            end
            
            --gui.text(8,8*2, string.format("%02x %02X %02X",i,o[i].state,o[i].state2,o[i].statecounter))
            
            o[i].skullc = ((o[i].skullc or 0) +1) % 1000
            --o[i].y=o[i].y+math.cos(o[i].skullc *.03)*2
            o[i].x=o[i].x+math.sin(o[i].skullc *.01)*1
            --o[i].y=o[i].y+math.cos(emu.framecount()*.04)*1
            o[i].x=o[i].x+math.sin(emu.framecount()*.04)*2
            n=40
            if o[i].x<0+n then o[i].x=0+n end
            if o[i].x>255-n then o[i].x=255-n end
            if o[i].y<0+n then o[i].y=0+n end
            if o[i].y>255-n then o[i].y=255-n end
            
            memory.writebyte(0x0348+6+i,o[i].x)
            memory.writebyte(0x0324+6+i,o[i].y)
            
            o.player.bossdoor()

            memory.writebyte(0x03ba+i,o[i].type)
            memory.writebyte(0x04fe+i,o[i].stun)
            memory.writebyte(0x0348+6+i,o[i].x)
            memory.writebyte(0x0324+6+i,o[i].y)
            memory.writebyte(0x044a+i,o[i].state)
            memory.writebyte(0x046e+i,o[i].state2)
            memory.writebyte(0x04b6+i,o[i].statecounter)
            memory.writebyte(0x0306+i,o[i].frame)
            memory.writebyte(0x03de+i,o[i].team)
        end
        
        if o[i].type==0x47 then -- Dracula
            o.player.inBossRoom=true
            o.boss.maxHp=240
            --gui.text(o[i].x,o[i].y, string.format("%u %02X %2u\n(%3u,%3u) %2i %2i",i,o[i].type,o[i].hp,o[i].x,o[i].y,signed8bit(o[i].xs),signed8bit(o[i].ys)))
            o[i].move=o[i].move or ''
            o[i].movec=o[i].movec or 0
            if emu.framecount() % 4==0 then o[i].movec=o[i].movec+1 end
            o[i].movename=''
            o[i].state2=0xff
            o[i].draccount=memory.readbyte(0x04b6)
            if o[i].frame==0x34 and not joy[2].B and not joy[2].idle then o[i].frame=0x33 end
            dracsp=2
            if joy[2].left then o[i].x=o[i].x-dracsp end
            if joy[2].right then o[i].x=o[i].x+dracsp end
            if joy[2].up then o[i].y=o[i].y-dracsp end
            if joy[2].down then o[i].y=o[i].y+dracsp end
            if joy[2].B_press and o[i].move=='' then
                --o[i].frame=0x34
                --o[i].state2=0x11
                o[i].move='shoot'
                o[i].movec=0
            end
            
            --[[
            if joy[2].A then
                n=joy[2].A_press_time
                --o[i].x=math.random(0,256)
                o[i].y=o[i].y+math.sin(n *.05)*3
                --o[i].x=o[i].x+math.cos(emu.framecount() *.15)
                o[i].movename='hover'
            end
            ]]--
            if joy[2].select then
                o[i].stun=0x08
                o[i].x=40+87*math.random(0,2)
                o[i].movename='warp'
            end
            
            if o[i].move=='' and not o[i].moveindex==false then
                o[i].moveindex=(o[i].moveindex+1) % #o[i].movequeue
                o[i].move=o[i].movequeue[o[i].moveindex]
                o[i].movec=0
                if o[i].move=='sway' then
                    o[i].x=128
                    o[i].y=64
                    swaycount=0
                end
            end
            
            if joy[2].A_press and o[i].move=='' then
                --n=joy[2].A_press_time
                --o[i].stun=0x08
                --o[i].y=o[i].y+math.sin(n*.1)*1
                --o[i].x=o[i].x+math.cos(n*.05)*3
                --o[i].frame=0
                --o[i].movename='sway'
                o[i].x=128
                o[i].y=64
                o[i].move='sway'
                o[i].movec=0
                swaycount=0
            end

            if joy[2].start_press and o[i].move=='' then
                o[i].movequeue={'warp2','warp2','warp2','warp2','warp2','warp2','warp2','warp2','warp2','warp2'}
                o[i].moveindex=1
            end
            
            if o[i].draccount==1 and o[i].move=='' then
                --o[i].movequeue={'warp2','warp2','warp2','warp2','warp'}
                o[i].movequeue={'warp','warp','shoot','warp','warp','shoot','warp','shoot','warp','shoot','warp','warp','shoot','shoot','shoot','shoot','warp2','warp2','warp2','sway','warp2','warp2','warp2'}
                o[i].moveindex=1
            end
            
            if o[i].move=='shoot' then
                if o[i].movec==1 then
                    --pass
                elseif o[i].movec==2 then
                    o[i].frame=0x34
                elseif o[i].movec==4 then
                    o[i].state2=0x11
                    o[i].movec=o[i].movec+1
                elseif o[i].movec==7 then
                    --o[i].frame=0x33
                elseif o[i].movec==8 then
                    o[i].move=''
                end
            end
            
            if o[i].move=='warp' then
                o[i].frame=0x33
                o[i].stun=0x08
                o[i].x=40+87*math.random(0,2)
                o[i].y=64
                if o[i].movec==1 then
                    --pass
                elseif o[i].movec==20 then
                    o[i].move=''
                end
            end
            
            if o[i].move=='sway' and emu.framecount() % 9==0 then
                onum=getunusedcustom()
                if (onum) then
                    o.custom[onum].type="fireball"
                    o.custom[onum].x=o[i].x+scrollx
                    o.custom[onum].y=o[i].y+scrolly
                    o.custom[onum].xs=math.random(-5,5)*.4
                    o.custom[onum].ys=math.random(-5,5)*.2-2
                    o.custom[onum].active=1
                end
            end
            
            if o[i].move=='sway' then
                o[i].stun=0x10
                o[i].team=0x80
                n=swaycount
                o[i].y=o[i].y+math.sin(n*.1)*1
                o[i].x=o[i].x+math.cos(n*.2)*16
                if o[i].movec==1 then
                    --pass
                elseif o[i].movec==200 then
                    o[i].stun=0
                    o[i].team=1
                    o[i].move=''
                end
                swaycount=swaycount+1
            end
            
            if o[i].move=='warp2' then
                if o[i].movec==1 then
                    o[i].team=0x80
                    o[i].frame=0xe9
                    o[i].stun=0xff
                elseif o[i].movec==2 then
                    o[i].frame=0xea
                elseif o[i].movec==4 then
                    o[i].frame=0xeb
                elseif o[i].movec==5 then
                    o[i].frame=0xec
                elseif o[i].movec==6 then
                    o[i].frame=0
                    o[i].y=170
                elseif o[i].movec==7 then
                    --o[i].x=40+87*math.random(0,2)
                    o[i].x=40+22*math.random(0,8)
                elseif o[i].movec==30 then
                    o[i].frame=0xec
                elseif o[i].movec==31 then
                    o[i].frame=0xeb
                    o[i].stun=0xff
                elseif o[i].movec==32 then
                    o[i].frame=0xea
                elseif o[i].movec==33 then
                    o[i].frame=0xe9
                elseif o[i].movec==34 then
                    o[i].frame=0x33
                elseif o[i].movec==43 then
                    o[i].stun=0x00
                    o[i].team=1
                elseif o[i].movec==53 then
                    onum=getunusedcustom()
                    spx=-2.4
                    if o.player.x < o[i].x+scrollx then spx=-spx; facing=0 else facing=1 end
                    if (onum) then
                        o.custom[onum].type="dracfire"
                        o.custom[onum].x=o[i].x+scrollx
                        o.custom[onum].y=o[i].y+scrolly-8-4
                        o.custom[onum].xs=spx
                        o.custom[onum].ys=-.39
                        o.custom[onum].facing=facing
                        o.custom[onum].active=1
                    end
                    onum=getunusedcustom()
                    if (onum) then
                        o.custom[onum].type="dracfire"
                        o.custom[onum].x=o[i].x+scrollx
                        o.custom[onum].y=o[i].y+scrolly-8
                        o.custom[onum].xs=spx
                        o.custom[onum].ys=0
                        o.custom[onum].facing=facing
                        o.custom[onum].active=1
                    end
                    onum=getunusedcustom()
                    if (onum) then
                        o.custom[onum].type="dracfire"
                        o.custom[onum].x=o[i].x+scrollx
                        o.custom[onum].y=o[i].y+scrolly-8+4
                        o.custom[onum].xs=spx
                        o.custom[onum].ys=.39
                        o.custom[onum].facing=facing
                        o.custom[onum].active=1
                    end
                    o[i].movec=o[i].movec+1
                elseif o[i].movec==63 then
                    o[i].stun=0
                    o[i].team=1
                    o[i].move=''
                end
                
            end
            
            memory.writebyte(0x04fe+i,o[i].stun)
            memory.writebyte(0x0348+6+i,o[i].x)
            memory.writebyte(0x0324+6+i,o[i].y)
            memory.writebyte(0x046e+i,o[i].state2)
            memory.writebyte(0x0306+i,o[i].frame)
            memory.writebyte(0x03de+i,o[i].team)
            --[[
            if o[i].stun>1 then
                o[i].stun=0
                o[i].y=o[i].y-4
                o[i].x=128+math.random(-32,32)
                memory.writebyte(0x04fe+i,o[i].stun)
                memory.writebyte(0x0348+6+i,o[i].x)
                memory.writebyte(0x0324+6+i,o[i].y)
            end
            ]]--
            if o[i].movename~='' then emu.message(o[i].movename) end
        end
        
        if o[i].destroy then
            o[i].type=0
            o[i].frame=0
            o[i].hp = 0
            memory.writebyte(0x03ba+i,o[i].type)
            memory.writebyte(0x0306+i,o[i].frame)
            memory.writebyte(0x04c8+i, o[i].hp)
        end
    end
    
    if inp.leftbutton_press then
        i=getunusedcustom()
        i=false --DISABLE
        if (i) then
            --o.custom[i].type="fireball"
            o.custom[i].type="bansheeboomerang"
            o.custom[i].rebound=false
            o.custom[i].x=inp.xmouse+scrollx
            o.custom[i].y=inp.ymouse+scrolly
            --o.custom[i].xs=math.random(-5,5)*.1
            o.custom[i].xs=1
            --o.custom[i].ys=math.random(-5,5)*.1-2
            o.custom[i].ys=0
            o.custom[i].active=1
        end
    end

--[[
    if inp.leftbutton_press then
        e=getenemydata(6)
        emu.message("get")
    end
    if inp.middlebutton_press then
        setenemydata(6+getunused(),e)
        emu.message("set")
    end
]]--
    
    if inp.leftbutton_press and false then
            i=0
            simon_x= memory.readbyte(0x0348)
            simon_y= memory.readbyte(0x0324)
            memory.writebyte(0x03b7+3,0x34) --21 22 34
            memory.writebyte(0x034b+3,simon_x)
            memory.writebyte(0x0327+3,simon_y)
            memory.writebyte(0x03ed+3,0x01) --helps to init it; frame?
            memory.writebyte(0x0393+3,0x00) --x speed
            memory.writebyte(0x03ba,52) --x speed 2?
            --memory.writebyte(0x044a,0x18) --make fire disappear faster
            
            memory.writebyte(0x01da,0xFE) --platform moves?
            memory.writebyte(0x033e,0x80) --platform moves?
            memory.writebyte(0x0384,0xf0) --platform moves?
            memory.writebyte(0x0386,0x80) --platform moves?
            memory.writebyte(0x03f7,0x09) --platform moves?
            memory.writebyte(0x0417,0x20) --platform moves?
            memory.writebyte(0x0438,0x04) --platform moves?
            memory.writebyte(0x04c8,0x20) --platform moves?
            o[i].frame=0x43
            memory.writebyte(0x0306+i,o[i].frame)
        --[[
        i=getunused()
        if (i) then
            --o.custom[i].type="fireball"
            o[i].type=0x22
            --o.custom[i].x=inp.xmouse+scrollx
            --o.custom[i].y=inp.ymouse+scrolly
            o[i].x=inp.xmouse
            o[i].y=inp.ymouse
        end
        ]]--
    end
    
--    o.player.gold = 9999
--    memory.writeword(0x7000+1, o.player.gold)
    
    if cheats.active and cheats.battest and inp.leftbutton_press then
        i=getunusedcustom()
        if (i) then
            o.custom[i].type="bigbat"
            o.custom[i].x=inp.xmouse+scrollx
            o.custom[i].y=inp.ymouse+scrolly
            o.custom[i].xs=0
            o.custom[i].ys=0
            o.custom[i].active=1
        end
    end
    
    --if spidey.debug.enabled and inp.leftbutton_press then
    --if true then
    if spidey.debug.enabled then
--        spidey.debug.enabled=true
--        cheats.active=true
        local x,y
--        x=math.floor((inp.xmouse+(scrollx % 16))/16)*16
--        y=math.floor((inp.ymouse+(scrolly % 16))/16)*16
        x=math.floor((inp.xmouse+scrollx % 16)/16)*16
        y=math.floor((inp.ymouse+scrolly % 16+3)/16)*16-3
        
        x=math.floor((inp.xmouse+0)/16)*16
        
        
        --gui.drawbox(inp.xmouse-1,inp.ymouse-1,inp.xmouse+1,inp.ymouse+1,"clear", "white")
        gui.drawpixel(inp.xmouse,inp.ymouse,"white")
        

        levelEdit = {}
        levelEdit.cursor={}
        levelEdit.cursor.x = math.floor((inp.xmouse+scrollx)/16)
        levelEdit.cursor.y = math.floor((inp.ymouse+scrolly+3)/16)
        
        x=levelEdit.cursor.x*16-scrollx
        y=levelEdit.cursor.y*16-scrolly
        gui.drawbox(x,y-3,x+16,y+16-3, "clear", "blue")
        
        levelEdit.block = 0
        
        if spidey.debug.enabled then
            drawfont(0,8*7+5,font[current_font], string.format("%02x %02x %02x",levelEdit.cursor.x,levelEdit.cursor.y, levelEdit.block))
        end
        
--        spidey.debug.levelEdit.cursorX=math.floor((game.scrollX.value+inp.xmouse)/16)
--        spidey.debug.levelEdit.cursorY=math.floor((game.scrollY.value+inp.ymouse)/16)
--        spidey.debug.levelEdit.screen=game.scrollScreen.value
--        if spidey.debug.levelEdit.cursorX>=0x10 then
--            spidey.debug.levelEdit.cursorX=spidey.debug.levelEdit.cursorX % 0x10
--            spidey.debug.levelEdit.screen=spidey.debug.levelEdit.screen+1
--        end
        
--        x=(spidey.debug.levelEdit.screen-game.scrollScreen.value)*16*16+spidey.debug.levelEdit.cursorX*16-game.scrollX.value
--        y=spidey.debug.levelEdit.cursorY*16-game.scrollY.value
--        gui.drawbox(x, y, x+16, y+16, "clear", "blue")


    end
    
    if inp.leftbutton_press and cheats.leftClick=="levelup" then
        createLevelUpText()
    end
    
    if inp.leftbutton_press and cheats.leftClick=="candle" then
        i=getunusedcustom()

        local c = {}
        c.type="candle"
        c.area={area1,area2,area3}
        c.x=math.floor((inp.xmouse+scrollx)/16)*16
        c.y=math.floor((inp.ymouse+scrolly)/16)*16
        c.outscreen=true
        c.active=1
        candles[#candles+1] = c
        
        if i then
            o.custom[i].type="candle"
            o.custom[i].area={area1,area2,area3}
            o.custom[i].x=math.floor((inp.xmouse+scrollx)/16)*16
            o.custom[i].y=math.floor((inp.ymouse+scrolly)/16)*16
            o.custom[i].outscreen=true
            o.custom[i].active=1
        end
    end
    
    
    if cheats.bonetest and inp.leftbutton_press then
    end
    
    --if cheats.active and not cheats.battest and inp.leftbutton_press then
    --if cheats.bonetest and inp.leftbutton_press then
    if inp.leftbutton_press and cheats.leftClick =="bone" then
    --if cheats.active and cheats.bonetest and inp.leftbutton_press then
        i=getunusedcustom()
        if (i) then
            o.custom[i].type="bone"
            o.custom[i].x=inp.xmouse+scrollx
            o.custom[i].y=inp.ymouse+scrolly
            o.custom[i].xs=math.random(-5,5)*.2
            --o.custom[i].xs=1
            o.custom[i].ys=math.random(-5,5)*.1-2.8
            --o.custom[i].ys=0
            --o.custom[i].xs=0
            --o.custom[i].ys=0
            o.custom[i].active=1
        end
    end

    for i=0,o.custom.count-1 do
        o.custom[i].xdist=math.abs(o.player.x-o.custom[i].x+scrollx)
        o.custom[i].ydist=math.abs(o.player.y-o.custom[i].y+scrolly)
        if o.custom[i].active==1 then
            o.custom[i].alivetime=math.min((o.custom[i].alivetime or 0)+1,100000)
        else
            o.custom[i].alivetime=0
        end
        if o.custom[i].active==1 then
            --gui.drawrect(o.custom[i].x-2-scrollx, o.custom[i].y-2-scrolly, o.custom[i].x+2-scrollx, o.custom[i].y+2-scrolly, "yellow","red")
            --gui.gdoverlay(o.custom[i].x-2-scrollx, o.custom[i].y-2-scrolly, cv2fire)
            
            o.custom[i].x=o.custom[i].x+o.custom[i].xs
            o.custom[i].y=o.custom[i].y+o.custom[i].ys
            
            if o.custom[i].type=="fireball" then
                gui.gdoverlay(o.custom[i].x-2-scrollx, o.custom[i].y-2-scrolly, cv2fire)
                o.custom[i].ys=o.custom[i].ys+.1
                if o.custom[i].xdist<10 and o.custom[i].ydist<10 then
                    o.custom[i].active=0
                    hurtplayer()
                end
            elseif o.custom[i].type=="candle" then
                --if o.custom.isOnScreen(i) or true then
                if o.custom.isOnScreen(i) then
                    f=math.floor(o.custom[i].alivetime/06) % 2
                    local x,y=o.custom[i].x-scrollx, o.custom[i].y-scrolly
                    --o.custom[i].flicker = 8
                    o.custom[i].flicker = o.custom[i].flicker or 0
                    if o.custom[i].flicker == 0 then
                        if math.random(1,50)==1 then o.custom[i].flicker = math.random(4,10) end
                    end
                    
--                    spidey.drawCircle(x+7-3,y+4,3, "#FFFF9910")
--                    spidey.drawCircle(x+7+3,y+4,3, "#FFFF9910")
                    if ((o.custom[i].flicker or 0) == 0) or o.custom[i].alivetime %4>=1 then
                        spidey.drawCircle(x+7,y+4,40, "#FFFF9910")
                        --spidey.drawCircle(x+7,y+4,6, "#FFFF9950")
                        spidey.drawCircle(x+7,y+4,6, "#FFFF9930")
                    else
                        spidey.drawCircle(x+7,y+4,5, "#FFFF9920")
                    end
                    if gui.circle then 
                        emu.pause()
                    end
                    o.custom[i].flicker = math.max(o.custom[i].flicker - 1,0)
                    gui.gdoverlay(o.custom[i].x-scrollx, o.custom[i].y-scrolly, gfx.candles[f])
                end
            elseif o.custom[i].type=="holyfire" then
                o.custom[i].frame = o.custom[i].frame or 0
                --if o.custom[i].alivetime > 8 and o.custom[i].alivetime %4>2 then
                if o.custom[i].alivetime % 5==0 then
                    o.custom[i].frame = (o.custom[i].frame + 1) % 5
                end
                
                --gui.gdoverlay(o.custom[i].x-2-scrollx, o.custom[i].y-2-scrolly, gfx.holyfire.test)
                gui.gdoverlay(o.custom[i].x-2-scrollx, o.custom[i].y-2-scrolly-15, gfx.holyfire[o.custom[i].frame])
                for ii=0,o.count-1 do
                    if o[ii].type~=0 and o[ii].team==1 then
                        xdist=math.abs(o[ii].x-o.custom[i].x+scrollx)
                        ydist=math.abs(o[ii].y-o.custom[i].y+scrolly)
                        if xdist<10 and ydist<30 then
                            --o.custom[i].active=0
                            hurtenemy(ii)
                            break
                        end
                    end
                end
                if o.custom[i].alivetime > 55 then
                    o.custom[i].active=0
                end
            elseif o.custom[i].type=="heart" then
                gui.gdoverlay(o.custom[i].x-2-scrollx, o.custom[i].y-2-scrolly, gfx.cv2heart)
                --o.custom[i].ys=o.custom[i].ys+.1
                if o.custom[i].xdist<10 and o.custom[i].ydist<10 then
                    o.custom[i].active=0
                    getheart()
                end
            elseif o.custom[i].type=="diamondtrail" then
                if o.custom[i].alivetime == 1 then o.custom[i].fade = 0xff end
                if o.custom[i].alivetime %1==0 then
                    if o.custom[i].alivetime>30 then
                        o.custom[i].fade = (o.custom[i].fade or 0xff) - 5
                        if o.custom[i].fade<0 then o.custom[i].fade = 0 end
                    end
                    gui.pixel(o.custom[i].x+5-scrollx, o.custom[i].y+5-scrolly,"#ffffff"..string.format("%02x",o.custom[i].fade or 255))
                    --drawfont(o.custom[i].x+5-scrollx, o.custom[i].y+5-scrolly,font[4], ".")
                    --gui.drawtext(o.custom[i].x+2-scrollx, o.custom[i].y-2-scrolly, ".", "white", "clear")
                    
                end
                if o.custom[i].alivetime>=100 then
                    o.custom[i].active = 0
                end
            elseif o.custom[i].type=="levelup" then
                local x = 70
                local y = 100
                local text = "- Level up! -"
                local borderColor = "#0070ec"
                if night then borderColor = "#24188c" end
                o.custom[i].textIndex = o.custom[i].textIndex or 1
                if o.custom[i].alivetime % 2 == 0 then
                    o.custom[i].textIndex = math.min(o.custom[i].textIndex + 1, #text)
                end
                
                
                gui.drawbox(x-2, y-3, x+8*16+2, y+8*2+3, "black", "black")
                gui.drawbox(x, y, x+8*16, y+8*2, "#000", borderColor)
                gui.drawbox(x+1, y-1, x+8*16-1, y+8*2+1, "clear", borderColor)
                
                drawfont(x+13,y+5,font[current_font], text:sub(1,o.custom[i].textIndex))
                

                if o.custom[i].alivetime==1 then
                    memory.writebyte(0x04f8,0x40) -- make invincible
                end
                
                -- add brief laurel effect, but don't cancel an actual laurel
                local l = memory.readbyte(0x0197)
                memory.writebyte(0x0197, math.max(l, 1))
                
                -- heal
                if o.player.hp < o.player.maxHp and o.custom[i].alivetime % 1 ==0 then
                    o.player.hp = o.player.hp + 1
                    memory.writebyte(0x0080, o.player.hp)
                end

                if o.custom[i].alivetime>=80 then
                    o.custom[i].active = 0
                end
            elseif o.custom[i].type=="bone" then
                o.custom[i].rnd=o.custom[i].rnd or math.random(0,90000)
                f=math.floor((o.custom[i].alivetime+o.custom[i].rnd)/06) % 3
                if o.custom[i].facing==0 then f=2-f end
                gui.gdoverlay(o.custom[i].x-2-scrollx-bone.xo[f], o.custom[i].y-2-scrolly-8-bone.yo[f], gfx.bone[f])
                o.custom[i].ys=o.custom[i].ys+.09
                --if o.custom[i].xdist<26 and o.custom[i].ydist<17 then
                if o.custom[i].xdist<15 and o.custom[i].ydist<17 then
                    o.custom[i].active=0
                    hurtplayer()
                end
            elseif o.custom[i].type=="axe" then
                o.custom[i].rnd=o.custom[i].rnd or math.random(0,90000)
                f=math.floor((o.custom[i].alivetime+o.custom[i].rnd)/06) % 4
                if o.custom[i].facing==0 then f=3-f end
                gui.gdoverlay(o.custom[i].x-2-scrollx-bone.xo[f], o.custom[i].y-2-scrolly-8-bone.yo[f], gfx.axe[f])
                o.custom[i].ys=o.custom[i].ys+.09
                for ii=0,o.count-1 do
                    if o[ii].type~=0 and o[ii].team==1 and (not o.custom[i].hasHit) then
                        xdist=math.abs(o[ii].x-o.custom[i].x+scrollx)
                        ydist=math.abs(o[ii].y-o.custom[i].y+scrolly)
                        if xdist<10 and ydist<10 then
                            --o.custom[i].active=0
                            o.custom[i].hasHit=true
                            hurtenemy(ii)
                            break
                        end
                    end
                end
            elseif o.custom[i].type=="bigbat" then
                o.custom[i].outscreen=true
                f=math.floor(o.custom[i].alivetime/10) % 2+1
                --if o.custom[i].facing==0 then f=2-f end
                gui.gdoverlay(o.custom[i].x-2-scrollx-bigbat.xo[f], o.custom[i].y-2-scrolly-8-bigbat.yo[f], gfx.bigbat[f])

                --o.custom[i].y=o.custom[i].y+math.cos(o.custom[i].alivetime *.03)*2
                --o.custom[i].x=o.custom[i].x+math.sin(o.custom[i].alivetime *.01)*1
                if o.player.x+scrollx>o.custom[i].x then dx=1 else dx=-1 end
                if o.player.y+scrolly>o.custom[i].y then dy=1 else dy=-1 end
                o.custom[i].ys=o.custom[i].ys+math.cos(o.custom[i].alivetime *.03)*.004*dy
                o.custom[i].xs=o.custom[i].xs+math.sin(o.custom[i].alivetime *.01)*.004*dx
                o.custom[i].ys=o.custom[i].ys+.006*dy
                o.custom[i].xs=o.custom[i].xs+.006*dx
                o.custom[i].ys=o.custom[i].ys-math.cos(o.custom[i].alivetime *.03)*.022
                if o.custom[i].alivetime % 30==0 then
                    o.custom[i].xs=o.custom[i].xs+dx*.5
                end
                if o.custom[i].alivetime % 200==0 then
                    --o.custom[i].xs=0
                    --o.custom[i].ys=0
                    o.custom[i].ys=.07*dy
                    o.custom[i].xs=.17*dx
                    
                end
                --o[i].y=o[i].y+math.cos(emu.framecount()*.09)*1
                --o[i].x=o[i].x+math.sin(emu.framecount()*.09)*1
                --n=40

                if o.custom[i].xdist<26 and o.custom[i].ydist<17 then
                    --o.custom[i].active=0
                    hurtplayer()
                end
            elseif o.custom[i].type=="bansheeboomerang" then
                
                f=math.floor(o.custom[i].alivetime/5) % 3
                if o.custom[i].facing==0 then f=2-f end
                gui.gdoverlay(o.custom[i].x-2-scrollx, o.custom[i].y-2-scrolly-8, gfx.boomerang[f])
                --o.custom[i].xs=o.custom[i].xs+.1
                if o.custom[i].rebound == false then
                    if o.custom[i].xs>0 then
                        if o.custom[i].x-scrollx>240 then o.custom[i].xs=-o.custom[i].xs; o.custom[i].x = 255+scrollx-10; o.custom[i].rebound=true end
                    elseif o.custom[i].xs<0 then
                        if o.custom[i].x-scrollx<0 then o.custom[i].xs=-o.custom[i].xs; o.custom[i].x = 0+scrollx+0; o.custom[i].rebound=true end
                    end
                end
                for ii=0,o.count-1 do
                    if o[ii].type~=0 and o[ii].team==1 then
                        xdist=math.abs(o[ii].x-o.custom[i].x+scrollx)
                        ydist=math.abs(o[ii].y-o.custom[i].y+scrolly)
                        if xdist<10 and ydist<10 then
                            --o.custom[i].active=0
                            hurtenemy(ii)
                            break
                        end
                    end
                end
                xdist=math.abs(o.player.x-o.custom[i].x+scrollx)
                ydist=math.abs(o.player.y-o.custom[i].y+scrolly)
                if o.custom[i].alivetime>20 and xdist<10 and ydist<10 then
                    --catch
                    o.custom[i].active=0
                    break
                end
            elseif o.custom[i].type=="dracfire" then
                gui.gdoverlay(o.custom[i].x-2-scrollx, o.custom[i].y-2-scrolly, cv2fire)
                o.custom[i].ys=o.custom[i].ys*.99
                if o.custom[i].facing==1 then 
                    o.custom[i].xs=o.custom[i].xs+.13
                else
                    o.custom[i].xs=o.custom[i].xs+-.13
                    
                end
                if o.custom[i].xdist<10 and o.custom[i].ydist<10 then
                    o.custom[i].active=0
                    hurtplayer()
                end
            else
                gui.gdoverlay(o.custom[i].x-2-scrollx, o.custom[i].y-2-scrolly, cv2fire)
            end
            
            if not o.custom[i].outscreen then
                if o.custom[i].x-scrollx<0 or o.custom[i].y-scrolly<0 or o.custom[i].x-scrollx>255 or o.custom[i].y-scrolly>255  then o.custom[i].active=0 end
            end
            
        end
    end
    
    if o[0].type==0x03 and false then
        if (emu.framecount() % 48)==0 then
            i=getunused()
            if i~=-1 then
                gui.text(20,20, string.format("%3u",i))
                o[i].type=0x30
                o[i].x=o[0].x
                o[i].y=o[0].y
                memory.writebyte(0x03ba+i,o[i].type)
                --memory.writebyte(0x0306+i,o[i].frame)
                memory.writebyte(0x0348+6+i,o[i].x)
                memory.writebyte(0x0324+6+i,o[i].y)
            end
        end
    end
    
    end
    
    
    
        --[[ create hearts out of nowhere
        --gui.text(8,8*6, string.format("%0X",memory.readbyte(0x03b7+3)))
        if memory.readbyte(0x03b7+3)==0 then
            simon_x= memory.readbyte(0x0348)
            simon_y= memory.readbyte(0x0324)
            memory.writebyte(0x03b7+3,0x36) --burn
            memory.writebyte(0x034b+3,simon_x)
            memory.writebyte(0x0327+3,simon_y)
            memory.writebyte(0x03ed+3,0x01) --helps to init it; frame?
            memory.writebyte(0x0393+3,0x00) --x speed
            memory.writebyte(0x044a,0x18) --make fire disappear faster
        end
        --]]
    
    -- faster messages
    if memory.readbyte(0x007b) == 4 then memory.writebyte(0x007b,0) end
    
    -- Trim the extra R from "Prossess".  Skips the letter as a nice
    -- quick fix until I get better handling to make custom messages.
    if msgnum==0x18 or msgnum==0x19 or msgnum==0x1a or msgnum==0x1b or msgnum==0x1c then 
      if memory.readbyte(0x007c) == 0x09 then memory.writebyte(0x007c,0x0a) end
    end
    -- appaer -> appear
    if msgnum==0x1e then 
      if memory.readbyte(0x007c) == 26 then memory.writebyte(0x0703,05) end
      if memory.readbyte(0x007c) == 27 then memory.writebyte(0x0703,01) end
    end
    
    
    -- draw G for gold over heart icon (needs work)
--    if (msgnum==0x33 or msgnum==0x30) and msgstatus~=0x0b then
--        drawfont(8*13,5+8*9,font[2], "G")
--    end
    
--    local msgIndex = memory.readbyte(0x007c)
--    gui.text(8,8*6, string.format("%0x %02x %02x",msgnum, msgIndex, msgstatus))
    
--    fontstr=" ABCDEFGHIJKLMNOPQRSTUVWXYZ.'v,                       0123456789!     -         !            ?    ETL            :"
    
--    msg=msg..fontstr:sub(msgchar+1,msgchar+1)

--    messages[msgIndex]
    
    
    if frame_tester then -- frame tester
        
        memory.writebyte(0x037e,0x00) --no downward gravity
        memory.writebyte(0x006c,0x00)
        memory.writebyte(0x006d,0x00)
        
        --wipe all enemies, and clear their gfx
        for i=0,12 do memory.writebyte(0x03ba+i,0) memory.writebyte(0x0306+i,0) end
        
        memory.writebyte(0x0300,0) --simon frame
        
        --emu.setrenderplanes(true, false)
        --frame=memory.readbyte(0x0303)
        simon_x= memory.readbyte(0x0348)
        simon_y= memory.readbyte(0x0324)
        memory.writebyte(0x034b,simon_x)
        memory.writebyte(0x0327,0x30)
        if joy[1].right_press or joy[1].right_press_time>32 then
            frame=frame+1
            if frame>0xff then frame=0xff end
        end
        if joy[1].left_press or joy[1].left_press_time>32 then
            frame=frame-1
            if frame<0 then frame=0 end
        end
        gui.text(8,8*6, string.format("frame=%02X",frame)); -- force clear of previous text
        memory.writebyte(0x0303,frame)
    else
        --emu.setrenderplanes(true, true)
    end
    
    --memory.writebyte(0x0245,0x1d) --hit box test
    --memory.writebyte(0x018b,0xc1) --hit box test **this makes it so you start low on screen after death 0x186 does too
    if (cheats.active) then
        if joy[1].A_press and joy[1].B and joy[1].down then
            
--            c0=hex2bin('80'..nespalette[0x0f]:sub(2,2+6))
--            c1=hex2bin('00'..nespalette[0x11]:sub(2,3+6))
--            c2=hex2bin('00'..nespalette[0x20]:sub(2,3+6))
--            c3=hex2bin('00'..nespalette[0x15]:sub(2,3+6))
            
            
            --palettenum=16
            --c1= hex2bin(string.format('00%02X%02X%02X',memory.readbyteppu(0x3f01+9*palettenum+0),memory.readbyteppu(0x3f01+9*palettenum+1),memory.readbyteppu(0x3f01+9*palettenum+2)))
            --c2= hex2bin(string.format('00%02X%02X%02X',memory.readbyteppu(0x3f01+9*palettenum+3),memory.readbyteppu(0x3f01+9*palettenum+4),memory.readbyteppu(0x3f01+9*palettenum+5)))
            --c3= hex2bin(string.format('00%02X%02X%02X',memory.readbyteppu(0x3f01+9*palettenum+6),memory.readbyteppu(0x3f01+9*palettenum+7),memory.readbyteppu(0x3f01+9*palettenum+8)))
            --emu.message(string.format('%02X',memory.readbyteppu(0x3f00+0)))
            --p=getpalettedata()
            --emu.message(string.format('%02X %02X %02X',p.color_indexed[3],p.color_indexed[4],p.color_indexed[5]))
            --emu.message(bin2hex(c1)..' '..bin2hex(c2)..' '..bin2hex(c3))
            --emu.message(string.format('%02X %02X %02X',memory.readbyte(0x2007),memory.readbyteppu(0x3f01+2),memory.readbyte(0x2007)))
            
            ofs=0+0x10*0x52
            --testgfx=gdTile(ofs+0x000, c0, c1, c2, c3, false,false)
            --[[
            for i=0,12 do
                e1=memory.readbyte(0x03ba+i)
                --if e1==0x06 then e1=0x0d end
                if e1 ~= 0 then
                    e1=0x36 --burn
                end
                memory.writebyte(0x03ba+i,e1)
            end
            ]]--
        end
        
        --[[
        if action and joy[1].down and joy[1].B_press then
            simon_x= memory.readbyte(0x0348)
            simon_y= memory.readbyte(0x0324)
            simon_facing=memory.readbyte(0x0420)
            memory.writebyte(0x034b+3,simon_x+16)
            memory.writebyte(0x0327+3,simon_y)
            memory.writebyte(0x03b7+3,0x09) -- type
            memory.writebyte(0x03ed+3,0x01) --helps to init it; frame?
            if memory.readbyte(0x0420)==0 then --if simon facing left
                memory.writebyte(0x0393+3,0xfe) --x speed
                memory.writebyte(0x0423+3,0) -- weapon face left
            else
                memory.writebyte(0x0393+3,0x02) --x speed
                memory.writebyte(0x0423+3,1) -- weapon face right
            end
            --memory.writebyte(0x0303,0xad) -- graphics
            --memory.writebyte(0x0411,0x32) -- graphics 2
        end
        ]]--
        
        
        --[[
        if action and joy[1].down and joy[1].B_press then
            simon_x= memory.readbyte(0x0348)
            simon_y= memory.readbyte(0x0324)
            memory.writebyte(0x034b,simon_x)
            memory.writebyte(0x0327,simon_y-16)
            memory.writebyte(0x03b7,0x03) --weapon type
            memory.writebyte(0x03ed,0x01) --helps to init it; frame?
            if memory.readbyte(0x0420)==0 then --if simon facing left
                memory.writebyte(0x0393,0xfe) --x speed
                memory.writebyte(0x0423,0) -- weapon face left
            else
                memory.writebyte(0x0393,0x02) --x speed
                memory.writebyte(0x0423,1) -- weapon face right
            end
            --memory.writebyte(0x0303,0xad) -- graphics
            --memory.writebyte(0x0411,0x32) -- graphics 2
        end
        ]]--
        
        --gui.text(8,8*6, string.format("%0X",memory.readbyte(0x03ba)))
        
        
        --Make Simon dance if he's idle for a while in the woods and it's not night
        if joy[1].idle_time>500 and (area1>=2 and area1<=4) and not night then
            o.player.dance=o.player.dance or {stepCount=0, headBangCount=0}
            o.player.dance.headBangCount = o.player.dance.headBangCount or 0
            music1=memory.readbyte(0x00a3)
            if music1==0x3d then
                if memory.readbyte(0x00b5)==0x02 then
                    memory.writebyte(0x300,0x0c)
                else
                    memory.writebyte(0x300,0x0d)
                end
                o.player.dance = {stepCount=0, headBangCount=0}
            elseif music1==0x40 then
                if o.player.dance.headBangCount<=16 then
                    if memory.readbyte(0x00b5)==0x03 then
                        o.player.dance.lastHeadBang = true
                        memory.writebyte(0x239,0x3d) -- head banger
                    else
                        if o.player.dance.lastHeadBang == true then
                            o.player.dance.lastHeadBang = false
                            o.player.dance.headBangCount=o.player.dance.headBangCount+1
                        end
                    end
                else
                    -- turn step dance
                    if memory.readbyte(0x00b5)==0x03 then
                        o.player.dance.lastStep = true
                        memory.writebyte(0x300,0x08)
                    else
                        if o.player.dance.lastStep then
                            o.player.dance.lastStep = false
                            o.player.dance.stepCount=o.player.dance.stepCount+1
                        end
                        memory.writebyte(0x300,0x04)
                    end
                    
                    if (o.player.dance.stepCount %4 > 2) or o.player.dance.stepCount > 20 then
                        if memory.readbyte(0x00c7)==0x01 then
                            memory.writebyte(0x420,0x00)
                        else
                            memory.writebyte(0x420,0x01)
                        end
                    end
                end
            end
        end
        
        --hp=memory.readbyte(0x0080)
        sp1=memory.readbyte(0x03b7)
        if sp1==0x01 then
            --sp1=0x0b
        end
        memory.writebyte(0x03b7,sp1)
        
        whipframe=memory.readbyte(0x0445)
        --[[
        if whipframe==01 then --fast whip
            whipframe=02
        end
        ]]--
        
        --if joy[1].B_press and whipframe==02 then
        --    whipframe=01
        --end
        
        --wy=memory.readbyte(0x0327)
        --wx=memory.readbyte(0x034b)
        --if joy[1].up then wy=wy-1 end
        --if joy[1].down then wy=wy+1 end
        --if joy[1].left then wx=wx-1 end
        --if joy[1].right then wx=wx+1 end
        --memory.writebyte(0x0327,wy)
        --memory.writebyte(0x034b,wx)
        
        memory.writebyte(0x0445,whipframe)
        
        --if hp<0x30 and os.time() % 10==0 then
        if o.player.hp < o.player.maxHp and os.time() % 10==0 then
            o.player.hp = o.player.hp + 1
            memory.writebyte(0x0080, o.player.hp)
        end
        if cheats.maxlevel then
            memory.writebyte(0x08b,0x05) --level
            memory.writebyte(0x046,0x00) --exp 00xx
            memory.writebyte(0x047,0x00) --exp xx00
        end
        memory.writebyte(0x0048,0x56) --hearts 00xx
        memory.writebyte(0x0049,0x02) --hearts xx00
        if cheats.allitems then 
            memory.writebyte(0x004a,0xff) --stuff (dagger, etc)
            memory.writebyte(0x004c,0x08) --Laurels
            memory.writebyte(0x004d,0x08) --Garlic
            memory.writebyte(0x0091,0xff) --stuff (relics row)
            memory.writebyte(0x0092,0xff) --stuff
        end
        if cheats.flamewhip then memory.writebyte(0x0434,0x04) end
        if cheats.invincible then memory.writebyte(0x04f8,0x20) end
        memory.writebyte(0x0086,0x06) --hours = 06
        memory.writebyte(0x0085,0x01) --minutes = 00
        
        if cheats.refightbosses then refight_bosses=true end
        
    end
    
--    if action or (pausemenu and frame_tester) then
--        drawHUD()
--    end
    
    mnu.background = not frame_tester -- don't show menu background if using the frame tester
    
    if specialPause and joy[1].select_press then
        exitSpecialPause = true
    end
    
    if game.paused and cheats.enabled and mapmenu == false then
            if spidey.cheatEngine.menuOpen then
                cheatMenu.items= spidey.cheatEngine.menu.current
                cheatMenu:show()
                mnu:hide()
            else
                mnu:show()
                cheatMenu:hide()
            end
    else
        mnu:hide()
    end
end

function spidey.draw()
    hideHP()
    if action or (pausemenu and frame_tester) then
        drawHUD()
    elseif pausemenu then
        drawSubScreen()
    end
    
    if (action or pausemenu) and o.player.inBossRoom==true then
        gui.gdoverlay(0,13+16*10,gfx.block)
        gui.gdoverlay(0,13+16*11,gfx.block)
        gui.gdoverlay(16*15,13+16*10,gfx.block)
        gui.gdoverlay(16*15,13+16*11,gfx.block)
    end
end

spidey.run()