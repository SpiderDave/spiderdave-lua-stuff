-- Castlevania 2 Lua script by SpiderDave
--
-- Changes:
--  * Message speed increased
--  * New patterns for Dracula (needs work and balancing)
--  * Improved Death boss (broken atm)
--  * Improved Carmilla boss (broken atm)
--  * Skeletons can turn around
--  * Skeletons now throw bones.  They throw more bones more frequently at night
--  * Werewolves improved; rush and jump attack.  rush distance increased at night.
--  * Improved skulls, ghosts, medusa heads (broken atm)
--  * Improved floating eyes
--  * Hands are hidden until close.
--  * All fireballs should now face proper direction
--  * Don't re-fight Bosses
--  * Locked boss rooms
--  * Fireballs (except those created by script) are destructable
--  * Most special weapons now have a heart cost.
--  * Garlic disappears after a while.
--  * Banshee Boomerang
--  * Axes
--  * Fixed spelling "Prossess" -> "Possess"
--  * New top display
--  * Holy water burn effect. The bottle is also now blue.
--  * Diamond sprite graphics are changed, and trail added.
--  * Day starts at 1
--  * Changed lives display to mean "extra" lives (you can go down to 0)
--  * The period of invincibility when you get hit now starts when you land,
--    and the player flashes.
--  * Relics are no longer equipped but turned on or off instead.  You can now have all 
--    relics active at the same time.
--  * Crystals are seperate and no longer swapped
--  * Experience is now gained when killing enemies, and experience system is reworked.
--  * Experience display shows total experience from all levels, not just current.
--  * Start at level 1; maximum level is 99.
--  * New "Level Up" toast.  Provides brief invincibility and health replenish on level up.
--  * Gold system added.  Gold is added automatically when killing enemies.
--  * Hearts no longer give experience and are no longer used to buy items.
--  * Maximum hearts lowered to 99 (these are now only used for special weapons).
--  * New reworked Sub screen
--  * New items (armors, whips).
--  * Reduced stun time when using whip
--  * slightly increased whip delay (to match other games)
--  * Removed continue/password screen, added simple "game over" screen
--  * Dracula's eye now shows fake blocks and breakable blocks
--  * New Save/Load system
--  * Adjusted handling of velocity when jumping while on a moving platform.
--  * Adjusted velocity when getting hit to be closer to other games.
--
-- Debug and experimental stuff (may not be in the final version):
--  * Cheats
--  * Frame tester
--  * Bat mode
--
-- ToDo/Issues/Bugs:
--  * Snakes should turn before jumping
--  * Ferryman shouldn't bounce off the dock and leave
--    + works most of the time; buggy.
--  * Custom projectiles need a better hit method.  Currently
--    It simply creates holy fire where the projectile was.
--  * Custom projectiles may disappear on non-enemy objects
--    such as moving platforms.
--  * Blood Skeletons
--  * Don't get items you already have (Dracula's parts, etc)
--    + dracula parts finished
--    + clues finished
--  * add mummy bandages
--  * overhaul menu system, make new sub screen
--    + select weapons, relics, equipment
--    + bestiary
--    + map
--    + clue list *DONE*
--  * improve gold system
--  * make garlic throw a bunch of garlic
--  * fix ghosts
--  * Change reflected fireballs to blocked fireballs (disappear)
--  * make bordia mountains useful (put something there)
--  * move respawn points to where you first entered the screen
--  * add stopwatch
--  * loading a save state doesn't reset some script things
--  * resetting doesn't clear extra data
--  * finish map labels
--  * make spikes kill you completely
--  * allow different configs for different save slots
--  * skeletons sometimes throw bones from below you when they are above -- wrong bone placement
--  * make it so when you get hit on stairs, you don't get knocked off.
--     - started work on it, buggy.
--  * create a town warp for debugging
--  * audit/test getting all items
--  * rework all memory.registerexec functions to use custom callbacks.  safer, better.
--     - did most of them
--  * add confirmation of equipping an item (sound, flash, etc)
--  * make it so when hands hit you you don't get knocked back.
--  * prevent talking to npcs in the air
--  * bug - password text is wrong (can't get to password screen anyway but still should track it down)
--  * issue - can keep getting non-inventory custom items (like gold) over and over again
--  * issue - boss doors don't reflect diamond or other collisions.
--      - possible solution: adjust nametable data.
--  * bug - can't get silk bag.
--  * restore hp after boss (or getting dracula relic?)
--  * fix it so jumping into sideways spikes doesn't just make you stand on them.
--  * animate water
--  * add ability to stand up during early part of ducking whip
--  * level up toast should go on top of everything else
--  * fix bug where you can whip through edge of screen and break blocks on the other side.
--  * adjust spawn point at top of screen so enemies don't appear behind the hud.
--  * bug: getting hit by custom hit object affects block velocity

require ".Spidey.TSerial"

spidey=require "Spidey.SpideyStuff"
local font=require "Spidey.default_font"
local cv2data=require("cv2.cv2data")
local candles = require("cv2.candles")
local items=require("cv2.items")
local util = require("spidey.util")
require("cv2.callbacks")
local hitboxes = require("cv2.hitboxes")
local config={}

function config.load(filename)
    if not util.fileExists(filename) then return end
    local file = io.open(filename, "r")
    for line in file:lines() do
        local k,v
        line = util.split(line,"//")[1]
        if util.trim(line)~="" then
            k=util.trim(util.split(line,"=")[1],1)
            v=util.trim(util.split(line,"=")[2],1)
            -- Attempt to coerce to a boolean or number
            if v=="false" then v=false end
            if v=="true" then v=true end
            v = tonumber(v) or v
            config[k]=v
        end
    end
end

config.load("cv2/config.default.txt")
config.load("cv2/config.txt")

spidey.joyAliases.confirm = config.button_confirm or spidey.joyAliases.confirm
spidey.joyAliases.cancel = config.button_cancel or spidey.joyAliases.cancel

local graphics = require("Spidey.graphics")
graphics:init(config.graphics_mode or "")

local sound = require("spidey.sound")
sound:init(util, util.getScriptFolder())

for k,v in pairs(cv2data.sounds) do
    sound:makeAlias(k, "cv2/sound/"..v)
end

if not config.externalSound then sound.enabled=false end

--local textMap = " ABCDEFGHIJKLMNOPQRSTUVWXYZ.'v,                       0123456789!     -         !            ?    ETL            :"
local textMap = " ABCDEFGHIJKLMNOPQRSTUVWXYZ.'v,                       0123456789!     -         !            ?    ETL            :"
local textMap2 = {}
for i=0,#textMap-1 do
    local c = textMap:sub(i+1,i+1)
    textMap2[c]=textMap2[c] or i
end
textMap2["\n"]=0xfe

game = {}
game.scriptPath = util.getScriptFolder()
game.paused = false
game.map = cv2data.map
game.map.x=0
game.map.y=0
game.map.width = 484
game.map.height = 237
game.map.visible=false
game.saveSlot = 1
game.romUndo = game.romUndo or {index={}}

game.showSaveMenu = false
game.saveCursor = 0

game.film = {
    scroll = 0,
    y=0,
    counter=0,
}

game.credits = {
    y=0,
    show=false,
}

game.medusa = {}

game.data = {}
game.data.enemies=game.data.enemies or {}

if util.fileExists('cv2/warp.dat') then
    local t=getfilecontents('cv2/warp.dat')
    t=TSerial.unpack(t)
    game.data.warps=t
elseif util.fileExists('cv2/warp.default.dat') then
    local t=getfilecontents('cv2/warp.default.dat')
    t=TSerial.unpack(t)
    game.data.warps=t
else
    game.data.warps = {}
end

local subScreen = {}
subScreen.subMenu={x=0, y=0, scrollY=0}

subScreen.clues = {106, 91, 62, 76, 77, 63, 78, 79, 56, 64, 96, 65, 57, 67, 68, 70, 102, 87, 103, 88, 89, 105, 61, }
subScreen.clue = 1

game.setDebugMenuTab = function(tab)
    game.debugMenuTab = tab
    subScreen.subMenu.y = 0
    subScreen.subMenu.scrollY = 0
end

game.debugMenuItems = {
    {tab="main", text="Cheats", action=function()
        game.setDebugMenuTab("cheats")
    end},
    {tab="main", text="Debug", action=function()
        game.setDebugMenuTab("debug")
    end},
    {tab="cheats", text="Fill HP", action=function()
        objects.player.hp = objects.player.maxHp
        memory.writebyte(0x0080, objects.player.hp)
        --queueSound(0x1f)
    end},
    {tab="cheats", text="Fill hearts", action=function()
        objects.player.hearts = objects.player.maxHearts
        setHearts(objects.player.hearts)
        --queueSound(0x1f)
    end},
    {tab="cheats", text="Add 1000 gold", action=function()
        objects.player.gold = objects.player.gold + 1000
        memory.writeword(0x7000+1, objects.player.gold)
    end},
    {tab="cheats", text=function() return "No Enemies "..(config.noEnemies and "on" or "off") end, action=function()
        config.noEnemies = not config.noEnemies
    end},

    {tab="-cheats", text=function() return "Save Slot "..game.saveSlot end, action=function()
    end},
    
    {tab="-cheats", text=function() return "Load Game - slot "..game.saveSlot end, action=function()
        loadGame(game.saveSlot, true)
    end},
    {tab="-cheats", text=function() return "Save Game - slot "..game.saveSlot end, action=function()
        saveGame(game.saveSlot)
    end},
    {tab="debug", text="Warp", action=function()
        game.setDebugMenuTab("warp")
    end},
    {tab="debug", text="left click action", action=function()
        game.setDebugMenuTab("leftclick")
    end},
    {tab="leftclick", text="Falling Blocks", action=function()
        config.leftClick = "fallingBlocks"
    end},
    {tab="leftclick", text="Item Pop-up", action=function()
        config.leftClick = "itemPopUp"
    end},
    {tab="leftclick", text="Level up", action=function()
        config.leftClick = "levelup"
    end},
    {tab="debug", text="time", action=function()
        game.setDebugMenuTab("time")
    end},
    {tab="debug", text="day/night test", action=function()
        memory.writebyte(0x002c, 0x06) -- day/night toggle thing
        memory.writebyte(0x0088, 0x01) -- day/night toggle counter
    end},
    {tab="debug", text="sfxtest", action=function()
        sound:play("getMoneyBag")
    end},
    {tab="debug", text=function() return "Candle Edit Mode "..(config.editCandles and "on" or "off") end, action=function()
        config.editCandles = not config.editCandles
    end},
    {tab="debug", text=function() return "Candle Item "..(config.candleItem or "heart") end, action=function()
        game.setDebugMenuTab("candleitem")
    end},
    {tab="debug", text=function() return "Show Hitboxes "..(config.hitboxes and "on" or "off") end, action=function()
        config.hitboxes = not config.hitboxes
    end},
    {tab="debug", text=function() return "Debug "..(spidey.debug.enabled and "on" or "off") end, action=function()
        spidey.debug.enabled = not spidey.debug.enabled
    end},
    {tab="debug", text=function() return "Show Stats "..(config.testStats and "on" or "off") end, action=function()
        config.testStats = not config.testStats
    end},
    {tab="debug", text="Ending", action=function()
        game.setDebugMenuTab("ending")
    end},
    {tab="debug", text="Credits", action=function()
        game.credits.show=true
        game.credits.done=false
        game.credits.y=0
    end},
    {tab="debug", text="Reset", action=function()
        emu.softreset()
        emu.message("") -- suppress the "reset" message
    end},
    {tab="candleitem", text="Heart", action=function()
        config.candleItem = false
    end},
    {tab="ending", text="1", action=function()
        config.testEnding = 1
    end},
    {tab="ending", text="2", action=function()
        config.testEnding = 2
    end},
    {tab="ending", text="3", action=function()
        config.testEnding = 3
    end},
}

for i,v in ipairs(items) do
    game.debugMenuItems[#game.debugMenuItems+1]={tab="candleitem", text = v.shortName, action = function() config.candleItem = v.name game.setDebugMenuTab("debug") end}
end

for i,w in ipairs(game.data.warps or {}) do
    --return string.format("Warp %02x %s", game.data.warpNum or 1, cv2data.locations.getAreaName(w.area1,w.area2,w.area3))
    game.debugMenuItems[#game.debugMenuItems+1]={tab="warp", text = function() return cv2data.locations.getAreaName(w.area1,w.area2,w.area3) end, action = function()
        game.data.warpNum = i
        warpPlayer(w)
        memory.writebyte(0x0026,0) -- unpause
    end}
end

--6:00 day 18:00 night
for i=0,23 do
    game.debugMenuItems[#game.debugMenuItems+1]={tab="time", text = string.format("%02d:00",i), action = function()
        memory.writebyte(0x0086, tonumber(string.format("%02d",i),16)) -- time1
        memory.writebyte(0x0085, 0x00) -- time2
    end}
end

for i=1,#game.debugMenuItems do
    game.debugMenuItems[i].index = i
end
game.debugMenuTab = "main"


enableddisabled={[true]="enabled",[false]="disabled"}

--if not messages then messages={} end


spidey.imgEdit.transparent = true
--spidey.imgEdit.transparentColor="#000000"
spidey.imgEdit.nobk=true


--current_font=2
current_font=1

font_selector=false
show_cursor = true
--quickmessages= true -- Displays idle messages; work in progress
game.paused = false
cheats={enabled=true,active=false,invincible=true,allitems=true,flamewhip=true,refightbosses=true,battest=false,bonetest=true}
cheats.leftClick = config.cheats_leftClick or config.leftClick


if config.cheats==true then cheats.active=true end

skeleton=false
bat=false
frame=0
frame_tester=false
simon_frame=0
spidey.debug.enabled=false

local msgChoice=0
local msgMode=0
local action

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
            else
                -- reenable whip better
                whipframe=00
                memory.writebyte(0x0445,whipframe)

            end
        end
    },
    {
        text=function()
            local w = game.data.warps[game.data.warpNum]
            if w then
                return string.format("Warp %02x %s", game.data.warpNum or 1, cv2data.locations.getAreaName(w.area1,w.area2,w.area3))
            else
                return string.format("Warp %02x", game.data.warpNum or 1)
            end
        end,
        action=function()
            game.data.warpNum = game.data.warpNum or 1
            
            local w = game.data.warps[game.data.warpNum]
            warpPlayer(w)
            memory.writebyte(0x0026,0) -- unpause
        end,
        left = function()
            game.data.warpNum = (game.data.warpNum or 1) - 1
        end,
        right = function()
            game.data.warpNum = (game.data.warpNum or 1) + 1
        end,
    },
    {text="Save Warp",
        action=function()
            game.data.warps[game.data.warpNum or 1] = {
                area1=memory.readbyte(0x0030),
                area2=memory.readbyte(0x0050),
                area3=memory.readbyte(0x0051) % 0x80,
                areaFlags=memory.readbyte(0x008f),
                returnArea = memory.readbyte(0x004e),
                returnScroll1 = memory.readbyte(0x0458),
                returnScroll2 = memory.readbyte(0x0046a),
                returnX = memory.readbyte(0x04a0),
                returnY = memory.readbyte(0x04b2),
                playerX=objects.player.x,
                playerY=objects.player.y,
                scrollX=scrollx,
                scrollY=scrolly,
            }
            local t= TSerial.pack(game.data.warps)
            writetofile('cv2/warp.dat', t)
            emu.message("warp saved.")
        end,
    },
    {text="Save candles",
        condition=function() return config.editCandles end,
        action=function()

            local out = "local candles = {\n"
            local formatText = '    {x=0x%02x, y=0x%02x, area = {0x%02x,0x%02x,0x%02x,0x%02x}, floor=0x%02x, location="%s", item="%s" },\n'
            for _,c in ipairs(candles) do
                if c.item then
                    formatText = '    {x=0x%02x, y=0x%02x, area = {0x%02x,0x%02x,0x%02x,0x%02x}, floor=0x%02x, location="%s", item="%s", },\n'
                    out = out..string.format(formatText, c.x,c.y,c.area[1],c.area[2],c.area[3],c.area[4],c.floor,c.location, c.item)
                else
                    formatText = '    {x=0x%02x, y=0x%02x, area = {0x%02x,0x%02x,0x%02x,0x%02x}, floor=0x%02x, location="%s", },\n'
                    out = out..string.format(formatText, c.x,c.y,c.area[1],c.area[2],c.area[3],c.area[4],c.floor,c.location)
                end
            end
            out=out.."}\n\nreturn candles\n"
            
            writetofile('cv2/candles.backup.lua', spidey.getFileContents("cv2/candles.lua"))
            writetofile('cv2/candles.lua', out)
            emu.message("Candles exported to cv2/candles.lua")
        end,
    },
    {text="Damage list",
        action=function()
            local levels={1,2,3,4,5,6,15,50,99}
            local level
            local stats

            local out=""
            out=out..string.rep("-",24).."\n"
            out=out.."Whip name, Attack power\n"
            out=out..string.rep("-",24).."\n"
            local whips = {}
            for _,item in ipairs(items) do
                if item.type=="whip" then
                    whips[#whips+1]=item
                    out=out..string.format("%-14s:%s\n",item.name, item.attack)
                end
            end
            out=out..string.rep("-",24).."\n\n"
            for i=0, 0xff do
                local e = cv2data.enemies[i]
                if e then
                    out=out..string.format("%s\nExp: %s\nHP: %s\nAttack: %s\n", e.name, e.exp or "?",e.hp or "?", e.attack or "?")
                
                    local oldWhip = objects.player.whipItem
                    
                    
--                    +--------------+--------------+--------------+--------------+--------------+--------------+--------------+
--                    | Leather Whip | Leather Whip | Thorn Whip   | Chain Whip   | Morning Star | Flame Whip   | Poison Whip  |
--                    |--------------+--------------+--------------+--------------+--------------+--------------+--------------|
--                    | level 01     | 2            | 1            | 1            | 1            | 1            | 1            |
--                    | level 50     | 2            | 1            | 1            | 1            | 1            | 1            |
--                    | level 99     | 2            | 1            | 1            | 1            | 1            | 1            |
--                    +--------------+--------------+--------------+--------------+--------------+--------------+--------------+
                    
                    if type(e.hp)=="number" then
                    
                        out = out.."+"..string.rep(string.rep("-",14).."+", #whips+1).."\n"
                        
                        out=out..string.format("|%14s|","")
                        for _,whip in ipairs(whips) do
                            out=out..string.format(" %-12s |",whip.name)
                        end
                        out=out.."\n"
                        out = out.."|"..string.rep(string.rep("-",14).."+", #whips)..string.rep("-",14).."|\n"
                        
                        for _,level in ipairs(levels) do
                            out=out..string.format("| %-12s |","level "..level)
                            for _,whip in ipairs(whips) do
                                objects.player.whipItem = whip.index
                                stats = getStats(level)
                                local nHits = math.ceil(e.hp/stats.damage)
                                out=out..string.format(" %-12s |",nHits)
                            end
                            out=out.."\n"
                        end
                        out = out.."+"..string.rep(string.rep("-",14).."+", #whips+1).."\n"
                    end
                    
                    
                    
                    
                    
--                    for _,level in ipairs(levels) do
--                        for _,item in ipairs(items) do
--                            if item.type=="whip" then
--                                objects.player.whipItem = item.index
--                                stats = getStats(level)
--                                local nHits
                                
--                                if e.hp then
--                                    nHits = math.ceil(e.hp/stats.damage)
--                                    out=out..string.format("Number of hits with %s at level %s: %s\n", item.name, level, nHits)
--                                end
--                            end
--                        end
--                    end
                    out=out.."\n"
                end
                
            end
            
            objects.player.whipItem = oldWhip
            
            writetofile('cv2/damage.txt', out)
            emu.message("output to cv2/damage.txt")
--            local armorDef = items[objects.player.armor or items.index["Red Tunic"]].ar or 0
--            local weaponPower = items[objects.player.whipItem or items.index["Leather Whip"]].attack or 0
--            cv2data.enemies
        end
    },
    {text=function() return string.format('Frame Test: %s',spidey.prettyValue(frame_tester)) end,
        action=function()
            frame_tester=not frame_tester
            emu.setrenderplanes(true, not frame_tester)
        end
    },
    {text="Save game data",
    action=function()
        saveGame(game.saveSlot)
    end},
    {text="Load game data",
    action=function()
        loadGame(game.saveSlot) -- setArea=false
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

--candles[1]={}
--candles[1].xo = 0
local levelObjects = {}

for _,item in ipairs(cv2data.placedItems) do
    local c={}
    c.type="item"
    c.area={item.area[1],item.area[2],item.area[3],item.area[4]}
    c.x=item.x
    c.y=item.y
    c.outscreen=true
    c.active=1
    c.name = item.name
    levelObjects[#levelObjects+1] = c


--    local c = {}
--    c.type="candle"
--    c.area={item.area[1],item.area[2],item.area[3],item.area[4]}
--    c.x=item.x
--    c.y=item.y-0x30
--    c.outscreen=true
--    c.active=1
--    candles[#candles+1] = c
end

--for _,item in ipairs(candles) do
--    local c = {}
--    c.type="candle"
--    c.area={item.area[1],item.area[2],item.area[3],item.area[4]}
--    c.x=item.x
--    c.y=item.y
--    c.outscreen=true
--    c.active=1
--    c.floor=item.floor
--    candles[#candles+1] = c
--end


gfxFileList={}
oldgetfilecontents=getfilecontents
local getfilecontents =function(f)
    gfxFileList[#gfxFileList+1]=f
    return oldgetfilecontents(f)
end


gfx={}
gfx.fileList = {}

gfx.load = function(f)
    local ext = graphics.getFileExt(f)
    if not ext then
        if graphics.use_gd then
            -- using gd library so we can load stuff like .png
            ext = ".png"
        else
            -- native fceux gd stuff only
            ext = ".gd"
        end
        
        f=f..ext
    end
    gfx.fileList[#gfx.fileList+1]=f
    
    local path = ""
    if ext == ".gd" then
        path = "cv2/images/gd/"
    elseif ext == ".png" then
        path = "cv2/images/png/"
    end
    local t={}
    t.image = graphics:loadImage(path..f)
    return t
end

gfx.draw = function(x,y,img)
    if type(img) == "table" then
        graphics:draw(x+(img.xo or 0),y+(img.yo or 0),img.image)
    else
        graphics:draw(x,y,img)
    end
    
end

--local testGraphics = gfx.load("axe4")


gfx.gold={}
for i=1,10 do
    gfx.gold[i]=gfx.load(string.format("gold%d",i))
end
gfx.map=gfx.load("map")
gfx.whipicon=gfx.load("whipicon")
gfx.cv2heart=gfx.load("cv2heart")
gfx.arrowcursor=gfx.load("arrowcursor")
gfx.arrowcursorRight=gfx.load("arrowcursor_right")
gfx.relics={}
gfx.relics[1]=gfx.load("cv2_relic_rib")
gfx.relics[2]=gfx.load("cv2_relic_heart")
gfx.relics[3]=gfx.load("cv2_relic_eye")
gfx.relics[4]=gfx.load("cv2_relic_nail")
gfx.relics[5]=gfx.load("cv2_relic_ring")
gfx.relics[6]=gfx.load("whitecrystal")
gfx.relics[7]=gfx.load("bluecrystal")
gfx.relics[8]=gfx.load("redcrystal")
gfx.whitecrystal=gfx.load("whitecrystal")
gfx.bluecrystal=gfx.load("bluecrystal")
gfx.redcrystal=gfx.load("redcrystal")
gfx.items = {}
gfx.items.bag = gfx.load("bag")
gfx.items.cross = gfx.load("cross")
gfx.weapons={}
gfx.weapons[1]=gfx.load("cv2_dagger")
gfx.weapons[2]=gfx.load("cv2_dagger2")
gfx.weapons[3]=gfx.load("cv2_dagger3")
--gfx.weapons[4]=gfx.load("cv2_holywater")
--gfx.weapons[4]=gfx.load("holywater")
gfx.weapons[4]=gfx.load("holywater_new")
gfx.weapons[5]=gfx.load("cv2_diamond")
gfx.weapons[6]=gfx.load("cv2_flame")
gfx.weapons[7]=gfx.load("cv2_stake")
gfx.weapons[8]=gfx.load("cv2_laurel")
gfx.weapons[9]=gfx.load("cv2_garlic")
gfx.holyfire={}
gfx.holyfire.test=gfx.load("holyfire")
gfx.holyfire[0]=gfx.load("holyfire0")
gfx.holyfire[1]=gfx.load("holyfire1")
gfx.holyfire[2]=gfx.load("holyfire2")
gfx.holyfire[3]=gfx.load("holyfire3")
gfx.holyfire[4]=gfx.load("holyfire4")
gfx.holywater={}
gfx.holywater.test=gfx.load("holywater")
gfx.boomerang={}
gfx.boomerang[0]=gfx.load("boomerang1")
gfx.boomerang[1]=gfx.load("boomerang2")
gfx.boomerang[2]=gfx.load("boomerang3")
gfx.bigbat={}
gfx.bigbat[0]=gfx.load("cv1_bigbat1")
gfx.bigbat[1]=gfx.load("cv1_bigbat2")
gfx.bigbat[2]=gfx.load("cv1_bigbat3")
gfx.bone = {}
gfx.bone[0]=gfx.load("cv2_bone1")
gfx.bone[1]=gfx.load("cv2_bone2")
gfx.bone[2]=gfx.load("cv2_bone3")
gfx.axe = {}
gfx.axe[0] = gfx.load("axe1")
gfx.axe[1] = gfx.load("axe2")
gfx.axe[2] = gfx.load("axe3")
gfx.axe[3] = gfx.load("axe4")
gfx.candles = {}
gfx.candles[0]=gfx.load("cv1candle1_1")
gfx.candles[1]=gfx.load("cv1candle1_2")
gfx.block = gfx.load("block")
gfx.medusa = {
    {gfx.load("medusa1"), gfx.load("medusa2")},
    {gfx.load("medusa1h"), gfx.load("medusa2h")},
}
gfx.castle = gfx.load("castle")
gfx.fleaman = {
    {gfx.load("fleaman1"),  gfx.load("fleaman2")},
    {gfx.load("fleaman1h"),  gfx.load("fleaman2h")},
}
gfx.bigheart = gfx.load("bigheart")
gfx.heart = gfx.load("heart")
gfx.moneybag = gfx.load("moneybag")
gfx.wallchicken = gfx.load("wallchicken")


mnu.cursor_image=gfx.cv2heart.image
if type(mnu.cursor_image)=="userdata" then
    mnu.cursor_image = mnu.cursor_image:gdStr()
end

getfilecontents=oldgetfilecontents


local itemList = {}


local ignoreErrors = false
local useGD = false


if not rom.writebyte then
    spidey.error = function()
        gui.drawrect(0,8,spidey.screenWidth-1,spidey.screenHeight-1, "#00000080")
        gui.text(0+8*2, 8+8*10, "Error: please update FCEUX version.","white","clear")
    end
end


-- We don't need movie.record for this script, but since the current 2.2.3 release
-- has all kinds of problems with this script I'll use it as a test that we're
-- using a more recent build of FCEUX.  It was added 2018-11-30, so that's our 
-- minimum for now.
if (not movie.record) and (not config.ignoreVersionWarning) then
    local inp, lastinp
    inp=input.read()
    spidey.error = function()
        gui.drawbox(0,0,spidey.screenWidth-1,spidey.screenHeight-1,"#00000070", "#ffffff30")
        gui.drawbox(0,8*3+20,spidey.screenWidth-1,8*16,"#706090b0", "#807070a0")
        gui.text(20,60,"ERROR: Please upgrade FCEUX to a more \nrecent build from:", "white", "clear")
        gui.text(20,60+8*3,"https://ci.appveyor.com/project/zeromus/fceux/\nbuild/artifacts", "#ccccff", "clear")
        
        lastinp=inp
        inp = input.read()
        local x,y = 18,8*11+20
        
        if inp.xmouse>=x and inp.xmouse<=x+8*12 and inp.ymouse>=y and inp.ymouse<=y+8+4 then
            gui.drawbox(x,y,  x+8*12,y+8+4,  "#bbbbcc", "#888888")
            gui.text(x+28,y+2,"Download", "#ffffff", "clear")
            
            if lastinp.leftclick and not inp.leftclick then
                spidey.message("click")
                winapi.shell_exec('open','https://ci.appveyor.com/project/zeromus/fceux/build/artifacts')
            end
        else
            gui.drawbox(x,y,  x+8*12,y+8+4,  "#FFFFFF", "#888888")
            gui.text(x+28,y+2,"Download", "#808080", "clear")
        end
    end
end


--            if not spidey.reloadfile() then
--                spidey.error = function()
                    --#000040d0
--                    gui.drawbox(0,0,spidey.screenWidth-1,spidey.screenHeight-1,"#807070a0", "#807070a0")
--                    gui.text(20,40,"ERROR: Could not test MD5 properly. Please \nupgrade FCEUX to at least 2.2.3.", "white", "clear")
--                end
--                config.md5=false
--            end



if useGD then
    if not pcall(function()
        require "gd"
    end) then
        gd = nil
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
--    local g = gd.createFromPng("cv2/images/whitecrystal.png"):gdStr()
--    spidey.writeToFile('cv2/images/whitecrystal.gd', g)
--    local g = gd.createFromPng("cv2/images/bluecrystal.png"):gdStr()
--    spidey.writeToFile('cv2/images/bluecrystal.gd', g)
    
    --local g = getfilecontents("spidey.output.gd")
    
--    for i=1,10 do
--        local g = gd.createFromPng(string.format("cv2/images/gold_treasure_icons_16x16/%d.png",i)):gdStr()
--        spidey.writeToFile(string.format("cv2/images/gold%d.gd",i), g)
--    end
    
    if false then
    for _,f in ipairs(gfxFileList) do
        local img = gd.createFromGd(f)
        
        f=string.gsub(f, "cv2/images", "cv2/images/png")
        f=string.gsub(f, "%.gd", "%.png")
        img:saveAlpha(false)
        img:png(f)
    end
    end
    
    --emu.message(type(gd))
    
    
    local convert=function(f)
        local img = gd.createFromPng("cv2/images/png/"..f)
        local newFile = string.gsub(f, "%.png", "%.gd")
        img:gd("cv2/images/gd/"..newFile)
    end
    
--    convert("fleaman1.png")
--    convert("fleaman2.png")
--    convert("fleaman1h.png")
--    convert("fleaman2h.png")
--    convert("bigheart.png")
--    convert("heart.png")
--    convert("bigheart.png")
--    convert("wallchicken.png")
--    convert("moneybag.png")
    
--    f="fleaman1h.png"
--    local img = gd.createFromPng("cv2/images/png/"..f)
--    local newFile = string.gsub(f, "%.png", "%.gd")
--    img:gd("cv2/images/gd/"..newFile)
--    f="fleaman2h.png"
--    local img = gd.createFromPng("cv2/images/png/"..f)
--    local newFile = string.gsub(f, "%.png", "%.gd")
--    img:gd("cv2/images/gd/"..newFile)
    
--    f="medusa1h.png"
--    local img = gd.createFromPng("cv2/images/png/"..f)
--    local newFile = string.gsub(f, "%.png", "%.gd")
--    img:gd("cv2/images/gd/"..newFile)
--    f="medusa2h.png"
--    local img = gd.createFromPng("cv2/images/png/"..f)
--    local newFile = string.gsub(f, "%.png", "%.gd")
--    img:gd("cv2/images/gd/"..newFile)

--    f="castle.png"
--    local img = gd.createFromPng("cv2/images/png/"..f)
--    local newFile = string.gsub(f, "%.png", "%.gd")
--    img:gd("cv2/images/gd/"..newFile)

    
    -- dump all png to gd
    if false then
    for _,f in ipairs(gfx.fileList) do
        local img = gd.createFromPng("cv2/images/png/"..f)
        local newFile = string.gsub(f, "%.png", "%.gd")
        
        img:saveAlpha(true)
        img:gd("cv2/images/gd/"..newFile)
    end
    end
    
    
--    local img = gd.createFromPng("cv2/images/png/slash.png")
--    writetofile("cv2/images/png/slash.txt",spidey.bin2hex(img:gdStr()))
    
--    local img = gd.createFromPng("cv2/images/gold_treasure_icons_16x16/3.png")
--    img:saveAlpha(false)
--    img:gd2("cv2/images/png/goldtest.gd2", 0,gd.GD2_FMT_RAW)
--    img:gd("cv2/images/png/goldtest.gd")

    
    --local img = gd.createFromGd2("cv2/images/png/goldtest.gd2")
--    local img = gd.createFromGd("cv2/images/png/goldtest.gd")
--    img:saveAlpha(true)
--    img:png("cv2/images/png/goldtest2.png")

--    local img = gd.createFromGd("SpiderDave/output.gd")
--    img:saveAlpha(0)
--    img:alphaBlending(0)
    
--    local im = gd.createTrueColor(48, 32)
--    im:saveAlpha(true)
--    im:alphaBlending(false)
--    gd.copy(im, img, 0,0,0,0,48,32)
--    im:png("cv2/images/png/test2.png")
    
--    if img:getTransparent() then emu.message("yes") end

--    img:saveAlpha(true)
--    img:alphaBlending(false)
    
--    img:png("cv2/images/png/bat_test.png")

    
    
    
    
    --gfx.arrowcursor = gd.createFromPng("cv2/images/arrowcursor.png"):gdStr()
    --gfx.holywater.new = gd.createFromPng("cv2/images/holywater_new.png"):gdStr()
    --gfx.items.bag = gd.createFromPng("cv2/images/bag.png"):gdStr()
    --gfx.items.cross = gd.createFromPng("cv2/images/cross.png"):gdStr()
    --gfx.block = gd.createFromPng("cv2/images/block.png"):gdStr()
    --spidey.writeToFile('cv2/images/holywater_new.gd', gfx.holywater.new)
    --spidey.writeToFile('cv2/images/bag.gd', gfx.items.bag)
    --spidey.writeToFile('cv2/images/cross.gd', gfx.items.cross)
    --spidey.writeToFile('cv2/images/block.gd', gfx.block)
    --spidey.writeToFile('cv2/images/arrowcursor.gd', gfx.arrowcursor)
    --local img
    --img = gd.createFromGdStr(gfx.relics[6])
    --img:png("cv2/images/redcrystal.png")
    --img = gd.createFromGdStr(gfx.holywater.test)
    --img = gd.createFromGdStr(gfx.weapons[4])
    --img:png("cv2/images/output2.png")
end


refight_bosses=config.refightBosses
relics={}
relics.names = cv2data.relics.names
relics.list = {}
relics.on = {}

weapons={}
weapons.gfx={}

local locations = cv2data.locations

objects = {}
objects.count=12
objects.player = {}
objects.boss={}

objects.player.gold = 0
objects.player.maxHearts = config.maxHearts or 99
objects.player.clues = {}
objects.player.loop = 0

for i=0,objects.count-1 do
    objects[i]={}
end


objects.player.bossdoor=function()
    --Don't let player leave room
    n=0x17
    if objects.player.x<0+n then objects.player.x=0+n end
    if objects.player.x>255-n then objects.player.x=255-n end
    if objects.player.y<0+n then objects.player.y=0+n end
    if objects.player.y>255-n then objects.player.y=255-n end
    memory.writebyte(0x0348, objects.player.x)
    memory.writebyte(0x0324, objects.player.y)
    objects.player.inBossRoom=true
end

objects.whip={}
objects.whip[0]={}
objects.whip[1]={}
objects.weapons={}
objects.weapons[0]={}
objects.weapons[1]={}
objects.weapons[2]={}

objects.custom={}
objects.custom.count=500
objects.custom.destroyall=function()
    for i=0,objects.custom.count-1 do
        if objects.custom[i] and objects.custom[i].deSpawn then
            objects.custom[i].deSpawn()
        end
        objects.custom[i]={custom=true, type='',active=0,x=0,y=0}
    end
end

objects.custom.destroyall()

objects.custom.isOnScreen=function(i)
    if not objects.custom[i].area then return false end
    return (area1==objects.custom[i].area[1] and area2==objects.custom[i].area[2] and area3==objects.custom[i].area[3] and areaFlags==(objects.custom[i].area[4] or areaFlags))
end

function saveCandles()
    local out = "local candles = {\n"
    local formatText = '    {x=0x%02x, y=0x%02x, area = {0x%02x,0x%02x,0x%02x,0x%02x}, floor=0x%02x, location="%s", item="%s" },\n'
    for _,c in ipairs(candles) do
        if c.item then
            formatText = '    {x=0x%02x, y=0x%02x, area = {0x%02x,0x%02x,0x%02x,0x%02x}, floor=0x%02x, location="%s", item="%s", },\n'
            out = out..string.format(formatText, c.x,c.y,c.area[1],c.area[2],c.area[3],c.area[4],c.floor,c.location, c.item)
        else
            formatText = '    {x=0x%02x, y=0x%02x, area = {0x%02x,0x%02x,0x%02x,0x%02x}, floor=0x%02x, location="%s", },\n'
            out = out..string.format(formatText, c.x,c.y,c.area[1],c.area[2],c.area[3],c.area[4],c.floor,c.location)
        end
    end
    out=out.."}\n\nreturn candles\n"
    
    --writetofile('cv2/candles.backup.lua', spidey.getFileContents("cv2/candles.lua"))
    writetofile('cv2/candles.lua', out)
    --emu.message("Candles exported to cv2/candles.lua")
end

function collision(t1,t2)
    if not t1 or not t2 then return end
    if #t1+#t2 ~=8 then return end
    
    if t1[1]>t1[3] then t1[1],t1[3] = t1[3],t1[1] end
    if t1[2]>t1[4] then t1[2],t1[4] = t1[4],t1[2] end
    
    if t2[1]>t2[3] then t2[1],t2[3] = t2[3],t2[1] end
    if t2[2]>t2[4] then t2[2],t2[4] = t2[4],t2[2] end
    
    return t1[1] < t2[3] and
         t2[1] < t1[3] and
         t1[2] < t2[4] and
         t2[2] < t1[4]
end


objects.custom.createCandles = function()
    for k,v in ipairs(candles) do
        local candle = createObject("candle", v.x, v.y)
        candle.area = {
                [1]=v.area[1],
                [2]=v.area[2],
                [3]=v.area[3],
                [4]=v.area[4],
        }
        candle.outscreen = true
        candle.floor = v.floor
        candle.item = v.item
    end
end

objects.custom.createLevelObjects = function()
    for k,v in ipairs(levelObjects) do
        local i=getunusedcustom()
        if i then
            objects.custom[i].type = v.type
            objects.custom[i].area = {
                [1]=v.area[1],
                [2]=v.area[2],
                [3]=v.area[3],
                [4]=v.area[4],
            }
            objects.custom[i].x = v.x
            objects.custom[i].y = v.y
            objects.custom[i].outscreen = v.outscreen
            objects.custom[i].active = v.active
            objects.custom[i].itemName = v.name
        end
    end
end


--converts unsigned 8-bit integer to signed 8-bit integer
function signed8bit(_b)
if _b>255 or _b<0 then return false end
if _b>127 then return (255-_b)*-1 else return _b end
end

function getunusedcustom()
    local dummy, i = createObject(nil, 0,0)
    return i
end

function getCustomCount(t)
    local count=0
    for k,v in ipairs(objects.custom) do
        if v.active==1 and v.type==t then
            count=count+1
        end
    end
    return count
end

function isCustomDuplicate(i)
    for k,v in ipairs(objects.custom) do
        if k~=i and v.active==1 and v.type==objects.custom[i].type then
            if v.originX == objects.custom[i].originX and v.originY == objects.custom[i].originY then
                return true
            end
        end
    end
    return false
end



function destroyEnemies()
    for i=0,objects.count-1 do
        memory.writebyte(0x03ba+i,0)
        memory.writebyte(0x0306+i,0)
    end
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

function newGamePlus()
    itemList = {}
    objects.player.hearts = config.hearts or 5
    objects.player.maxHearts = config.maxHearts or 99
    objects.player.lives = config.lives
    objects.player.hp = objects.player.maxHp
    objects.player.level = 0
    memory.writebyte(0x0086, 0x12) -- time1
    memory.writebyte(0x0085, 0x00) -- time2
    relics.main = 0
    relics.list = {}
    relics.on = {}
    subScreen.relic = 0
    relics.current = 0
    weapons.current = 0
    objects.player.gold = 0
    objects.player.items = 0
    objects.player.exp = 0
    objects.player.laurels = 0
    objects.player.garlic = 0
    area1 = 0
    area2 = 0
    area3 = 0
    areaFlags = 0
    returnArea = 0
    returnScroll1 = 0
    returnScroll2 = 0
    returnX = 0
    returnY = 0
    
    getItem("Red Plate", false)
    getItem("Leather Whip", false)
    
    getItem("Charm", false)
    
    setArmor(items.index["Red Plate"])
    setWhip(items.index["Leather Whip"])
    setWeapon(0)
    setAccessory(items.index["Charm"])
    objects.player.clues = {}
    objects.player.loop = objects.player.loop + 1
    memory.writebyte(0x7619, objects.player.loop)
end

function saveGame(slot)
    slot = slot or 1
    
    local itemList2 = {}
    for k,v in ipairs(itemList) do
        --itemList2[#itemList2+1] = {v.name, v.type, v.amount}
        --itemList2[#itemList2+1] = {name=v.name, type=v.type, amount=v.amount}
        itemList2[#itemList2+1] = {index=v.index}
    end
    
    local saveData = {
        hearts = objects.player.hearts,
        maxHearts = objects.player.maxHearts,
        hp = objects.player.hp,
        maxHp = objects.player.maxHp,
        whip = objects.player.whip,
        level = objects.player.level,
        time1=memory.readbyte(0x0086),
        time2=memory.readbyte(0x0085),
        day = day,
        relics = relics.main,
        relicsList = relics.list,
        relicsOn = relics.on,
        subScreenRelic = subScreen.relic or relics.current,
        relicsCurrent = relics.current,
        weapon = weapons.current,
        gold = objects.player.gold,
        items = objects.player.items,
        lives = objects.player.lives,
        exp = objects.player.exp,
        laurels = objects.player.laurels,
        garlic = objects.player.garlic,
        area1=area1,
        area2=area2,
        area3=area3,
        areaFlags=areaFlags,
        returnArea = returnArea,
        returnScroll1 = returnScroll1,
        returnScroll2 = returnScroll2,
        returnX=returnX,
        returnY=returnY,
        whipItem = objects.player.whipItem,
        weaponItem = objects.player.weaponItem,
        armor=objects.player.armor,
        accessory=objects.player.accessory,
        itemList = itemList2,
        clues = objects.player.clues,
        loop = objects.player.loop
    }
    
    local t= TSerial.pack(saveData)
    writetofile(string.format("cv2/SaveGame%d.dat",slot), t)
    if game.saveCache then
        game.saveCache[game.saveSlot] = nil
    end
    emu.message("saved. "..slot)
end

function getGameSaveData(slot)
    slot=slot or 1
    if not util.fileExists(string.format("cv2/SaveGame%d.dat",slot)) then return false end
    local saveData = TSerial.unpack(getfilecontents(string.format("cv2/SaveGame%d.dat",slot)))
    return saveData
end

function loadGame(slot, setArea)
    slot=slot or 1
    --emu.message(slot)

    game.saveSlot = slot
    memory.writebyte(0x7400, game.saveSlot)

    if not util.fileExists(string.format("cv2/SaveGame%d.dat",slot)) then return false end
    
    local saveData = TSerial.unpack(getfilecontents(string.format("cv2/SaveGame%d.dat",slot)))
    
    objects.player.hearts = saveData.hearts
    objects.player.maxHearts = saveData.maxHearts
    objects.player.hp = saveData.hp
    objects.player.maxHp = saveData.maxHp
    objects.player.whip = saveData.whip
    objects.player.level = saveData.level
    local time1 = saveData.time1
    local time2 = saveData.time2
    day = saveData.day
    relics.main = saveData.relics
    relics.list = saveData.relicsList
    relics.on = saveData.relicsOn
    subScreen.relic = saveData.subScreenRelic
    relics.current = saveData.relicsCurrent
    weapons.current = saveData.weapon
    objects.player.gold = saveData.gold
    objects.player.items = saveData.items
    objects.player.lives = saveData.lives
    objects.player.exp = saveData.exp
    objects.player.laurels = saveData.laurels
    objects.player.garlic = saveData.garlic
    objects.player.weaponItem = saveData.weaponItem
    objects.player.whipItem = saveData.whipItem
    objects.player.armor = saveData.armor
    objects.player.accessory = saveData.accessory
    --itemList = saveData.itemList or itemList
    itemList = saveData.itemList
    
    area1=saveData.area1
    area2=saveData.area2
    area3=saveData.area3
    returnArea = saveData.returnArea
    areaFlags = saveData.areaFlags or 1
    returnScroll1 = saveData.returnScroll1
    returnScroll2 = saveData.returnScroll2
    returnX = saveData.returnX
    returnY = saveData.returnY
    
    objects.player.clues = saveData.clues or {}
    objects.player.loop = saveData.loop or 0
    
    --subScreen.relic = relics.current
    
    setHearts(objects.player.hearts)
    memory.writebyte(0x0080, objects.player.hp)
    memory.writebyte(0x0081, objects.player.maxHp)
    memory.writebyte(0x0434, objects.player.whip)
    memory.writebyte(0x008b, objects.player.level)
    memory.writebyte(0x0086, time1)
    memory.writebyte(0x0085, time2)
    memory.writebyte(0x0083, day)
    memory.writebyte(0x0091, relics.main)
    memory.writebyte(0x004F, relics.current)

    for i,v in ipairs(cv2data.relics) do
        if relics.list[v.varName] then
            setRelicState(v.varName, relics.on[v.varName])
        end
    end

    memory.writebyte(0x0090, weapons.current)
    
    memory.writeword(0x7000+1, objects.player.gold)
    memory.writebyte(0x004a, objects.player.items % 0x100)
    memory.writebyte(0x0092, (objects.player.items - (objects.player.items % 0x100))/0x100)
    memory.writebyte(0x0031, objects.player.lives)
    
    local e = tonumber(string.format("%04d",objects.player.exp),16)
    memory.writebyte(0x46, e % 0x100)
    memory.writebyte(0x47, (e-(e % 0x100))/0x100)
    
    memory.writebyte(0x004c, objects.player.laurels)
    memory.writebyte(0x004d, objects.player.garlic)
    
    
    setWeapon(objects.player.weaponItem)
    setWhip(objects.player.whipItem)
    setArmor(objects.player.armor)
    setAccessory(objects.player.accessory)
    
    updateItems()
    
    game.setArea = setArea
    if game.setArea==true then
        -- need to make this work better form pause menu
        --memory.writebyte(0x0026,0) -- unpause
        memory.writebyte(0x0030, area1)
        memory.writebyte(0x0050, area2)
        memory.writebyte(0x0051, area3)
        memory.writebyte(0x004e, returnArea)
        memory.writebyte(0x0458, returnScroll1)
        memory.writebyte(0x046a, returnScroll2)
        memory.writebyte(0x4a0, returnX)
        memory.writebyte(0x4b2, returnY)
    end
    --emu.message("loaded "..slot)
    subScreen.subMenu.scrollY = 0
    return true
end

function hasInventoryItem(n)
    for k,v in ipairs(itemList) do
        if v.name == n then return true end
    end
    return false
end

function getInventoryIndex(n)
    for i,v in ipairs(itemList) do
        if v.name == n then return i end
    end
    return false
end

function removeItem(name, amount)
    amount=amount or 1
    local newList = {}
    
    for _,item in ipairs(itemList) do
        if item.name==name then
            if ((item.stack or 0)> 0) and (item.amount or 0)-amount>0 then
                item.amount=(item.amount or 0)-amount
                newList[#newList+1] = item
            else
                if item.index==objects.player.weaponItem then
                    objects.player.weaponItem = nil
                    weapons.current=0
                    setWeapon(0)
                end
            end
        else
            newList[#newList+1] = item
        end
    end
    itemList = newList
    updateItems()
end

function equipItem(itemName)
    --spidey.message("equip")
    local item = items[items.index[itemName]]
    if item.type=="armor" then setArmor(item.index) end
    if item.type=="whip" then setWhip(item.index) end
    if item.type=="weapon" then setWeapon(item.index) end
    if item.type=="accessory" then setAccessory(item.index) end
    updateItems()
end

function getItem(n, showMessage, delay)
    if delay then
        game.getItemDelayed = n
        if type(delay) == "number" then
            game.getItemDelayCounter=delay
        else
            game.getItemDelayCounter=0x10
        end
        return
    end

    if not items.index[n] then
        --if showMessage then emu.message(string.format("you got %s", n)) end
        if showMessage then createItemPopUp(n) end
        return
    end
    
    local item = items[items.index[n]]
    
    if item.name == "Grab Bag" then
        for k,v in ipairs(item.bagList) do
            getItem(v, true)
        end
        return
    end
    
    if item.type =="gold" then
        sound:play("getMoneyBag")
        objects.player.gold = objects.player.gold+item.gold
        memory.writeword(0x7000+1, objects.player.gold)
        --if showMessage then emu.message(string.format("you got %d gold.", item.gold or 0)) end
        if showMessage then createItemPopUp(string.format("%d gold",item.gold or 0)) end
        return
    elseif item.type =="food" then
        objects.player.hp=math.min(objects.player.maxHp, objects.player.hp+(item.hp or 1))
        memory.writebyte(0x0080, objects.player.hp)

        --if showMessage then emu.message(string.format("you got %s.", item.name)) end
        if showMessage then createItemPopUp(item.name) end
        return
    end
    
    if hasInventoryItem(n) then
        if (item.stack or 0) > 0 then
            itemList[getInventoryIndex(item.name)].amount = (itemList[getInventoryIndex(item.name)].amount or 0) + 1
        end
        updateItems()
    else
        itemList[#itemList+1]={name=n}
        if (item.stack or 0) > 0 then
            itemList[#itemList].amount = 1
        end
        updateItems()
    end
    --if showMessage then emu.message(string.format("you got %s", item.name)) end
    if showMessage then createItemPopUp(item.shortName) end
end

function sortItems()
    updateItems()
    
    local newList = {}
    local types={"weapon", "use", "whip", "armor", "accessory"}

    for i=1,#itemList do
        local inList = false
        for k,v in ipairs(types) do
            if itemList[i].type == v then
                inList = true
            end
        end
        if not inList then
            types[#types+1] = v
        end
    end
    
    for _,t in ipairs(types) do
        for i=1,#itemList do
            if itemList[i].name and itemList[i].type==t then
                newList[#newList+1] = itemList[i]
            end
        end
    end
    itemList = newList
    updateItems()
end

function updateItems()
    -- wipe list in memory
    for i=0,255 do
        memory.writebyte(0x7200+i*2, 0)
        memory.writebyte(0x7200+i*2+1, 0)
    end
    
    -- update data for items
    for i=1,#itemList do
        if itemList[i].name and not itemList[i].type then
            local amount = itemList[i].amount
            local index = items.index[itemList[i].name]
            if index then
                itemList[i] = items[index]
                itemList[i].amount = amount
            end
        elseif itemList[i].index then
            if items[itemList[i].index] then
                itemList[i] = items[itemList[i].index]
            end
        end
        
        if itemList[i].type=="weapon" then
            --itemList[i].name = cv2data.weapons[itemList[i].weaponIndex].name
            itemList[i].gfx = gfx.weapons[itemList[i].weaponIndex]
        end
        
        if itemList[i].name=="Cross" then
            itemList[i].gfx = gfx.items.cross
        end
        
        if itemList[i].type=="whip" then
            itemList[i].gfx = gfx.whipicon
            if itemList[i].name == "Thief's Dagger" then
                itemList[i].gfx = gfx.weapons[3]
            end
        end
    end
    
    -- add items and write to memory
    for i,v in ipairs(itemList) do
        local itemIndex
        local itemAmount
        if v.name then
            itemIndex = items.index[v.name] or 0
            itemAmount = v.amount or 1
        else
            itemIndex = 0
            itemAmount = 0
        end
        memory.writebyte(0x7200+i*2-2, itemIndex)
        memory.writebyte(0x7200+i*2-2+1, itemAmount)
    end
end

function getExtraData()
    itemList = {}
    if memory.readbyte(0x7000) ~= 0x42 then
        --emu.message("init")
        -- initialize
        for i=1,0x1000-1 do
            memory.writebyte(0x7000+i,0)
        end
        memory.writebyte(0x7000,0x42)
        
        relics.list = {}
        relics.list.rib = (relics.main == bit.bor(relics.main, 0x01))
        relics.list.heart = (relics.main == bit.bor(relics.main, 0x02))
        relics.list.eye = (relics.main == bit.bor(relics.main, 0x04))
        relics.list.nail = (relics.main == bit.bor(relics.main, 0x08))
        relics.list.ring = (relics.main == bit.bor(relics.main, 0x10))
        relics.list.allParts = (relics.list.rib and relics.list.heart and relics.list.eye and relics.list.nail and relics.list.ring)
        relics.list.whiteCrystal = (relics.main == bit.bor(relics.main, 0x20))
        relics.list.blueCrystal = (relics.main == bit.bor(relics.main, 0x40))
        
        -- red crystal gives white and blue when initializing
        if relics.list.redCrystal then
            relics.list.blueCrystal = true
        end
        if relics.list.blueCrystal then
            relics.list.whiteCrystal = true
        end
        
        for i,v in ipairs(cv2data.relics) do
            if relics.list[v.varName] then
                relics.on[v.varName] = true
                setRelicState(v.varName, true)
            end
        end
--        relics.list.whiteCrystal = true
--        relics.list.blueCrystal = true
--        setRelicState("whiteCrystal", true)
--        setRelicState("blueCrystal", true)
        itemList = {
            {name = "Red Plate"},
        }
        
        for i = 0, objects.player.whip do
            itemList[#itemList+1] = {name = cv2data.whips.names[i]}
        end
        
        for i,v in ipairs(items) do
            if v.weaponIndex and hasItem(v.weaponIndex) then
                itemList[#itemList+1] = {name = v.name}
            end
        end
        
        objects.player.gold = 50
        memory.writeword(0x7000+1, objects.player.gold)
        
        if game.saveSlot <0 then game.saveSlot = 0 end
        memory.writebyte(0x7400, game.saveSlot)
        --if game.saveSlot == 0 then emu.pause() end
        --emu.message(string.format("%02x %02x",game.saveSlot,memory.readbyte(0x7400)))
        --emu.message(game.saveSlot)

        objects.player.loop = 0
        memory.writebyte(0x7619, objects.player.loop)
    end
    objects.player.gold = memory.readword(0x7000+1)
    --0x7003 = msgMode
    --0x7004 = msgChoice
    --0x700a = armor
    --0x700b = whip
    --0x700c = weapon
    --0x700d = accessory
    --0x700e = (reserved / accessory2)
    --0x7014 to 0x701b = relics list
    --0x701e to 0x7025 = relics on/off state
    --0x7200 to 0x73ff items
    --0x7400 = save slot
    --0x7401 to 0x740e = clues
    --0x7410 reset counter
    --0x7500 sfx thing
    --0x7600 to 0x7618 enemy alivetime counters (two bytes each, 12 of them)
    --0x7619 game loop
    
    for i,v in ipairs(cv2data.relics) do
        if memory.readbyte(0x7000+20+i-1)==1 then
            relics.list[v.varName] = true
        else
            relics.list[v.varName] = false
        end
    end
    
    relics.main = 0
    if relics.list.rib then relics.main = bit.bor(relics.main, 0x01) end
    if relics.list.heart then relics.main = bit.bor(relics.main, 0x02) end
    if relics.list.eye then relics.main = bit.bor(relics.main, 0x04) end
    if relics.list.nail then relics.main = bit.bor(relics.main, 0x08) end
    if relics.list.ring then relics.main = bit.bor(relics.main, 0x10) end
    if relics.list.whiteCrystal then relics.main = bit.bor(relics.main, 0x20) end
    if relics.list.blueCrystal then
        -- this removes the white crystal
        relics.main = bit.bor(relics.main, 0x60)-0x20
    end
    if relics.list.redCrystal then
        relics.main = bit.bor(relics.main, 0x60)
    end


    memory.writebyte(0x0091, relics.main)
    
    for i,v in ipairs(cv2data.relics) do
        if memory.readbyte(0x7000+30+i-1)==1 then
            relics.on[v.varName]=true
        else
            relics.on[v.varName]=not true
        end
    end
    updateVisibleBlocks()

    setArmor(memory.readbyte(0x7000+10))
    setWhip(memory.readbyte(0x7000+11))
    setWeapon(memory.readbyte(0x7000+12))
    setAccessory(memory.readbyte(0x7000+13))
    msgChoice=memory.readbyte(0x7000+4)
    -- 7100-71ff = msg stuff
    -- 7200-72ff = items
    game.saveSlot = memory.readbyte(0x7400)
    --emu.message(game.saveSlot)
    
    
    for i=0,255 do
        local itemIndex = memory.readbyte(0x7200+i*2)
        local itemAmount = memory.readbyte(0x7200+i*2+1)
        --itemAmount = 1
        if itemIndex~=0 then
            itemList[#itemList+1] = {name = items[itemIndex].name, amount=itemAmount}
        end
    end
    updateItems()
    
    if hasInventoryItem("Laurel") then
        memory.writebyte(0x004c, itemList[getInventoryIndex("Laurel")].amount or 0)
    else
        memory.writebyte(0x004c, 0)
    end
    if hasInventoryItem("Garlic") then
        memory.writebyte(0x004d, itemList[getInventoryIndex("Garlic")].amount or 0)
    else
        memory.writebyte(0x004d, 0)
    end
    
    -- 13 clues 0x7401 to 0x740e
    objects.player.clues = {}
    for i=1, 13 do
        objects.player.clues[i] = (memory.readbyte(0x7400+i)~=0)
    end
    
    objects.player.loop = memory.readbyte(0x7619)
end

function setArmor(n)
    objects.player.armor = n or objects.player.armor
    if (objects.player.armor or 0) == 0 then
        objects.player.armor = items.index["Red Plate"]
    end
    
    memory.writebyte(0x7000+10, objects.player.armor or 0)
    if objects.player.armor == 0 then 
        -- no armor
        objects.player.armor = nil
        objects.player.palette = cv2data.palettes.simon[1].palette
    else
        objects.player.palette = items[objects.player.armor].palette
    end
end

function setAccessory(n)
    objects.player.accessory = n or objects.player.accessory
    memory.writebyte(0x7000+13, objects.player.accessory or 0)
    if objects.player.accessory == 0 then 
        -- no accessory
        objects.player.accessory = nil
        --objects.player.palette = cv2data.palettes.simon[1].palette
    else
        --objects.player.palette = items[objects.player.armor].palette
    end

    if objects.player.accessory == items.index["Soul of Bat"] then
        if not objects.player.batMode then
            --objects.player.batMode=true
            --memory.writebyte(0x03b5,0xff) --help disable whip
        end
    elseif objects.player.batMode then
        objects.player.batMode = false
        -- reenable whip better
        whipframe=00
        memory.writebyte(0x0445,whipframe)
    end

end

function setWhip(n)
    objects.player.whipItem = n or objects.player.whipItem
    if (objects.player.whipItem or 0) == 0 then
        objects.player.whipItem = items.index["Leather Whip"]
    end

    --emu.message(string.format("setwhip %d",objects.player.whipItem))
    memory.writebyte(0x7000+11, objects.player.whipItem)
    if objects.player.whipItem == 0 then 
        -- no whip
        objects.player.whipItem = nil
        memory.writebyte(0x0434, 0)
    else
        memory.writebyte(0x0434, items[objects.player.whipItem].whipBase)
    end
end

function setWeapon(n)
    objects.player.weaponItem = n or objects.player.weaponItem
    memory.writebyte(0x7000+12, objects.player.weaponItem or 0)
    if not items[objects.player.weaponItem] then
    --if objects.player.weaponItem == 0 then 
        -- no weapon
        objects.player.weaponItem = nil
        weapons.current=0
        memory.writebyte(0x0090, weapons.current)
    else
        weapons.current=items[objects.player.weaponItem].weaponBase or items[objects.player.weaponItem].weaponIndex or 0
        memory.writebyte(0x0090, weapons.current)
    end
end

function numClues()
    local n=0
    for k,clue in ipairs(objects.player.clues) do
        if clue then n=n+1 end
    end
    return n
end

function setRelic(n)
    relics.current = n or relics.current or 0
    subScreen.relic = relics.current
    
    -- 6,7,8 all use relic slot
    memory.writebyte(0x004F, math.min(6, relics.current))
end

function setRelicState(r,state)
    relics.on[r] = not not state
    for i,v in ipairs(cv2data.relics) do
        if relics.list[v.varName] then
            memory.writebyte(0x7000+20+i-1, 1)
        else
            memory.writebyte(0x7000+20+i-1, 0)
        end
    end
    for i,v in ipairs(cv2data.relics) do
        if relics.on[v.varName] then
            memory.writebyte(0x7000+30+i-1, 1)
        else
            memory.writebyte(0x7000+30+i-1, 0)
        end
    end
    updateVisibleBlocks()
end

function updateVisibleBlocks()
--    for _,v in ipairs(cv2data.mansions) do
    
--    end
    for i=0,0x0f do
        --for bank = 0,9 do
        local bank = memory.readbyte(0x0101)
            if relics.on.eye then
                if inMansion then
                    if i<8 then
                        rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xd9+i, rom.readbyte(0x10+0x20000+bank*0x1000+0x10*0xd9+i+8))
                        rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xdb+i, rom.readbyte(0x10+0x20000+bank*0x1000+0x10*0xdb+i+8))
                        rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xda+i, rom.readbyte(0x10+0x20000+bank*0x1000+0x10*0xda+i+8))
                        rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xdc+i, rom.readbyte(0x10+0x20000+bank*0x1000+0x10*0xdc+i+8))
                    end
                end

--                rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xfb+i, rom.readbyte(0x10+0x28000+0x10*0x47+i))
--                rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xfd+i, rom.readbyte(0x10+0x28000+0x10*0x49+i))
--                rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xfc+i, rom.readbyte(0x10+0x28000+0x10*0x4b+i))
--                rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xfe+i, rom.readbyte(0x10+0x28000+0x10*0x4c+i))

--                rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xfb+i, rom.readbyte(0x10+0x28000+0x10*0xf2+i))
--                rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xfd+i, rom.readbyte(0x10+0x28000+0x10*0xf3+i))
--                rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xfc+i, rom.readbyte(0x10+0x28000+0x10*0xf2+i))
--                rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xfe+i, rom.readbyte(0x10+0x28000+0x10*0xf3+i))

                if i <8 then
                    rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xfb+i, bit.band(rom.readbyte(0x10+0x20000+bank*0x1000+0x10*0xfb+i), 0xff-rom.readbyte(0x10+0x20000+bank*0x1000+0x10*0xfb+i+8)))
                    rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xfd+i, bit.band(rom.readbyte(0x10+0x20000+bank*0x1000+0x10*0xfd+i), 0xff-rom.readbyte(0x10+0x20000+bank*0x1000+0x10*0xfd+i+8)))
                    rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xfc+i, bit.band(rom.readbyte(0x10+0x20000+bank*0x1000+0x10*0xfc+i), 0xff-rom.readbyte(0x10+0x20000+bank*0x1000+0x10*0xfc+i+8)))
                    rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xfe+i, bit.band(rom.readbyte(0x10+0x20000+bank*0x1000+0x10*0xfe+i), 0xff-rom.readbyte(0x10+0x20000+bank*0x1000+0x10*0xfe+i+8)))
                end

            else
                if inMansion then
                    rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xd9+i, rom.readbyte(0x10+0x28000+0x10*0xf6+i))
                    rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xdb+i, rom.readbyte(0x10+0x28000+0x10*0xf8+i))
                    rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xda+i, rom.readbyte(0x10+0x28000+0x10*0xf7+i))
                    rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xdc+i, rom.readbyte(0x10+0x28000+0x10*0xf9+i))
                end

                rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xfb+i, rom.readbyte(0x10+0x28000+0x10*0xf6+i))
                rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xfd+i, rom.readbyte(0x10+0x28000+0x10*0xf8+i))
                rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xfc+i, rom.readbyte(0x10+0x28000+0x10*0xf7+i))
                rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xfe+i, rom.readbyte(0x10+0x28000+0x10*0xf9+i))
            end
        --end
    end
end

function warpPlayer(w)
    if not w then return end
    area1=w.area1 or area1
    area2=w.area2 or area2
    area3=w.area3 or area3
    areaFlags=w.areaFlags or areaFlags
    returnArea=w.returnArea or returnArea
    returnScroll1=w.returnScroll1 or returnScroll1
    returnScroll2=w.returnScroll2 or returnScroll2
    returnX=w.returnX or returnX
    returnY=w.returnY or returnY
    objects.player.x=w.playerX or objects.player.x
    objects.player.y=w.playerY or objects.player.x
    scrollx=w.scrollX or scrollx
    scrolly=w.scrollY or scrollx
    
    if w.facing then
        objects.player.facing = w.facing
        memory.writebyte(0x0420, objects.player.facing)
    end
    
    
    
    memory.writebyte(0x0030, area1)
    memory.writebyte(0x0050, area2)
    memory.writebyte(0x0051, area3)
    memory.writebyte(0x008f, areaFlags)
    memory.writebyte(0x004e, returnArea)
    memory.writebyte(0x0458, returnScroll1)
    memory.writebyte(0x046a, returnScroll2)
    memory.writebyte(0x4a0, returnX)
    memory.writebyte(0x4b2, returnY)
    
    memory.writebyte(0x0348, objects.player.x)
    memory.writebyte(0x0324, objects.player.y)
    
    setScroll()

    memory.writebyte(0x2c, 1) -- reload screen
end


function setScroll(x,y)
    x = x or scrollx
    y = y or scrolly
    memory.writebyte(0x0053, x % 0x100)
    memory.writebyte(0x0054, (x-(x % 0x100))/0x100)
    memory.writebyte(0x0056, y % 0xe0)
    memory.writebyte(0x0057, (y-(y % 0xe0))/0xe0)
end

function getunused()
    for _i=0,objects.count-1 do
        if objects[_i].type==0 then
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
    local h = 14+2+1
    local w = 14+10+2
    local subScreenFont = 2
    local itemFont = 2
    gui.drawbox(x+28-9, y+28+1-8,x+ 24+8*w+10, 28+24+h*08+8+4, "black", "black")
    gui.drawbox(x+28-5, y+28-4, x+24+8*w+6,28+ 24+h*08+4+1+4, "black", borderColor)
    gui.drawbox(x+28-5-1, y+28-4+1, x+24+8*w+4+3, 28+24+h*08+4+1-1+4, "clear", borderColor)
    
    drawfont(x+28,y+28+8*1,font[subScreenFont], "Simon")
    drawfont(x+28+8*17,y+28+8*1,font[subScreenFont], string.format("Level %02d", objects.player.level+1))
    
    drawfont(x+28+8*16,y+28+8*17,font[itemFont], string.format("Lives: %02d",objects.player.lives-1))
    drawfont(x+28+8*0,y+28+8*19,font[subScreenFont], string.format("Day %d",day+1))
    drawfont(x+28+8*14,y+28+8*19,font[subScreenFont], string.format("Time: %s",time))
    
--    local s = string.format("%d/%d", objects.player.hp, objects.player.maxHp)
--    drawfont(x+28+8*11,y+28+8*4,font[subScreenFont], " HP:")
--    drawfont(x+28+8*(11+12-#s),y+28+8*4,font[subScreenFont], s)
    -- for now, draw a line to fix missing slash character
    --gui.drawline(x+28+8*20-2, y+28+8*4, x+28+8*19+1, y+28+8*5)
    
    --drawfont(x+28+8*11,y+28+8*5,font[subScreenFont], "Exp:    1234")
    
--    drawfont(x+28+8*11,y+28+8*5,font[subScreenFont], string.format("Exp:  %6d", getCurrentExp()))
--    drawfont(x+28+8*10,y+28+8*6,font[subScreenFont], string.format("Next:  %6d", objects.player.expNext))
    
    --gui.drawbox(x+28+8*0, y+28+8*9+3, x+28+8*23+6,y+28+8*9+4, "clear", borderColor)
    
    gui.drawbox(x+28+8*0, y+28+8*9+3, x+28+8*9,y+28+8*17+4, "clear", borderColor)
    
    --drawfont(x+28,y+28+8*8,font[itemFont], cv2data.whips.names[objects.player.whip])
    --drawfont(x+28+8*12,y+28+8*10,font[itemFont], cv2data.whips.names[objects.player.whip])
    
    local stats = getStats()
    drawfont(x+28+8*18,y+28+8*3,font[itemFont], string.format("ATT: %d\nDEF: %d", stats.atk, stats.def))
    drawfont(x+28+8*18,y+28+8*6,font[itemFont], string.format("STR: %d\nCON: %d\nINT: %d\nLCK: %d", stats.str, stats.con, stats.int, stats.luck))
    
    
    
    drawfont(x+44,y+28+8*10,font[itemFont], "Equip")
    drawfont(x+44,y+28+8*12,font[itemFont], "Relics")
    if numClues() > 0 then
        drawfont(x+44,y+28+8*14,font[itemFont], "Clues")
    else
        drawfont(x+44,y+28+8*14,font[itemFont], "----")
    end
    drawfont(x+44,y+28+8*16,font[itemFont], "Map")
    
    if objects.player.armor then
        drawInventoryItemName(x+8*13+1,y+28+8*11,getInventoryIndex(items[objects.player.armor].name))
    end
    if objects.player.whipItem then
        drawInventoryItemName(x+8*13+1,y+28+8*12,getInventoryIndex(items[objects.player.whipItem].name))
    end
    if objects.player.weaponItem then
        drawInventoryItemName(x+8*13+1,y+28+8*13,getInventoryIndex(items[objects.player.weaponItem].name))
    end
    if objects.player.accessory then
        drawInventoryItemName(x+8*13+1,y+28+8*14,getInventoryIndex(items[objects.player.accessory].name))
    end
    
    -- draw relics
--    for i=1,8 do
--        if hasRelic(i) then
--            gfx.draw(x+28+16*i-16,y+28+8*10,gfx.relics[i])
--        end
--    end
    
    
--    gfx.draw(x+28+8*0,y+28+8*10,gfx.relics[1])
--    gfx.draw(x+28+8*2,y+28+8*10,gfx.relics[2])
--    gfx.draw(x+28+8*4,y+28+8*10,gfx.relics[3])
--    gfx.draw(x+28+8*6,y+28+8*10,gfx.relics[4])
--    gfx.draw(x+28+8*8,y+28+8*10,gfx.relics[5])
--    gfx.draw(x+28+8*10,y+28+8*10,gfx.relics[6])
    
    --gfx.draw(x+28+(relics.current*16-16),y+28+8*9,gfx.arrowcursor)
    
    -- draw cursors
    --if subScreen.cursorY==1 or spidey.counter % 3==0 then
--    if subScreen.relic > 0 then
--        gui.drawbox(x+28+(subScreen.relic*16-16)-2,y+28+8*10-2,x+28+(subScreen.relic*16-16)+8+1,y+28+8*10+8+1,"clear","#0070ec")
--    end
    --if subScreen.cursorY==0 or spidey.counter % 3==0 then
    if ((spidey.counter %4<3) or config.noBlinkCursor) and not subScreen.showClues and not subScreen.showRelics then
        gfx.draw(x+28+4,y+28+8*8+16*subScreen.cursorY,gfx.arrowcursorRight)
        --gui.drawbox(x+28+(subScreen.cursorX*16-16)-2,y+28+8*8-2+16*subScreen.cursorY,x+28+(subScreen.cursorX*16-16)+8+1,y+28+8*8+8+1+16*subScreen.cursorY,"clear","blue")
    end
    
    --if subScreen.cursorY == 0 then subScreen.relic = subScreen.cursorX end
    
    -- laurels count
--    gfx.draw(x+28+8*0,y+28+8*6,gfx.weapons[8])
--    drawfont(x+28+8*1,y+28+8*6,font[itemFont], string.format(":%02d",objects.player.laurels or 0))
    
    -- garlic count
--    gfx.draw(x+28+8*0,y+28+8*7,gfx.weapons[9])
--    drawfont(x+28+8*1,y+28+8*7,font[itemFont], string.format(":%02d",objects.player.garlic or 0))
    
    --gfx.draw(x+28+8*19,y+28+8*11,gfx.items.bag)
    
    
    --local s = string.format("%d/%d", objects.player.hp, objects.player.maxHp)
    
    drawfont(x+28+8*0,y+28+8*3,font[itemFont], string.format("   HP: %d/%d",objects.player.hp, objects.player.maxHp))
    drawfont(x+28+8*0,y+28+8*4,font[itemFont], string.format("Heart: %02d",objects.player.hearts or 0))
    drawfont(x+28+8*0,y+28+8*5,font[subScreenFont], string.format("  Exp: %d", getCurrentExp()))
    drawfont(x+28+8*0,y+28+8*6,font[subScreenFont], string.format(" Next: %d", objects.player.expNext))
    drawfont(x+28+8*0,y+28+8*7,font[itemFont], string.format(" Gold: %d",objects.player.gold or 0))
    
    
    -- draw weapons and items
--    for i,v in ipairs(gfx.weapons) do
--        if hasItem(i) then
--            gfx.draw(x+28+8*(i*2-2),y+28+8*12,v)
--        end
--    end
--    if hasItem(8) then
--        gfx.draw(x+28+8*(10*2-2),y+28+8*12,gfx.items.cross)
--    end
--    if hasItem(7) then
--        gfx.draw(x+28+8*(11*2-2),y+28+8*12,gfx.items.bag)
--    end
    
    if not hasRelic(subScreen.relic) then
        relics.current=0
        subScreen.relic = 0
        -- Don't bother with this, it's obsolete
        --memory.writebyte(0x004F, relics.current or 0)
    end
    
    if subScreen.showClues then
        local x=2
        local y=5
        local h = 12
        local w = 14

        subScreen.clues = cv2data.clues
        subScreen.clue = subScreen.clue or 1
        --subScreen.clue = 5

        gui.drawbox(x+28-9, y+28+1-8,x+ 24+8*w+10, 28+24+h*08+8+4, "black", "black")
        gui.drawbox(x+28-5, y+28-4, x+24+8*w+6,28+ 24+h*08+4+1+4, "black", borderColor)
        gui.drawbox(x+28-5-1, y+28-4+1, x+24+8*w+4+3, 28+24+h*08+4+1-1+4, "clear", borderColor)
        
        --drawfont(x+28,y+28+1,font[subScreenFont], string.format("Clues %d/13", numClues()))
        drawfont(x+28,y+28+1,font[subScreenFont], "Clues")
        drawfont(x+28,y+28+1+8*2,font[subScreenFont], string.format("- %02d -",subScreen.clue))
        --if cv2data.clues[subScreen.clue] and objects.player.clues[subScreen.clue] then
        if cv2data.clues[subScreen.clue] and objects.player.clues[subScreen.clue] then
            local txt = cv2data.messages[subScreen.clues[subScreen.clue]][1].text
            --txt = txt:gsub("\n", "\n\n")
            drawfont(x+28,y+28+1+8*4,font[current_font], txt)
        end
    end
    if subScreen.showRelics then
        local x=2
        local y=5
        local h = 17
        local w = 19

        gui.drawbox(x+28-9, y+28+1-8,x+ 24+8*w+10, 28+24+h*08+8+4, "black", "black")
        gui.drawbox(x+28-5, y+28-4, x+24+8*w+6,28+ 24+h*08+4+1+4, "black", borderColor)
        gui.drawbox(x+28-5-1, y+28-4+1, x+24+8*w+4+3, 28+24+h*08+4+1-1+4, "clear", borderColor)
        
        drawfont(x+28,y+28+1,font[subScreenFont], "Relics")
        for i=1,8 do
            if hasRelic(i) then
                gfx.draw(x+28+8,y+28+8*(1+i*2),gfx.relics[i])
                drawfont(x+28+8*3,y+28+8*(1+i*2),font[itemFont], cv2data.relics[i].displayNameLong)
                
                if relics.on[cv2data.relics[i].varName] then
                    gui.drawbox(x+28+8*17,y+28+8*(1+i*2), x+28+8*17+6,y+28+8*(1+i*2)+6, "white", "#aaf")
                else
                    gui.drawbox(x+28+8*17,y+28+8*(1+i*2), x+28+8*17+6,y+28+8*(1+i*2)+6, "#333", "grey")
                end

            else
                drawfont(x+28+8*3,y+28+8*(1+i*2),font[itemFont], "----")
            end
        end
        subScreen.subMenu = subScreen.subMenu or {}
        subScreen.subMenu.y = subScreen.subMenu.y or 0
        
        gui.drawbox(x+28,y+28+8*(3+subScreen.subMenu.y*2)-4,x+28+8*18+4,y+28+8*(3+subScreen.subMenu.y*2)+8+4,"clear","blue")
    end
    if subScreen.showItems then
        local x=2
        local y=5
        local h = 20
        local w = 26
--        itemList = {
--            {name="Red Tunic"},
--            {name = "Leather Whip"},
--        }
--        itemList = {}
        
        -- give all items
--        for k,v in ipairs(items) do
--            itemList[#itemList+1]=v
--        end
        
--        for i=1,0x0a do
--            if hasItem(i) then
--                itemList[#itemList+1] = {type="weapon", weaponIndex=i}
--            end
--        end
        
        updateItems()
--        for i=1,#itemList do
--            if itemList[i].name and not itemList[i].type then
--                local index = items.index[itemList[i].name]
--                if index then
--                    itemList[i] = items[index]
--                end
--            elseif itemList[i].index then
--                if items.index[itemList[i].index] then
--                    itemList[i] = items[itemList[i].index]
--                end
--            end
            
--            if itemList[i].type=="weapon" then
--                itemList[i].name = cv2data.weapons[itemList[i].weaponIndex].name
--                itemList[i].gfx = gfx.weapons[itemList[i].weaponIndex]
--            end
            
--            if itemList[i].type=="whip" then
--                itemList[i].gfx = gfx.whipicon
--            end
--        end

        gui.drawbox(x+28-9, y+28+1-8,x+ 24+8*w+10, 28+24+h*08+8+4, "black", "black")
        gui.drawbox(x+28-5, y+28-4, x+24+8*w+6,28+ 24+h*08+4+1+4, "black", borderColor)
        gui.drawbox(x+28-5-1, y+28-4+1, x+24+8*w+4+3, 28+24+h*08+4+1-1+4, "clear", borderColor)
        
        drawfont(x+28,y+28+1,font[subScreenFont], "Items")
        for i=1+subScreen.subMenu.scrollY,8+subScreen.subMenu.scrollY do
            local y2 = i-subScreen.subMenu.scrollY
            if itemList[i] then
                if itemList[i].gfx then
                    gfx.draw(x+28+8*2,y+28+8*(1+y2*2),itemList[i].gfx)
                elseif itemList[i].palette then
                    gui.drawbox(x+28+8*2+1,y+28+8*(1+y2*2)-1+1, x+28+8*2+8-1,y+28+8*(1+y2*2)-1+8-1, spidey.nes.palette[itemList[i].palette[3]], spidey.nes.palette[itemList[i].palette[2]])
                else
                    gui.drawbox(x+28+8*2+1,y+28+8*(1+y2*2)-1+1, x+28+8*2+8-1,y+28+8*(1+y2*2)-1+8-1, "white", "clear")
                end
                if (itemList[i].stack or 0) >0 then
                    drawfont(x+28+8*3+4,y+28+8*(1+y2*2),font[itemFont], string.format("%s %d", itemList[i].name, itemList[i].amount or 0))
                else
                    local n = itemList[i].name
                    if n=="Laurel" then n=string.format("%s (%d)",n, objects.player.laurels) end
                    if n=="Garlic" then n=string.format("%s (%d)",n, objects.player.garlic) end
                    drawfont(x+28+8*3+4,y+28+8*(1+y2*2),font[itemFont], n)
                end
            else
                drawfont(x+28+8*3,y+28+8*(1+y2*2),font[itemFont], "----")
            end
        end
        
        
        local currentItem = itemList[subScreen.subMenu.scrollY+subScreen.subMenu.y+1]
        if currentItem and currentItem.desc then
            drawfont(x+28+8*0,y+28+8*20,font[itemFont], currentItem.desc)
        end
        
        
        
        subScreen.subMenu = subScreen.subMenu or {}
        subScreen.subMenu.y = subScreen.subMenu.y or 0
        
        --gui.drawbox(x+28,y+28+8*(3+subScreen.subMenu.y*2)-4,x+28+8*15,y+28+8*(3+subScreen.subMenu.y*2)+8+4,"clear","blue")
        if ((spidey.counter %4<3) or config.noBlinkCursor) and not subScreen.showClues and not subScreen.showRelics then
            gfx.draw(x+28+4,y+28+8*(3+subScreen.subMenu.y*2),gfx.arrowcursorRight)
        end
        
    end
    if subScreen.showDebug then
        local borderColor = "#ff3030"
        local x=2
        local y=5
        local h = 20
        local w = 26
        gui.drawbox(x+28-9, y+28+1-8,x+ 24+8*w+10, 28+24+h*08+8+4, "black", "black")
        gui.drawbox(x+28-5, y+28-4, x+24+8*w+6,28+ 24+h*08+4+1+4, "black", borderColor)
        gui.drawbox(x+28-5-1, y+28-4+1, x+24+8*w+4+3, 28+24+h*08+4+1-1+4, "clear", borderColor)
        
        local menuItems = {}
        for k,v in ipairs(game.debugMenuItems) do
            if v.tab==game.debugMenuTab then
                menuItems[#menuItems+1]=v
            end
        end
        
        if game.debugMenuTab=="main" then
            drawfont(x+28,y+28+1,font[subScreenFont], "Debug")
        else
            drawfont(x+28,y+28+1,font[subScreenFont], "Debug / "..game.debugMenuTab)
        end
        
        for i=1+subScreen.subMenu.scrollY,8+subScreen.subMenu.scrollY do
            local y2 = i-subScreen.subMenu.scrollY
            
            if menuItems[i] then
                if type(menuItems[i].text)=="function" then
                    drawfont(x+28+8*3,y+28+8*(1+y2*2),font[itemFont], menuItems[i].text())
                else
                    drawfont(x+28+8*3,y+28+8*(1+y2*2),font[itemFont], menuItems[i].text)
                end
            end
        end

        if (spidey.counter %4<3) or config.noBlinkCursor then
            gfx.draw(x+28+4,y+28+8*(3+subScreen.subMenu.y*2),gfx.arrowcursorRight)
        end
    end
    
    if spidey.debug.enabled then
        drawfont(28+8*0-4,28+8*22,font[subScreenFont], string.format("%02X %02X",subScreen.cursorX or 0,subScreen.cursorY or 0))
    end
end


function drawInventoryItemName(x,y,i)
    local itemFont = 2
    if not itemList[i] then
        drawfont(x+8+4,y,font[itemFont], "----")
        return
    end
    if itemList[i].gfx then
        gfx.draw(x,y,itemList[i].gfx)
    elseif itemList[i].palette then
        gui.drawbox(x+1,y, x+8-1,y+6, spidey.nes.palette[itemList[i].palette[3]], spidey.nes.palette[itemList[i].palette[2]])
    else
        gui.drawbox(x+1,y, x+8-1,y+6, "white", "clear")
    end
    if (itemList[i].stack or 0) >0 then
        drawfont(x+8+4,y,font[itemFont], string.format("%s %d", itemList[i].name, itemList[i].amount or 0))
    else
        local n = itemList[i].shortName
        if n=="Laurel" then n=string.format("%s (%d)",n, objects.player.laurels) end
        if n=="Garlic" then n=string.format("%s (%d)",n, objects.player.garlic) end
        drawfont(x+8+4,y,font[itemFont], n)
    end
end

function enterSubScreen()
    if config.sortInventory then sortItems() end
    subScreen.showClues = false
    subScreen.showRelics = false
    subScreen.showItems = false
    subScreen.showDebug = false
    game.setDebugMenuTab("main")
    game.map.visible = false


    subScreen.subMenu = subScreen.subMenu or {x=0,y=0, scrollY=0} 
    subScreen.relic = relics.current
    
    memory.writebyte(0x33, 0)
    subScreen.realCursorY = 0
    subScreen.cursorY = 1
    subScreen.cursorX = 1
    
--    if subScreen.cursorY==1 then subScreen.cursorX = subScreen.cursorX or relics.current end
--    if subScreen.cursorY==2 then subScreen.cursorX = subScreen.cursorX or weapons.current end

--  if subScreen.cursorY == 0 then subScreen.cursorX = subScreen.relic end
end

function exitSubScreen()
    subScreen.showClues = false
    subScreen.showRelics = false
    subScreen.showItems = false
    subScreen.showDebug = false
    game.map.visible = false
    if hasRelic(subScreen.relic) then
        relics.current=subScreen.relic or 0
        -- 6,7,8 all use relic slot 6
        memory.writebyte(0x004F, math.min(6, relics.current))
    else
        relics.current=0
        subScreen.relic = 0
        memory.writebyte(0x004F, relics.current or 0)
    end
end


function drawHUD()
        displayarea = locations.getAreaName(area1,area2,area3,areaFlags)
        
        if spidey.debug.enabled then
            --spidey.debug.font=font[6]
            --spidey.debug.font=font[current_font]
            spidey.debug.font=font[5]
            gui.drawbox(8*14, 8*5+5, 8*16+8*16, 8*5+5+8*6, "#40404080", "#40404080")
            drawfont(8*14,8*5+5,spidey.debug.font, string.format("Area: %02x %02x %02x %02x",area1,area2,area3, returnArea))
            drawfont(8*14,8*6+5,spidey.debug.font, string.format("Area flags: %02x", areaFlags))
            drawfont(8*14,8*7+5,spidey.debug.font, string.format("Scroll: %02x %02x",scrollx, scrolly))
            drawfont(8*14,8*8+5,spidey.debug.font, string.format("Player: %02x %02x",objects.player.x, objects.player.y))
            drawfont(8*14,8*9+5,spidey.debug.font, string.format("        %02x %02x",scrollx+objects.player.x,scrolly+objects.player.y))
            drawfont(8*14,8*10+5,spidey.debug.font, string.format("Mouse: %02x %02x ",spidey.inp.xmouse,spidey.inp.ymouse))
        end
        
        name = "^aH^ai"
        string.gsub(name, "^a", "")
        
        gui.drawbox(0, 0, 256, 20+8*3, "black", "black")
        drawfont(0+1,8+4,font[current_font], displayarea)
        
        drawfont(0+1,8*2+4,font[current_font], "PLAYER")
        drawfont(0+1,8*3+4,font[current_font], "ENEMY")
        objects.player.hp=objects.player.hp or 0
        objects.player.maxHp=objects.player.maxHp or 0
        if objects.player.inBossRoom==true then
            --drawfont(0,40,font[current_font], "yep")
            objects.boss.maxHp=objects.boss.maxHp or 140
            objects.boss.hp=memory.readbyte(0x4c8)
        else
            --drawfont(0,40,font[current_font], "nope")
            objects.boss.maxHp=nil
            objects.boss.hp=nil
        end
        -- Draw new life bar; Always shows 16 bars.
        for x=1,16 do
            if x<=math.floor((objects.player.hp/objects.player.maxHp)*16) then
                gui.drawbox((x-1)*4+8*7, 8*2+4+1,(x-1)*4+8*7+  2, 8*2+4+1+  5, "#d82800", "#d82800")
            else
                gui.drawbox((x-1)*4+8*7, 8*2+4+1,(x-1)*4+8*7+  2, 8*2+4+1+  5, "black", "white")
            end
        end
        
        for x=1,16 do
            if (not objects.player.inBossRoom) or x<=math.floor((objects.boss.hp/objects.boss.maxHp)*16) then
                gui.drawbox((x-1)*4+8*7, 8*3+4+1,(x-1)*4+8*7+  2, 8*3+4+1+  5, "#fc7460", "#fc7460")
            else
                gui.drawbox((x-1)*4+8*7, 8*3+4+1,(x-1)*4+8*7+  2, 8*3+4+1+  5, "black", "white")
            end
        end
        
        gfx.draw(8*21-1,8*2+4,gfx.cv2heart)
        drawfont(8*22,8*2+4,font[current_font], string.format('-%02s',objects.player.hearts or 0))
        drawfont(8*21,8*3+4,font[current_font], string.format('P-%02s',(objects.player.lives or 1) - 1))
        
        drawfont(8*21-1,8+4,font[current_font], "time:"..time)
        --drawfont(256-4-8*5,8+4,font[current_font], time)
        
        
        if config.showRelicsInHUD then
            for i,relic in ipairs(cv2data.relics) do
                if relics.list[relic.varName] and gfx.relics[i] then
                    gfx.draw(8*21-1+i*8-8,35,gfx.relics[i])
                    if not relics.on[relic.varName] then
                        gui.drawbox(8*21-1+i*8-8,35,8*21-1+i*8,35+8,"#000000c0","#000000c0")
                    end
                end
            end
        end
        
--        if relics.name then
--            if gfx.relics[relics.current] then gfx.draw(8*21-1,35,gfx.relics[relics.current]) end
--            drawfont(8*22,8*4+4,font[current_font], string.format('%s',relics.displayName))
--        end
        
        if testgfx then gfx.draw(4+8*15,11+8,testgfx) end
        
        --sp weapon box
        gui.drawbox(128,20,148+11,20+21, "clear", "#d82800")
        gui.drawbox(128+1,20+1,148+11-1,20+21-1, "clear", "#d82800")
        
        
        if objects.player.weaponItem then
            weaponName = items[objects.player.weaponItem].name
        else
            weaponName = nil
        end
        
        if weaponName == "Banshee Boomerang" then
            gfx.draw(145-9,11+12,gfx.boomerang[2])
        elseif weaponName == "Axe" then
            gfx.draw(135,24,gfx.axe[0])
        elseif weaponName == "Cross" then
            gfx.draw(140,11+16,gfx.items.cross)
        elseif weaponName then
            gfx.draw(145-5,11+16,gfx.weapons[items[objects.player.weaponItem].weaponIndex])
        end
        
end

function getheart()
    local i=getunused()
    --if n==-1 then n=0 end


--                objects[i].hp=0xef
--                objects[i].hp=1
--                memory.writebyte(0x04c8+i, objects[i].hp)
--                objects[i].frame=0x8b
--                memory.writebyte(0x0306+i, objects[i].frame)


    --type = 0x05
    memory.writebyte(0x3ba+i,0x37) --type
    --memory.writebyte(0x3ba+i,0x36) --type
    memory.writebyte(0x3de+i,0x00) --team
    --memory.writebyte(0x4c8+i,0x01) --hp
    
    --memory.writebyte(0x44a+i,0x01) -- time to dissappear?
    memory.writebyte(0x44a+i,0x18) -- time to dissappear?
    memory.writebyte(0x46e+i,0x00) --state2
    memory.writebyte(0x0306+i, 0x9c) -- frame
    memory.writebyte(0x0306+i, 0) -- frame
--    memory.writebyte(0x34e+i,objects.player.x-scrollx)
--    memory.writebyte(0x32a+i,objects.player.y-scrolly)
    memory.writebyte(0x34e+i,objects.player.x)
    memory.writebyte(0x32a+i,objects.player.y)
    --objects[i].team=memory.readbyte(0x03de+i) --00=uninitialized 01=enemy 40=friendly+talks 80=friendly 08=move with player
end


function hurtplayer(data)
    --atm, we hurt the player by creating an unfriendly heart on top of him
    if objects.player.inv>0 then return end --if he's invincible, don't bother.
    local onum = getunused()
    if not onum then return false end --should create an alternate method if it fails
    --memory.writebyte(0x03ba+onum,0x36) --burn
    memory.writebyte(0x03ba+onum,0x37) --heart
    --memory.writebyte(0x03ba+onum,0x38)
    memory.writebyte(0x034e+onum,objects.player.x)
    memory.writebyte(0x032a+onum,objects.player.y)
    memory.writebyte(0x03de+onum,0x01) --not friendly
    memory.writebyte(0x03f0+onum,0x01) --helps to init it; frame?
    memory.writebyte(0x0396+onum,0x01) --x speed
    memory.writebyte(0x036f+onum, data or 0) --y speed
    memory.writebyte(0x044a+onum,0x18) --make fire disappear faster
    return true
end

function hurtenemy(ii)
    if objects[ii].stun>0 then return end --if he's invincible, don't bother.
    onum = 2
    --memory.writebyte(0x03b7+onum,0x36) --burn
    --memory.writebyte(0x03b7+onum,0x37) --heart
    --memory.writebyte(0x03b7+onum,0x01) --dagger
    --memory.writebyte(0x03b7+onum,0x05) --crystal
    --memory.writebyte(0x03b7+onum,0x06) --sacred flame
    --memory.writebyte(0x03b7+onum,0x02) -- ?
    --memory.writebyte(0x03b7+onum,0x37) -- heart
    memory.writebyte(0x03b7+onum,0x48)
    
    memory.writebyte(0x034b+onum,objects[ii].x)
    memory.writebyte(0x0327+onum,objects[ii].y)
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
    if objects[ii].stun>0 then return end --if he's invincible, don't bother.
    --onum = getunused()
    onum = 2
    if not onum then return false end --should create an alternate method if it fails
    --memory.writebyte(0x03b7+onum,0x36) --burn
    --memory.writebyte(0x03b7+onum,0x37) --heart
    --memory.writebyte(0x03b7+onum,0x01) --dagger
    --memory.writebyte(0x03b7+onum,0x05) --crystal
    --memory.writebyte(0x03b7+onum,0x06) --sacred flame
    memory.writebyte(0x03b7+onum,0x02)
    
    memory.writebyte(0x034b+onum,objects[ii].x)
    memory.writebyte(0x0327+onum,objects[ii].y)
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



cv2fire = gfx.load("cv2fire.gd")

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

function onLoadState()
    objects.custom.destroyall()
end

-- whip reach if n=1
--function onSetWhipHitbox(a, n)
--    if n==1 then
--        spidey.message("%02x",a)
--        return 0x2f
--    end

--end

--function onSetHitboxCollision(n)
--    return false
--end

function onCreateEnemyFireball(enemyIndex, enemyType)
    memory.writeword(0x7600+2*enemyIndex, 0) -- set enemy aliveTime
end

function onTalk(t)
    -- Can only talk to NPCs when standing or walking.
    if objects.player.state > 1 then return false end
end

function onSetSpikeDamage(d)
    -- change spike damage from 0x10 to maxhp/6
    return math.floor(objects.player.maxHp/6)
end

function onSetHitbox(enemyType, enemyIndex, yOffset, xRadius, yRadius)
    -- set hitbox for flea men
    if cv2data.enemies[enemyType].name == "High Jump Blob" and not inMansion then
        --spidey.message("%02x %02x %02x",yOffset, xRadius, yRadius)
        yOffset = 0
        xRadius = 6
        yRadius = 9
    end
    
--    if not objects[enemyIndex] then return end
--    local o = objects[enemyIndex]
--    gui.drawbox(o.x-xRadius,o.y-yRadius+yOffset,o.x+xRadius,o.y+yRadius+yOffset, "#807070c0", "#807070ff")
    
--    if enemyType==0x35 then
--        spidey.message(yOffset)
--        yOffset=yOffset+13
--        yRadius = 0
--    end
    
    return yOffset, xRadius, yRadius
end


function onLoadTileSquareoid(t,x,y)
    --spidey.message("%s %s",inTown and "yes" or "no",inDoor and "yes" or "no")
    
    -- remove water in town
    if inTown and not inDoor and t==0x24 then t=0x01 end
    
    if config.levelReplaceTest and inTown and not inDoor then
        if y==0x0d then
            t=0x01 -- floor
        elseif y==0x0a and x % 4==1 then
            t=0x21 --window top
        elseif y==0x0b and x % 4==1 then
            t=0x2c --window bottom
        else
            t=0x38 --wall
        end
    end
    
--    t=math.min(0xff, x*8+y)
    if objects.player.pendant and jomaMarsh() then
        if y==6 then t=0x17 end
    end
    
    -- drac room edits
--    if y<5 and x==0 then t=0 end
--    if y<=5 and x==7 then t=0 end
--    if y==4 and (x==3 or x==4) then t=0 end
--    if y==5 and x<=6 then t=0 end
--    if y==5 and (x==2 or x==5) then t= 0x2c end
--    if t==0 then
--        t=0x20
--        if math.random(3)==1 then t=t+1 end
--    end
    
    return t
end

-- check if attack is sub weapon or whip
function onWhipOrSubWeapon(isSub)
--    if objects.player.whipItem == items.index["Thief's Dagger"] then
--        isSub=true
--        return isSub
--    end
    if isSub and canThrowWeapon()==false then
        isSub = false
        return isSub
    end
end

function onPrintTitleText(c,address, index)
    if address == 0x840c then 
        local m = "  PRESS START "
--        for i=1,#m do
--            memory.writebyte(0x7100+i-1, textMap2[m:sub(i,i)] or 0)
--        end
--        memory.writebyte(0x7100+#m, 0xff)
        --game.customMessage = m
        
        --memory.writebyte(0x01, 0x71)
        --memory.writebyte(0x00, 0x00)

        if index>=3 then
            c=textMap2[m:sub(index-2,index-2)]
            if c==textMap2[" "] then c=0xc1 end
        end
    elseif address == 0x8356 then
        -- story text
        --if index>3 then c=0 end
    elseif address == 0x8392 then
        -- ??
    elseif address == 0xcab7 then
        -- ??
    else
        --spidey.message("%04x %02x %02x",address,c,index)
    end
    return c
end

function onSetTitleScreenDisplayDuration(n)
    -- Increase time that title screen is shown (default is 0xb4)
    return 0xff
end

-- triggers when an enemy takes damage from whip
--memory.registerexec(0x8920,1,
--    function()
--        local a,x,y,s,p,pc=memory.getregisters()
--        memory.writebyte(0x4c2+x,40)
--        memory.setregister("a",0x10)
--        memory.setregister("y",0x00)
--        local i=x-6
--        emu.message(string.format("%02X %02X",objects[i].type,a))
--    end
--)

--set visual x pos of whip
--memory.registerexec(0xdb93,1, function()
--    local a,x,y,s,p,pc=memory.getregisters()
--    a=a-20
--    emu.message(a)
--    memory.setregister("a",a)
--end)

-- set visual y pos of whip
--memory.registerexec(0xdbb0,1, function()
--    local a,x,y,s,p,pc=memory.getregisters()
--    a=180
--    emu.message(a)
--    memory.setregister("a",a)
--end)

-- hide whip
--memory.registerexec(0xdb9a,1, function()
--    local a,x,y,s,p,pc=memory.getregisters()
--    a=1
--    memory.setregister("a",a)
--end)

-- block solidity check
--memory.registerexec(0xea04+2,1, function()
--    local a,x,y,s,p,pc=memory.getregisters()
--    a=0
--    memory.setregister("a",a)
--end)


-- fish man tweak
--memory.registerexec(0xa2bb+4,1, function()
--    local a,x,y,s,p,pc=memory.getregisters()
--    a=0xfd
--    y=0x70
--    memory.setregister("a",a)
--    memory.setregister("y",y)
--end)

-- set mode to 0 on continue screen which freezes it.
function onContinueScreen()
    memory.writebyte(0x19,0x00)
    -- reset counter
    if memory.readword(0x7410)==0 then
        memory.writeword(0x7410,0x190)
    end
end

-- force continue
--memory.registerexec(0xc2f8,1, function()
--    emu.message("continue")
--    local a,x,y,s,p,pc=memory.getregisters()
--    a=0
--    memory.setregister("a",a)
--end)

-- enter sub screen
function onEnterSubScreen()
    enterSubScreen()
end

-- number of hearts to get on pickup
function onHeartPickup(n)
    n=1
    return n
end

function onEnding(n)
    return n
end

function onGetRedCrystal()
    relics.list.redCrystal = true
    setRelicState("redCrystal",true)
    createItemPopUp("Red Crystal")
end

function onGetCross()
    getItem("Cross", true)
end

function onGetDiamond()
    if hasInventoryItem("Diamond") then return end
    
    -- He gives the item before the message, so we have to do this
    game.getItemDelayed = "Diamond"
    game.getItemDelayCounter=0x10
end

function onGetSilverKnife()
    if hasInventoryItem("Silver Knife") then return end
    
    getItem("Silver Knife", true, true) -- Delayed
end

function onGetGoldenKnife()
    if hasInventoryItem("Golden Knife") then return end
    getItem("Golden Knife", true, true) -- Delayed
end

function onGetSacredFlame()
    if hasInventoryItem("Sacred Flame") then return end
    getItem("Sacred Flame", true, true) -- Delayed
end



function onUseLaurel(n)
    removeItem("Laurel", 1)
    
    if hasInventoryItem("Laurel") then
        n = itemList[getInventoryIndex("Laurel")].amount
    else
        n = 0
    end
    
    return n
end

-- This isn't needed because the real sub menu selections 
-- are irrelevant
--function onSetWeapon(w, side)
--end



--memory.registerexec(0x87a4+3,1, function()
--    local a,x,y,s,p,pc=memory.getregisters()
--    a=0
--    a=0x38
    --memory.writebyte(0x3f,0)
--    memory.setregister("a",a)
    --memory.setregister("x",0)
--end)

function onMessage(messageNum, cancel)
    -- cancel sacred flame message, since we have the item popup.
    if messageNum == 0x80 then cancel=true end
    
    for i,clue in ipairs(cv2data.clues) do
        if messageNum == clue then
            if objects.player.clues[i] then
                cancel = true
            else
                objects.player.clues[i] = true
                memory.writebyte(0x7400+i, 1)
            end
        end
    end
    
    --if messageNum == 0x0d
    --spidey.message("%02x", messageNum)
    
    return messageNum, cancel
end

function onSetStartingHearts(hearts)
    return config.hearts or 5
end

function onSetStartingLives(lives)
    if config.saveLives and game.loadAgain then return end
    if config.lives then return config.lives end
end

function onSetPlayerFacingWhenHit(newFacing, facing)
    --spidey.message("%02x %02x",newFacing,facing)

    -- Don't turn around when hit on stairs
    if config.stairsFix then
        local state = memory.readbyte(0x3d8)
        if state==0x09 or state==0x0a then
            -- return original direction
            return facing
        end
    end
end

function onSetPlayerVelocityWhenHit(axis,v1, v2)
--    if axis=="y" then
--        return -6
--    end
--    if axis=="x" then
--        return v1*4
--    end
    if config.stairsFix then
        local state = memory.readbyte(0x3d8)
        if state==0x09 or state==0x0a then
            return 0
        end
    end
    if axis=="y" then return -3 end
    --if axis=="x" then return v1*2 end
end

--memory.registerexec(0xd390+2,1, function()
--    local a,x,y,s,p,pc=memory.getregisters()
--    if config.stairsFix then
--        local state = memory.readbyte(0x3d8)
--        if state==0x09 or state==0x0a then
--            a=state
--            memory.setregister("a", a)
--        end
--    end
--end)


function onSetPlayerStateWhenHit(newState, state)
    --spidey.message("%02x %02x",state, newState)
    if config.stairsFix then
        if state==0x09 or state==0x0a then
            return state
        end
    end
end

function onSetPlayerFrameWhenHit(newFrame, frame)
    --spidey.message("%02x %02x",frame, newFrame)
    if config.stairsFix then
        local state = memory.readbyte(0x3d8)
        if state==0x09 or state==0x0a then
            if frame==0x08 or frame==0x09 then
                return 0x03
            else
                return 0x02
            end
        end
    end
end

-- message change
function onMessage2(messageNum)
    if spidey.debug.enabled then
        emu.message(string.format("Message = %02X",messageNum))
    end
    
    local m=""
    if cv2data.messages[messageNum] then
        if type(cv2data.messages[messageNum])=="table" then
            for i,v in ipairs(cv2data.messages[messageNum]) do
                if v.condition then
                    if v.condition()==true then
                        m=v.text
                        break
                    end
                elseif v.cycle then
                    cv2data.messages[messageNum][i].cycleIndex = (cv2data.messages[messageNum][i].cycleIndex or 0) +1
                    if cv2data.messages[messageNum][i].cycleIndex > #v.text then cv2data.messages[messageNum][i].cycleIndex = 1 end
                    m=v.text[cv2data.messages[messageNum][i].cycleIndex]
                else
                    m=v.text
                    break
                end
            end
        end
    else
        --m = "YAY I GOT\nTHIS MESSAGE\nREPLACER\nTHING WORKING"
        --m=string.format("MESSAGE %02X",messageNum)
        --m=cv2data.defaultMessages[messageNum]..string.format(" %02X",messageNum)
        --write 0xff to display original message instead
        memory.writebyte(0x7100, 0xff)
        return
    end
    --m=string.format("MESSAGE %02X",messageNum)
    --m=string.format("MESSAGE %02X",messageNum)
    for i=1,#m do
        memory.writebyte(0x7100+i-1, textMap2[m:sub(i,i)] or 0)
    end
    memory.writebyte(0x7100+#m, 0xff)
    game.customMessage = m
end

function onMessageWriteAddress(address)
    -- If our custom message flag is set, then
    -- change the message address to our custom message address.
    if memory.readbyte(0x7100)~=0xff then
        address = 0x7100
    end
    return address
end

-- intercept whip damage
function onWhipDamage(damage, target)
    local stats = getStats()
    
    damage = stats.damage
    
    local enemyDef = cv2data.enemies[objects[target].type].def or 0
    
    if objects.player.whipItem == items.index["Thorn Whip"] then
        enemyDef = enemyDef - math.floor(enemyDef*.5)
        enemyDef = 0
    end
    
    if damage>1 then
        damage=math.max(1, damage-enemyDef)
    end
    
    if objects.player.whipItem == items.index["Poison Whip"] then
        createPoison(target)
    end
    
    if config.testStats then
        emu.message(string.format("whip damage %d, item=%d",damage, objects.player.whipItem or 0))
    end
    return damage
end


--07:DC67: B9 E3 DC  LDA $DCE3,Y @ $DCE3 = #$0A
-- whip frame thing
--memory.registerexec(0xdc67+3,1, function()
--    local a,x,y,s,p,pc=memory.getregisters()
--    memory.setregister("a",a)
--end)

function addExp(n)
    local e = tonumber(string.format("%02x%02x", memory.readbyte(0x47), memory.readbyte(0x46)))
    --local e = getCurrentExp()
    
    e=math.min(9999, e+n)
    
    
    objects.player.gold = objects.player.gold+5
    memory.writeword(0x7000+1, objects.player.gold)
    
    local need = getExpNeeded()
    
    --if e>=need then
    if need-n <=0 then
        --getheart()
        
        --emu.message("level up!")
        
        createLevelUpText()
        playSound(0x27)
        
        e=e-getTotalExpNeeded()
        
        objects.player.level = math.min(objects.player.level+1, 99)
        memory.writebyte(0x008b, objects.player.level)
    end
    
    e = tonumber(string.format("%04d",e),16)
    memory.writebyte(0x46, e % 0x100)
    memory.writebyte(0x47, (e-(e % 0x100))/0x100)
end

function setHearts(n)
    objects.player.hearts = n
    if objects.player.hearts > objects.player.maxHearts then
        objects.player.hearts = objects.player.maxHearts
    end
    if objects.player.hearts < 0 then objects.player.hearts=0 end
    memory.writebyte(0x48, tonumber(string.format("%02d",objects.player.hearts % 100),16))
    memory.writebyte(0x49, tonumber(string.format("%02d",(objects.player.hearts-(objects.player.hearts % 100))/100),16))
end

function addHearts(n)
    setHearts(objects.player.hearts+n)
end

function playSound(n)
    game.soundQueue=game.soundQueue or {}
    game.soundQueue[#game.soundQueue+1] = n
end

function queueSound(n)
    game.soundQueue=game.soundQueue or {}
    game.soundQueue[#game.soundQueue+1] = n
end

function updateSoundQueue()
    game.soundQueue=game.soundQueue or {}
    if #game.soundQueue==0 then return end
    if memory.readbyte(0x7500)==0 then
        memory.writebyte(0x7500, table.remove(game.soundQueue, 1))
    end
end

-- buying (cost)
-- changes sp weapon cost too, but we fix that elsewhere
function onHeartCost(cost)
    if objects.player.gold >= cost then
        -- deduct from gold here
        objects.player.gold = objects.player.gold-cost
        memory.writeword(0x7000+1, objects.player.gold)
        
        -- no heart cost
        cost = 0
    else
        -- not buyable
        cost = 0xaaaa
    end
    return cost
end


-- buying (deduct)
-- changes sp weapon cost too, but we fix that elsewhere
-- two of these for two bytes of heart cost.
function onDeductHeartCost1(oldHeartValue, newHeartValue)
    -- don't deduct hearts
    return oldHeartValue
end
function onDeductHeartCost2(oldHeartValue, newHeartValue)
    -- don't deduct hearts
    return oldHeartValue
end

-- triggers when an enemy dies from whip
--memory.registerexec(0x8927,1, function()
--        if not spidey.debug.enabled then return end
--        local a,x,y,s,p,pc=memory.getregisters()
--        local t = memory.readbyte(0x03b4+x)
--        if cv2data.enemies[t] then
--            emu.message(string.format("%02X %s",x,cv2data.enemies[t].name or "?"))
--        else
--            emu.message(string.format("%02X %02x",x,t))
--        end
--end)

-- triggers when an enemy dies from anything
function onEnemyDeath(t)
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
end

-- ********** start of map stuff **********
-- This section is stuff related to the map in this hack:
-- http://www.romhacking.net/hacks/1032/
--
--memory.registerexec(0xff1a,1,
--    function()
--        local a,x,y,s,p,pc=memory.getregisters()
--        mapmenu=true
--    end
--)

-- map exit
--memory.registerexec(0xff3c,1,
--    function()
--        local a,x,y,s,p,pc=memory.getregisters()
--        mapmenu=false
--        specialPause=true
--        if exitSpecialPause then
--            specialPause = false
--            exitSpecialPause = false
--        else
--            specialPause=true
--            memory.writebyte(0x007a,2) -- Prevent exit, but now we can use our cheat menu
--        end
        
--    end
--)
-- ********** end of map stuff **********

-- create a callback for manipulating enemy damage
--memory.registerexec(0x883a,1,
--    function()
--        local a,x,y,s,p,pc=memory.getregisters()
--        local t=memory.readbyte(0x03ba+x-6)
--        if enemyDamage then
--            local a = enemyDamage(x-6,t,a)
--            if a then memory.setregister("a",a) end
--        end
--    end
--)

function onEnemyDamage(i,t,damage)

    if cv2data.enemies[t].name=="Heart" then
        -- Heart's x speed is 1 to indicate it's a reference to a normal 
        -- enemy.  Later we'll add more flags to indicate custom stuff.
        -- type is stored in heart's y speed
        if memory.readbyte(0x0396+i) == 1 then
            t = memory.readbyte(0x036f+i)
        end
    end
    
    damage = cv2data.enemies[t].attack or damage
    

    
    local oldDamage = damage
    --damage=damage*2
    
    --if game.night then damage = 99 else damage = 1 end
    game.data.enemies[t] = game.data.enemies[t] or {}
    game.data.enemies[t].damage = game.data.enemies[t].damage or {}
    if night then
        game.data.enemies[t].damage[2]=damage
    else
        game.data.enemies[t].damage[1]=damage
    end
    
    --emu.message(string.format("Damage %02X",damage))
    
    if night and objects.player.armor == items.index["Night Armor"] then
        if damage>=1 then
            damage = math.max(1, math.floor(damage * .6))
        end
    end
    
    -- apply accessory damage reduction
    if objects.player.accessory then
        if items[objects.player.accessory].damageReduction and damage>=1 then
            damage = math.max(1, math.floor(damage - items[objects.player.accessory].damageReduction))
        end
    end
    
    local stats=getStats()
    if damage>1 then
        damage = math.max(1, math.floor(damage - stats.def))
    end
    
    if config.testStats then
        emu.message(string.format("Damage %d (original %d)",damage, oldDamage))
    end
    
    return damage
end


--memory.registerexec(0x8a5f,1, function()
--    local a,x,y,s,p,pc=memory.getregisters()
--    local t=memory.readbyte(0x03ba+y-6)
--    memory.setregister("x",0)
--    if enemyDamage then
--        local a = enemyDamage(x-6,t,a)
--        if a then memory.setregister("a",a) end
--    end
--end)

-- remove heart use from sp weapons
function onSubWeaponCost(cost)
    cost=0
    return cost
end

function _spWeaponUseHearts(address, len, t)
    memory.setregister("a", 0)
    do return end
    --emu.message(a or "?")
    --emu.message(fData.a)
--    t=t or {}
    util.extract(t)
    emu.message(bank or "nope")
    a=0
    memory.setregister("a",a)
    return {address=address,len=len,bank=bank,a=a,x=x,s=s,p=p,pc=pc}
end

function getBank(address)
    local nBanks = 8
    local bankSize = 0x4000
    local a1 = address-address % bankSize
    local compare1 = ""
    for i=0, 0x10 do
        compare1=compare1..string.char(memory.readbyte(a1+i))
    end
    for bank=1,nBanks do
        compare2=""
        for i=0, 0x10 do
            compare2=compare2..string.char(rom.readbyte(0x10+(bank*0x4000)+i))
        end
        if compare1==compare2 then
            return bank
        end
    end
end

function onSetWhipFrameDelay(delay, whipState)
    -- add 2 more frames to whip state back 2.
    -- this makes it match castlevania 1
    if whipState == 1 then delay=delay+2 end
    return delay
end

function canThrowWeapon()
    if not objects.player.weaponItem then return false end
    local weaponName = items[objects.player.weaponItem].name
    local cost = items[objects.player.weaponItem].heartCost or 0
    if cost > objects.player.hearts then return false end
    
    if getCustomCount("holyfire")>0 then return false end
    if weaponName=="Banshee Boomerang" and getCustomCount("bansheeboomerang")>=3 then return false end
    if weaponName=="Axe" and getCustomCount("axe")>=3 then return false end
    
    return true
end

function onThrowWeapon(weaponType, abort)
    --emu.pause()
--    local a,x,y,s,p,pc=memory.getregisters()
--    local t=memory.readbyte(0x03ba+y-6)
    
    -- used to abort the normal weapon creation but not the custom cost.
    local abortWeaponOnly = false
    local weaponName = items[objects.player.weaponItem].name
    
    -- heart cost
    local cost = items[objects.player.weaponItem].heartCost or 0
    

    if objects.player.armor == items.index["Adventure Armor"] then
        if cost>1 then cost = cost-1 end
    end
    if objects.player.accessory == items.index["Charm"] then
        if cost>1 then cost = cost-1 end
    end
    
    if config.reduceHeartCost then
        if cost>1 then cost = math.max(1,cost-config.reduceHeartCost) end
    end
    
    
    if objects.player.weaponItem and items[objects.player.weaponItem].stack then
        removeItem(items[objects.player.weaponItem].name,1)
    end
    
    abort = false


    -- abort throwing of holy water if fire is on ground
    if getCustomCount("holyfire")>0 then
        --emu.pause()
        abort = true
    end

    if cost > objects.player.hearts then
        -- abort weapon
        abort = true -- use this to cancel axes/boomerang
    end
--        if objects.player.hearts==0 then
--            memory.setregister("a",0)
--            memory.writebyte(0x40e,0)
--        end
    
    -- Banshee Boomerang
    --if weaponName=="Banshee Boomerang" and a==0x01 and not abort then
    if weaponName=="Banshee Boomerang" and not abort then
        abortWeaponOnly = true
        if getCustomCount("bansheeboomerang")<3 then
            createBoomerang(objects.player.x,objects.player.y)
        else
            abort = true
        end
    end
    if weaponName=="Axe" and not abort then
        abortWeaponOnly = true
        if getCustomCount("axe")<3 then
            createAxe(objects.player.x,objects.player.y)
        else
            abort = true
        end
    end
    
    if not abort then
        -- spend hearts
        setHearts(objects.player.hearts - cost)
    end
    return weaponType, abort or abortWeaponOnly
end

-- Note: changing an enemy type to 0 will make a phantom enemy if
-- hp isn't set to 0.  You can't fix it here, have to clean it up
-- in onEnemyCreated().
function onCreateEnemy(enemyIndex,enemyType)
    --if t==0x43 then t=0x3a end
    --if t==0x03 then t=0x13 end
    
    --if t==0x03 then t=0x0d end -- turn skeletons to jumping skeleton
    
    -- joma marsh
    if objects.player.pendant and jomaMarsh() then
        enemyType = 0
    end
    
--    if enemyType~=0x19 and enemyType~=0x1a and enemyType~=0x4a then
--        enemyType = 0
--    end
    
    if config.noEnemies then
        if cv2data.enemies[enemyType] and cv2data.enemies[enemyType].exp>0 then
            enemyType = 0
        end
    end
    
    
    if enemyType==0x26 and hasInventoryItem("Sacred Flame") then
        enemyType=0
    end
    
    -- grace period to despawn zombies when it turns to night in town
    if inTown and enemyType==0x17 and hour==18 and minute <=15 then 
        enemyType=0
    end
    
--    if inTown and areaFlags==0 and hour==17 then
--        if enemyType>=0x28 and enemyType<=0x2f then enemyType=0 end
--        if enemyType==0x35 then enemyType=0 end
--    end
    
    
    -- 27 = clue
    if enemyType==0x27 then
        --t=0
    end
    
    --if enemyType==0x27 then debugger.hitbreakpoint() end
    
    --if t==0x03 then t=0x3a end --turn skeletons into mummies
    
    --pattern1=6
    --pattern2=7
    --memory.writebyte(0x101,pattern1)
    --memory.writebyte(0x102,pattern2)
    
    
    --t=0
    --emu.message(string.format("Create enemy %02X",t))
    memory.writeword(0x7600+2*enemyIndex, 0) -- enemy aliveTime
    return enemyType
end

function onCreateHeart(enemyIndex,enemyType)
--    local x = objects[enemyIndex].x + scrollx
--    local y = objects[enemyIndex].y + scrolly
    
--    local obj = createObject("item", x, y)
--    obj.floor = y
--    obj.itemName = "Gold"
    --return enemyType
end

function onCreateHeartChance(createHeart)
    createHeart = false
    return createHeart
end

function jomaMarsh()
    local l=string.format("%02x%02x%02x",area1,area2,area3)
    if l=="030001" or l== "030300" then return true end
end


-- after enemy creation finished
function onEnemyCreated(enemyIndex, enemyType, enemyX, enemyY)
    if enemyType==0 then
        memory.writebyte(0x04c8+enemyIndex, 0) -- hp
        return
    end
    local enemyName = cv2data.enemies[enemyType].name
    
    if config.replaceMedusaHeads and enemyName=="Medusa" then
        --createMedusaHead(enemyX+scrollx,enemyY+scrolly,enemyIndex)
        enemyType = 0
        --enemyType = 0x10
        memory.writebyte(0x03ba+enemyIndex,enemyType)
    end
    
    -- Town npcs don't spawn when it's close to night.
    if inTown and areaFlags==0 and hour==17 and minute>=15 then
        if (enemyType>=0x28 and enemyType<=0x2f) or enemyType==0x35 then
            enemyType=0
            memory.writebyte(0x03ba+enemyIndex,enemyType)
        end
    end
    
    
    if enemyName=="Blob" then
        enemyY=enemyY+8+5
        memory.writebyte(0x032a+enemyIndex, enemyY)
    end
    if enemyName=="High Jump Blob" then
        enemyY=enemyY+8
        memory.writebyte(0x032a+enemyIndex, enemyY)
    end
    
    eData = cv2data.enemies[enemyType] or {}
    
    -- adjust hp on creation
    local hp = memory.readbyte(0x04c8+enemyIndex)
    if eData.hp == "initial" then
        -- don't change hp.  some objects like platforms rely on it.
    elseif eData.hp then
        -- use our defined hp
        hp = eData.hp
    else
        -- default to 4x normal
        hp=math.min(0x80, hp*4)
        if config.testStats then
            --emu.message(string.format("%s needs hp set",e.name))
        end
    end
    
    --emu.message(string.format("%s hp: %d",e.name, hp))
    
    --emu.message(string.format("%02x %d",x, hp))
    
    memory.writebyte(0x04c8+enemyIndex, hp)
    
    --emu.message(string.format("%s hp=%02x",e.name or "?",memory.readbyte(0x04c8+x)))
    
    if not spidey.debug.enabled then return end
    
    local i=getunusedcustom()
    objects.custom[i].type = "marker"
    objects.custom[i].eName = enemyName
    objects.custom[i].x=enemyX+scrollx
    objects.custom[i].y=enemyY+scrolly
    objects.custom[i].outscreen=true
    objects.custom[i].active=1
    
    
--    memory.writebyte(0x03ba+x,0)
--    memory.readbyte(0x0324+6+x,0xff)
    
    
    --e.y=e.y-16
    --memory.writebyte(0x0324+6+x,e.y)
    
    --emu.message(x)
end

function onCreateEnemyProjectile(i,t,x,y)
    if t==0x0c then
        t=0
        --createBone(objects[i].x-scrollx,objects[i].y-scrolly)
        --for j=1, 2 do
        local boneInterval = 2
        local nBones = 1
        if game.night then
            boneInterval = 1
            nBones = 2
        end

        if objects[i].state2==boneInterval then
            for j=1, nBones do
                createBone(x,y)
            end
            objects[i].state2=0
            memory.writebyte(0x046e+i, objects[i].state2)
        else
            objects[i].state2=objects[i].state2+1
            memory.writebyte(0x046e+i, objects[i].state2)
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
    local i=getunusedcustom()
    if (i) then
        objects.custom[i].type="diamondtrail"
        objects.custom[i].x=x+scrollx
        objects.custom[i].y=y+scrolly
--        objects.custom[i].xs=math.random(-5,5)*.2
--        objects.custom[i].ys=math.random(-5,5)*.1-2.8
        objects.custom[i].xs=0
        objects.custom[i].ys=0
        objects.custom[i].active=1
    end
end

function createLevelUpText()
    local i=getunusedcustom()
    if i then
        objects.custom[i].type="levelup"
        objects.custom[i].x=objects.player.x+scrollx
        objects.custom[i].y=objects.player.y+scrolly-32
        objects.custom[i].active=1
    end
end

function createItemPopUp(text)
    local obj = createObject("itemPopUp", objects.player.x+scrollx, objects.player.y+scrolly-32)
    obj.text = text
--    local i=getunusedcustom()
--    if i then
--        objects.custom[i].type="itemPopUp"
--        objects.custom[i].x=objects.player.x+scrollx
--        objects.custom[i].y=objects.player.y+scrolly-32
--        objects.custom[i].active=1
--        objects.custom[i].text=text
--    end
end

function createBone(x,y)
    local i=getunusedcustom()
    if i then
        objects.custom[i].type="bone"
                --objects.custom[i].x=inp.xmouse+scrollx
        --objects.custom[i].y=inp.ymouse+scrolly
        objects.custom[i].x=x+scrollx
        objects.custom[i].y=y+scrolly
        --objects.custom[i].xs=math.random(-5,5)*.2
        objects.custom[i].xs=math.random(2,4)*.2*playerDirection(objects.custom[i])
        
        --objects.custom[i].xs=1
        objects.custom[i].ys=math.random(-5,5)*.1-2.8
        --objects.custom[i].ys=0
        --objects.custom[i].xs=0
        --objects.custom[i].ys=0
        objects.custom[i].active=1
    end
end

function playerDirection(source)
    if source.custom then
        if source.x < scrollx+objects.player.x then return 1 else return -1 end
    else
        if source.x < objects.player.x then return 1 else return -1 end
    end
end

function createPoison(enemyIndex)
    local i=getunusedcustom()
    if not i then return end
    
    objects.custom[i].type = "poison"
    objects.custom[i].target = enemyIndex
    objects.custom[i].outscreen=true
    objects.custom[i].active=1
end

function createPoisonDrip(target)
    local i=getunusedcustom()
    if not i then return end
    
    objects.custom[i].type = "poisonDrip"
    objects.custom[i].target = target
    objects.custom[i].x=objects[target].x-scrollx
    objects.custom[i].y=objects[target].y-scrolly
    objects.custom[i].outscreen=true
    objects.custom[i].active=1
end

function createAxe(x,y)
    local i=getunusedcustom()
    if (i) then
        objects.custom[i].type="axe"
        objects.custom[i].x=x+scrollx
        objects.custom[i].y=y+scrolly
        --objects.custom[i].xs=math.random(-5,5)*.2
        --objects.custom[i].ys=math.random(-5,5)*.1-2.8
        objects.custom[i].hasHit=false
        objects.custom[i].xs=4*.2
        objects.custom[i].ys=-5*.1-2.8
        objects.custom[i].facing=objects.player.facing
        if objects.custom[i].facing==1 then 
        else 
            objects.custom[i].xs=objects.custom[i].xs*-1
        end
        objects.custom[i].active=1
    end
end

function createBoomerang(x,y)
    local i=getunusedcustom()
    if (i) then
        objects.custom[i].type="bansheeboomerang"
        objects.custom[i].rebound = false
        objects.custom[i].x=x+scrollx
        objects.custom[i].y=y+scrolly
        --objects.custom[i].rnd=math.random(0,90000)
        --objects.custom[i].xs=math.random(-5,5)*.2
        --objects.custom[i].xs=1
        objects.custom[i].facing=objects.player.facing
        if objects.custom[i].facing==1 then 
            objects.custom[i].xs=1.5 
        else 
            objects.custom[i].xs=-1.5 
        end
        objects.custom[i].ys=0
        objects.custom[i].active=1
    end
end

function createMedusaHead()
    local x,y
    
    y=scrolly+objects.player.y-0x20
    local facing = 1-objects.player.facing
    if facing==1 then 
        x = scrollx+0x08
    else 
        x = scrollx+0x0ff-0x08
    end
    local obj = createObject("medusahead",x,y)
    obj.facing = facing
    obj.xs=1.17
    if obj.facing == 0 then obj.xs=obj.xs*-1 end
    
    --obj.outscreen=true
    obj.outscreen=false
end

function createCustomHeart(x,y, floor)
    local obj = createObject("heart", x, y)
    obj.floor = floor
end


--    for i=1,objects.custom.count-1 do
--        if objects.custom[i].active==0 then
--            objects.custom[i] = {x=0,y=0}
--            objects.custom[i].originX = objects.custom[i].x
--            objects.custom[i].originY = objects.custom[i].y
--            objects.custom[i].outscreen=nil
--            objects.custom[i].alivetime=0
--            objects.custom[i].xs=0
--            objects.custom[i].ys=0
--            return i
--        end
--    end
--    return false


function createObject(t,x,y)
    local unusedIndex
     for i=1,objects.custom.count-1 do
        if objects.custom[i].active==0 then
            unusedIndex = i
            break
        end
    end
    
    if not unusedIndex then return false end
    
    local i = unusedIndex
    objects.custom[i] = {}
    objects.custom[i].custom = true
    objects.custom[i].type = t
    objects.custom[i].facing = 1
    objects.custom[i].x = x or 0
    objects.custom[i].y = y or 0
    objects.custom[i].xs = 0
    objects.custom[i].ys = 0
    objects.custom[i].originX = 0
    objects.custom[i].originY = 0
    objects.custom[i].outscreen=nil
    objects.custom[i].alivetime=0
    objects.custom[i].aliveTime=0
    objects.custom[i].active=1
    objects.custom[i].area = {area1,area2,area3,areaFlags}
    return objects.custom[i], i
end


function onStartGame()
    if game.setArea==true then
        memory.writebyte(0x30,area1)
        memory.writebyte(0x50,area2)
        memory.writebyte(0x51,area3)
        memory.writebyte(0x004e, returnArea)
        memory.writebyte(0x0458, returnScroll1)
        memory.writebyte(0x046a, returnScroll2)
        memory.writebyte(0x4a0, returnX)
        memory.writebyte(0x4b2, returnY)
        game.setArea=false
    end
    game.applyPlayerPalette = 1
end

function onRestartGame()
    if objects.player.inBossRoom == true then
        if area1==0x01 and area2==0x06 and area3==0x02 then
            -- Camille
            local w={}
            w.area3=0x01
            w.playerX=0xd2
            w.playerY=0xbd
            w.scrollX=0x200
            w.scrollY=0x2a0
            w.facing = 1
            warpPlayer(w)
            return w.area3

        elseif area1==0x01 and area2==0x09 and area3==0x02 then
            -- Death
            local w={}
            w.area3=0x01
            w.playerX=0x27
            w.playerY=0xbd
            w.scrollX=0
            w.scrollY=0x2a0
            w.facing = 1
            warpPlayer(w)
            return w.area3
        else
            -- Dracula
            return
        end
    end
end

function onWalkSpeed(speed)
    if objects.player.armor == items.index["Zombie Armor"] then
        speed=speed *.6
    end
    return speed
end

-- stop moving left/right
function onWalkStop()
    objects.player.sp=0
end

function onSetJumpSpeedX(v)
    return v
end

function onSetJumpSpeedY(v, onPlatform)
    if config.platformVelocityFix then
        if objects.player.platformIndex then
            -- Cancel x velocity of jumping straight up on a platform.
            memory.writebyte(0x6c,0)
            memory.writebyte(0x6d,0)
            
            if objects[objects.player.platformIndex].xs == 0 then
                -- for some reason on the vertical platforms you gotta make it 0xfb not 0xfc
                v=0xfb
            else
                v=0xfc
            end
        end
    end
    return v
end

-- Don't get knocked off stairs when hit; needs work
-- disabled
--memory.registerexec(0xd392,0, function()
--    local a,x,y,s,p,pc=memory.getregisters()
--function onSetPlayerStateWhenHit(state)
--    if not config.stairsFix then return end
    --local state = memory.readbyte(0x3d8)
--    if state==0x09 or state==0x0a then
--        a=0x0a
--        objects.player.lockPosition = {
--            frame = objects.player.facing,
--            frame = objects.player.frame,
--            scrollX=scrollx,
--            scrollY=scrolly,
--            c=0x30,
--        }
        --memory.setregister("a",a)
--        return 0x0a
--    end
    --memory.setregister("a",a)
--end

-- Modify the lives display by intercepting the 
-- given value to print and subtracting 1.
-- This will make it more like other CastleVania
-- games, where the lives are "extra" lives.
function onPrintLives(lives)
    return lives-1
end

-- experience gain from hearts
function onExpGain(e)
    e = 0
    return e
end

function getTotalExpNeeded(level)
    level = level or objects.player.level
    --do return 10 end
    return level*50+100
end

function getExpNeeded(level)
    level = level or objects.player.level
    --do return 10 end
    return level*50+100 - objects.player.exp
end

function getCurrentExp()
    --spidey.message(objects.player.exp)
    local exp = objects.player.exp
    for i=0, objects.player.level-1 do
       exp=exp + getTotalExpNeeded(i)
    end
    return exp
end

function getStats(level)
    level = level or objects.player.level
    local armorDef = items[objects.player.armor or items.index["Red Tunic"]].ar or 0
    local weaponPower = items[objects.player.whipItem or items.index["Leather Whip"]].attack or 0
    
    local stats = {}
    stats.str = 8 + math.floor(level * .5)
    stats.atk = math.floor(stats.str*.2+weaponPower)
    stats.con = 7 + math.floor(level * .5)
    stats.def = math.floor(stats.con*.1+armorDef*.4)
    stats.int = 5
    stats.luck = 5
    stats.damage = math.max(1,stats.atk)
    
    return stats
end

-- intercept exp needed for level (low byte
function onExpForLevel1(e)
    local e = getExpNeeded()
    return tonumber(string.format("%02d",e % 100),16)
end

-- intercept exp needed for level (high byte)
function onExpForLevel2(e)
    local e = getExpNeeded()
    return tonumber(string.format("%02d",(e - e % 100) / 100),16)
end

-- intercept getting pointer to level data stuff
--local f = function(address)
--    local a,x,y,s,p,pc=memory.getregisters()
    
--    if objects.player.level>6 then -- for now, use stats for level 6 at levels > 6
--        if address == 0x881c+3 then
--            a = 0x3b
--        else
--            a = 0x8c
--        end
--    end
    
--    memory.setregister("a",a)
--end
--memory.registerexec(0x881c+3,1, f)
--memory.registerexec(0x8821+3,1, f)

-- intercept getting pointer to level data stuff
function onSetPlayerLevelDataPointer(low, high)
    if objects.player.level>6 then -- for now, use stats for level 6 at levels > 6 (0x8c3b)
        if low then
            return 0x3b
        else
            return 0x8c
        end
    end
end

-- change solid blocks (not visually)
--memory.registerexec(0xe8a2,1, function()
--    local a,x,y,s,p,pc=memory.getregisters()
--    local address = memory.readbyte(0x0a)+y
    --aa = block, ac=swamp ad=some are breakable
    --if a==0xaa then a=0xae end
    
--    a=0
    
--    memory.setregister("a",a)
--end)


-- something to do with stage block palette
--memory.registerexec(0xe8ca,1, function()
--    local a,x,y,s,p,pc=memory.getregisters()
--    a=0xaa
--    memory.setregister("a",a)
--end)

--function onPlaceStageTile(tile)
--    if tile==0xd9 then tile=0 end
--    if tile==0xdb then tile=0 end
--    if tile==0xda then tile=0 end
--    if tile==0xdc then tile=0 end
--    return tile
--end

function onGetFreeLaurels()
    --spidey.message("%02x %02x", memory.getregister("a"),memory.readbyte(0x92))
    if not hasInventoryItem("Pendant") then getItem("Pendant", true, true) end --delayed
    memory.setregister("a", memory.readbyte(0x92)) -- cancel laurels
end

function onPlaceStageTile(tile)
--    if tile==0xdb then tile=0 end
--    if tile==0xda then tile=0 end

--    pattern1=memory.readbyte(0x0101)
--    pattern2=memory.readbyte(0x0102)
    
    local tileY = memory.readbyte(0x6a)
    local x = memory.getregister("x")
    --joma marsh
--    if objects.player.pendant and jomaMarsh() then
--        if tile==0xe0 then
--            tile=0xf6 + ((memory.getregister("x")+1) % 2)*2
--        end
--        if tile==0xe1 then
--            if tileY==0x19 then
--                tile=0xf7 + ((memory.getregister("x")+1) % 2)*2
--            else
--                tile = 0xe7
--            end
--        end
--        if tile==0xe2 then tile=0xed + (x+1) % 4 end
--        return tile
--    end

--    if tile==0xe1 then tile=0xe7 end
--    if tile==0xe2 then tile=0xe7 end
end


-- reduce enemy stun time from 0x10
function onEnemyStun(stunTime)
    stunTime = 0x0b
--    if objects.player.whipItem == items.index["Poison Whip"] then
--        stunTime=0x0e
--    end
    return stunTime
end


-- Whip check for getting flame whip
function onWhipCheckForFlameWhip(whip)
    if hasInventoryItem("Morning Star") then
        whip = 3
        if not hasInventoryItem("Flame Whip") then
            getItem("Flame Whip", true, true) -- delayed
        end
    else
        whip = 0
    end
    return whip
end

-- controller direction press check on stairs
-- bank 3
--memory.registerexec(0x8ae2+2,1, function()
--    local a,x,y,s,p,pc=memory.getregisters()
--    a=0
--    a=0x04
--    a=0x08
--    memory.setregister("a", a)
--end)


-- Relic check for eye
function onRelicCheckEye(relic)
    --emu.message("relic check eye")
    if relics.list.eye and relics.on.eye then
        relic=3
    else
        relic=0
    end
    return relic
end

-- Relic check for nail
function onRelicCheckNail(relic)
    if relics.list.nail and relics.on.nail then
        relic=4
    else
        relic=0
    end
    return relic
end

-- Relic check for rib
function onRelicCheckRib(relic)
    if relics.list.rib and relics.on.rib then
        relic=1
    else
        relic=0
    end
    return relic
end

-- Relic check for blue crystal
function onRelicCheckBlueCrystal(relic)
    if relics.list.blueCrystal and relics.on.blueCrystal then
        relic=6
    else
        relic=0
    end
    return relic
end

-- Relic check for blue crystal
function onRelicCheckBlueCrystal2(relic)
    if relics.list.blueCrystal and relics.on.blueCrystal then
        relic=6
    else
        relic=0
    end
    return relic
end


-- Relic check for blue crystal
function onRelicCheckBlueCrystal3()
    if relics.list.blueCrystal and relics.on.blueCrystal then
        return false
    else
        return true
    end
end


-- Relic check for red crystal
function onRelicCheckRedCrystal(relic)
    if relics.list.redCrystal and relics.on.redCrystal then
        relic = 6
    else
        relic = 0
    end
    return relic
end

-- Relic check for white crystal (to see invisible block)
function onRelicCheckWhiteCrystal(relic)
    if relics.list.whiteCrystal and relics.on.whiteCrystal then
        relic = 6
    else
        relic = 0
    end
    return relic
end

-- Relic check for white crystal to get blue in aljiba
function onRelicCheckWhiteCrystal2()
    if relics.list.whiteCrystal and not relics.list.blueCrystal then
        -- get relic, turn it on by default
        relics.list.blueCrystal=true
        setRelicState("blueCrystal", true)
        return false
    else
        return true
    end
end

-- Relic check for heart
function onRelicCheckHeart(relic)
    if relics.list.heart and relics.on.heart then
        relic = 2
    else
        relic = 0
    end
    return relic
end

-- Relic check for west bridge
function onRelicCheckAll(relic)
    relic = 0x7f
    for i=1,5 do
        if not relics.list[cv2data.relics[i].name] or not relics.on[cv2data.relics[i].name] then
            relic = 0
        end
    end
    return relic
end

-- get a relic (mansions)
memory.registerexec(0x8799,1, function()
    local a,x,y,s,p,pc=memory.getregisters()
    --emu.message(cv2data.relics[y+1].name)
    
    -- get relic, turn it on by default
    if cv2data.relics[y+1] then
        relics.list[cv2data.relics[y+1].varName]=true
        setRelicState(cv2data.relics[y+1].varName, true)
    else
        emu.message(string.format("Invalid Relic: %02x",y+1))
    end
end)

-- get sacred flame
--memory.registerexec(0x87d1,1, function()
    --local a,x,y,s,p,pc=memory.getregisters()
--    getItem("Sacred Flame", true)
--end)

-- character printing; change heart to "G" in messages
function onWindowPrintChar(c)
    if not pausemenu then
        if c==0x61 then c=0x07 end
        return c
    end
end

-- get an item/relic from npc (such as holy water)
memory.registerexec(0xede9,1, function()
    local a,x,y,s,p,pc=memory.getregisters()
    
    local address = memory.readbyte(0+y)
    local n=memory.readbyte(0xee14+x)
    local itemNum = 0
    for i=0,15 do
        if n==2^i then
            itemNum = i
        end
    end
    
    
    if address==0x91 then
        -- get relic, turn it on by default
        relics.list[cv2data.relics[itemNum+1].varName]=true
        setRelicState(cv2data.relics[itemNum+1].varName, true)
        --emu.message(cv2data.relics[itemNum+1].name)
    elseif address==0x4a then
        if cv2data.weapons[itemNum+1] then
            getItem(cv2data.weapons[itemNum+1].name, true)
        end
    elseif address==0x92 then
        -- get relic, turn it on by default
        
        if itemNum == 0 then
            --getItem("Silk Bag", true)
        end
        if itemNum == 2 then
            getItem("Laurel", true)
            getItem("Laurel", false)
            objects.player.laurels = objects.player.laurels +2
            memory.writebyte(0x004c, objects.player.laurels)
        end
        if itemNum == 3 then
            getItem("Garlic", true)
            getItem("Garlic", false)
            objects.player.garlic = objects.player.garlic +2
            memory.writebyte(0x004d, objects.player.garlic)
        end

--        relics.list[cv2data.relics[itemNum+1].varName]=true
--        setRelicState(cv2data.relics[itemNum+1].varName, true)

--        if cv2data.weapons[itemNum+1] then
--            getItem(cv2data.weapons[n+1].name, true)
--        end
        --emu.message("test item thing: "..cv2data.weapons[n+1].name)
    end
    
    
    
--    for i=0,7 do
--        if n==2^i then
--            if cv2data.weapons[i+1] then
--                getItem(cv2data.weapons[i+1].name, true)
--                    emu.pause()
--            end
--        end
--    end
end)

-- get a whip from npc (such as thorn whip)
memory.registerexec(0xedf4,1, function()
    local a,x,y,s,p,pc=memory.getregisters()
    if cv2data.whips.names[a] then
        getItem(cv2data.whips.names[a], true)
    end
end)


memory.registerexec(0xd7ad,1, function()
    local a,x,y,s,p,pc=memory.getregisters()
    if not config.quickDayNight then return end
    if a==0x06 then
        memory.writebyte(0x002c, 0x06) -- day/night toggle thing
        memory.writebyte(0x0088, 0x01) -- day/night toggle counter
--        a=0
--        emu.message("day")
--        day = math.min(99, day+1)
--        memory.writebyte(0x0083, day)
--        game.applyDay = true
--        memory.writebyte(0x0082, 0)
        a=0
    end
    memory.setregister("a", a)
end)

memory.registerexec(0xd7b1,1, function()
    local a,x,y,s,p,pc=memory.getregisters()
    if not config.quickDayNight then return end
    if a==0x18 then
        memory.writebyte(0x002c, 0x06) -- day/night toggle thing
        memory.writebyte(0x0088, 0x01) -- day/night toggle counter
        
        --emu.message("night")
        --game.applyNight = true
        --memory.writebyte(0x0082, 1)

        --local address=0x3f09
--        memory.writebyteppu(address+0,0x02)
--        memory.writebyteppu(address+1,0x13)
--        memory.writebyteppu(address+2,0x0c)

--        memory.writebyte(0x70c+0,0x02)
--        memory.writebyte(0x70c+1,0x13)
--        memory.writebyte(0x70c+2,0x0c)

--        memory.writebyteppu(address+0,0x02)
--        memory.writebyteppu(address+1,0x13)
--        memory.writebyteppu(address+2,0x0c)
    end
    a=0
    memory.setregister("a", a)
end)

-- found this spot by doing a breakpoint on $2002 (PPUSTATU) and
-- checking to see if bit 7 is set (vblank).  Basically it's 
-- probably a safe place to do ppu writes.
function onVBlank()
    if game.applyDay and false then
        local address=0x3f09
        memory.writebyteppu(address+0,0x22)
        memory.writebyteppu(address+1,0x20)
        memory.writebyteppu(address+2,0x1a)
        game.applyDay = not game.applyDay
        emu.message(string.format("Day %2d",day+1))

        if inTown then
            memory.writebyte(0x002c, 2) -- reload level
        end

    end
    
    if game.applyNight and false then
    
        local address=0x3f09
        memory.writebyteppu(address+0,0x02)
        memory.writebyteppu(address+1,0x13)
        memory.writebyteppu(address+2,0x0c)
        game.applyNight = not game.applyNight
        
        -- classic pink blocks
--        local address=0x3f00
--        memory.writebyteppu(address+1,0x26)
--        memory.writebyteppu(address+2,0x20)
--        memory.writebyteppu(address+3,0x16)

        if inTown then
            memory.writebyte(0x002c, 2) -- reload level
        end
    end
    
    if game.applyPlayerPalette and action then
        game.applyPlayerPalette = game.applyPlayerPalette - 1
        if game.applyPlayerPalette <= 0 then
            if spidey.debug.enabled then spidey.message("apply palette") end
            memory.writebyteppu(0x3f10, objects.player.palette[1])
            memory.writebyteppu(0x3f11, objects.player.palette[2])
            memory.writebyteppu(0x3f12, objects.player.palette[3])
            memory.writebyteppu(0x3f13, objects.player.palette[4])
            game.applyPlayerPalette = false
        end
    end
end

memory.registerexec(0xc85a,1, function()
    if (game.resetCounter or 0) > 0 then return end
    
    --if not (action or game.paused or game.pausemenu ) then return end
    --emu.message(string.format("palette %d bank %02x", spidey.counter, getBank(0xc85a)))
    
    local a,x,y,s,p,pc=memory.getregisters()
    
    objects.player.palette = objects.player.palette or cv2data.palettes.simon[1].palette 
    --objects.player.paletteIndex = objects.player.paletteIndex or 1
    ---local palette = cv2data.palettes.simon[objects.player.paletteIndex].palette
--    palette = {0x0f, 0x0f, 0x16, 0x20} -- original black and red
--    palette = {0x0f, 0x0f, 0x1c, 0x20} -- black and blue
--    palette = {0x0f, 0x0f, 0x17, 0x37} -- original look, slightly less red, more skin tone
--    palette = {0x0f, 0x0f, 0x13, 0x35} -- black and purple
--    palette = {0x0f, 0x0f, 0x14, 0x23} -- black and purple (better?)
--    palette = {0x0f, 0x08, 0x16, 0x33} -- lighter version of original; brown and redish
--    palette = {0x0f, 0x08, 0x27, 0x37} -- classic tan
--    palette = {0x0f, 0x08, 0x17, 0x37} -- darker version of classic tan; slightly more redish
    
    if x>=0x13 and x<=0x16 then
        local i = x-0x13+1
        a = objects.player.palette[i]
        memory.setregister("a", a)
    end
    
    
end)

-- mode select: override to game start when password is selected
memory.registerexec(0xc390,1, function()
    local a,x,y,s,p,pc=memory.getregisters()
    
    local gameMode=memory.readbyte(0x23)
    if gameMode == 1 then
        -- We load once here just to display the right saved lives, but 
        -- load again later to load all the rest of the data.
        if loadGame(game.saveSlot, true) then
            game.loadTimer=5
            game.loadAgain = true
            memory.writebyte(0x7400, game.saveSlot)
        else
            -- Not loaded; start new game instead.
            memory.writebyte(0x7000,0) -- wipe all extra data
        end
        --emu.message("load")
    elseif gameMode == 0 then
        --emu.message("start new game")
        memory.writebyte(0x7000,0) -- wipe all extra data
    end
    
    --game.modeCounter =memory.readbyte(0x002a)
    --memory.writebyte(0x002a, 0x01)
    --emu.pause()
    
    a=0
    memory.writebyte(0x23,0)
    memory.setregister("a",a)
end)


-- Modify time to start game after pressing start on mode select
function onSetGameStartDelay(delay)
    delay=0x30
    return delay
end

-- title tm text
memory.registerexec(0xc6f5+2,1, function()
    local a,x,y,s,p,pc=memory.getregisters()
    local address = memory.readbyte(1)*0x100+memory.readbyte(0)+y
    
    if address >= 0x8159 and address<= 0x8159+0x0d then
        --a=0xc1
        --memory.setregister("a",a)
    end
    memory.setregister("a",a)
end)

--prologue
memory.registerexec(0xc84b+2,1, function()
    local a,x,y,s,p,pc=memory.getregisters()
    local address = memory.readbyte(1)*0x100+memory.readbyte(0)+y
    if address >= 0x8358 and address<= 0x8358+0x40 then
        --a=0xc1
    end
    memory.setregister("a",a)
end)

-- on music change
memory.registerexec(0xcd2c+3,1, function()
    local a,x,y,s,p,pc=memory.getregisters()
    --emu.message(string.format("music=%02x",a))
    if spidey.debug.enabled then emu.message(string.format("music=%02x",a)) end
    
    if config.music == false then
        a=0
        memory.writebyte(0x00, a)
    end
    memory.setregister("a",a)
end)

-- on sfx (can't change to 0 without muting music, use 0x62 instead)
memory.registerexec(0xc127,1, function()
    local a,x,y,s,p,pc=memory.getregisters()
    if spidey.debug.enabled then spidey.message("sfx=%02x",a) end
    
    if bat then
        -- disable whip sfx if bat mode
        if a==0x0a then a=0x62 end
        if a==0x0e then a=0x62 end
        if a==0x0f then a=0x62 end
    end
    
    if a == 0x0e and objects.player.whipItem == items.index["Thief's Dagger"] then a=0x11 end
    
    
    -- Remove blob sfx if in camilla cemetary
    if a == 0x0b and not inMansion then a=0x62 end
    
    -- Change Golden Knife sound effect
    if a == 0x13 then a=0x11 end
    
    -- Dracula music
    if config.music == false and a==0x4d then a=0x62 end
    if config.music == false and a==0x55 then a=0x62 end
    
    -- you know what?  get rid of all these dumb 'item get' sound effects for now.
    if a == 0x22 then a=0x62 end
    
    -- Silence the item get sound from diamond guy if you already got it.
    -- Note: you get the item before sfx plays so it's more 
    -- complicated than using hasInventoryItem("Diamond").
    if msgnum == 0x12 and a==0x22 and displayarea == "Vrad Mountain" then
        if util.removeLineBreaks(game.customMessage) ~= "I'LL GIVE YOU A DIAMOND." then
            a=0x62
        end
    end
    
    -- Flame whip guy sfx (just remove sfx completely for now)
    if msgnum == 0x0e and a == 0x22 then
        a=0x62
    end
    
    -- Flame whip guy: remove "come back" sfx.
    if msgnum == 0x75 and a == 0x22 then
        a=0x62
    end
    
    -- silence cursor on map screen
    if a==0x31 and game.map.visible then a=0x62 end
    
    if config.music == false then
        -- break seal on dracula part; change to version that doesn't restart music
        if a==0x2f then a=0x30 end
        
        -- the above music change event doesn't do mansion music, so we handle it here
        if a==0x45 then a=0x62 end
    end
    
    -- 5 message print sound
    -- 6 tornado
    -- 7 jump land
    -- 0a whip
    -- 0b slime
    -- 0d swamp
    -- 0e whip?
    -- 0f flame whip
    -- 12 diamond bounce
    -- 13 golden dagger
    -- 14 shield reflect
    -- 15 sacred flame
    -- 16 holy water
    -- 18 hurt enemy
    -- 19 fast whoosh sound
    -- 1a kill enemy
    -- 1d fall in water
    -- 1e destroy blocks
    -- 1f collect heart
    -- 20 use laurel
    -- 21 destroy dracula
    -- 22 get item
    -- 24 can't buy buzz
    -- 25 bought item
    -- 26 fill hp from church?
    -- 27 level up
    -- 28 longer tornado? (glitchy?)
    -- 29 ?
    -- 2d magic sfx (tornado 2nd part?)
    -- 2f break seal on dracula part sfx, also restarts mansion music
    -- 30 break seal on dracula part sfx, does not restart mansion music
    -- 31 cursor
    -- 34 death
    -- 35 death
    -- 38 ?? would be good for a freeze sfx
    -- 39 town music
    -- 3a-3c town music background parts
    -- 3d outside music
    -- 41 night music
    -- 45 mansion music
    -- 49 dracula castle music
    -- 4d dracula battle
    -- 51 game over
    -- 55 select screen
    -- 59 ending
    -- 5d drum
    -- 5e drum
    -- 5f get hit
    -- 60 pause
    -- 61 silent sfx (mutes others)
    -- 62 silent sfx (doesn't mute others)
    --a=0x62
    
    --a=0x00
    memory.setregister("a",a)
    --memory.writebyte(0x0f, a)
    

end)


-- sfx/music parts
memory.registerexec(0xc118,1, function()
    local a,x,y,s,p,pc=memory.getregisters()
    --if spidey.debug.enabled then emu.message(string.format("sfx=%02x",a)) end

    do return end
    --a=0
    --config.music=true
    if config.music == false then
        -- this will crudely turn off music when any sfx plays
        -- and mute that one sfx as a side effect.  better than
        -- nothing
        if memory.readbyte(0x11b) ~=0 then
            --memory.writebyte(0x1b,0x00)
            a=0
        end
        if a==0x39 then a=0 end
        if a==0x3d then a=0 end
        if a==0x41 then a=0 end
        if a==0x45 then a=0 end
        if a==0x49 then a=0 end
        if a==0x4d then a=0 end
        if a==0x55 then a=0 end
    end
    
    --if a==0x31 and game.map.visible then a=0 end
    
    memory.setregister("a",a)
end)

-- Triggered when a sp weapon breaks
function onSubWeaponBreak(currentWeapon, i)
    if currentWeapon == 4 then
        for j=0,0 do
            local onum=getunusedcustom()
            if (onum) then
                objects.custom[onum].type="holyfire"
                objects.custom[onum].x=objects.weapons[i].x+scrollx
                objects.custom[onum].y=objects.weapons[i].y+scrolly
                --objects.custom[onum].xs=math.random(-5,5)*.4
                --objects.custom[onum].ys=-j*.2-2
                objects.custom[onum].xs=0
                objects.custom[onum].ys=0
                objects.custom[onum].active=1
                objects.custom[onum].outscreen=true
            end
        end
    end
end

--dereg={0xda69,0x8918,0x8147,0x883a,0x8a5f,0xd7ea,0x80ec,0xde7b,0xc5ad,0xc50b,0xcc77,0xd4f7,0xe38d}
--for i=1,#dereg do
--    memory.registerexec(dereg[i],1,nil)
--end


function romPatch()
    local rom_writebyte = function(address, value)
        if not game.romUndo[address] then 
            game.romUndo[address] = rom.readbyte(address, value)
            game.romUndo.index[#game.romUndo.index+1] = address
        end
        rom.writebyte(address, value)
    end
    
    local rom_writebytes = function(address, str)
        for i = 0, #str-1 do
            rom_writebyte(address+i,string.byte(str,i+1))
        end
    end
    
    -- This adds a little patch that makes it so when you poke a value
    -- to 0x7500 it plays a sound effect.
    --put 1ce0e 20edfe
    --put 1feed 203a86  48 ad0075 f008  2018c1 a900 8d0075  68 60
    rom_writebytes(0x1c08a+0x10, spidey.hex2bin("20edfe"))
    rom_writebytes(0x1feed+0x10, spidey.hex2bin("208ac848ad0075f0082018c1a9008d00756860"))

    -- remove hp graphics
    rom_writebytes(0x21600+0x10, string.rep(string.char(0x00), 0x60))
    rom_writebytes(0x23600+0x10, string.rep(string.char(0x00), 0x60))
    rom_writebytes(0x25600+0x10, string.rep(string.char(0x00), 0x60))
    rom_writebytes(0x27600+0x10, string.rep(string.char(0x00), 0x60))
    rom_writebytes(0x29600+0x10, string.rep(string.char(0x00), 0x60))
    rom_writebytes(0x2a600+0x10, string.rep(string.char(0x00), 0x60))
    rom_writebytes(0x2c600+0x10, string.rep(string.char(0x00), 0x60))
    
    -- remove exp cap thing based on area
    rom_writebyte(0x1d518+0x10, 0xc9)
    rom_writebyte(0x1d519+0x10, 0x00)
    
    --increase level cap to 99
    rom_writebyte(0x1d53c+0x10, 0xc9)
    rom_writebyte(0x1d53d+0x10, 0x63)
    
    --don't increase hp for level up
    rom_writebyte(0x1d57f+0x10, 0xea)
    rom_writebyte(0x1d580+0x10, 0xea)

    -- Change golden dagger throw sfx
    --rom_writebyte(0x1d90c+0x10, 0x11)
    
    
--    if tile==0xd9 then tile=0 end
--    if tile==0xdb then tile=0 end
--    if tile==0xda then tile=0 end
--    if tile==0xdc then tile=0 end

--    for i=0,0x0f do
--        rom_writebyte(0x10+0x28000+0x10*0xd9+i, 0)
--        rom_writebyte(0x10+0x28000+0x10*0xdb+i, 0)
--        rom_writebyte(0x10+0x28000+0x10*0xda+i, 0)
--        rom_writebyte(0x10+0x28000+0x10*0xdc+i, 0)
--    end

--    for i=0,0x0f do
--        rom_writebyte(0x10+0x28000+0x10*0xd9+i, rom.readbyte(0x10+0x28000+0x10*0xf6+i))
--        rom_writebyte(0x10+0x28000+0x10*0xdb+i, rom.readbyte(0x10+0x28000+0x10*0xf8+i))
--        rom_writebyte(0x10+0x28000+0x10*0xda+i, rom.readbyte(0x10+0x28000+0x10*0xf7+i))
--        rom_writebyte(0x10+0x28000+0x10*0xdc+i, rom.readbyte(0x10+0x28000+0x10*0xf9+i))
--    end

end

function hasRelic(n)
    if n==6 then return relics.list.whiteCrystal end
    if n==7 then return relics.list.blueCrystal end
    if n==8 then return relics.list.redCrystal end
    return (relics.main == bit.bor(relics.main, 2^(n-1)))
end
function hasItem(n)
    return (objects.player.items == bit.bor(objects.player.items, 2^(n-1)))
end

savestate.registerload(function()
    objects.custom.destroyall()
    objects.custom.createCandles()
    objects.custom.createLevelObjects()
end)

emu.registerexit(function(x)
    emu.message("")
    if game.romUndo then
        for _,a in ipairs(game.romUndo.index) do
            rom.writebyte(a,game.romUndo[a])
        end
    end

end)

function spidey.reset()
    setArmor(items.index["Dummy Armor"])
    --setArmor(items.index["Night Armor"])
    --objects.player.armor=false
end
spidey.reset2=spidey.reset

function spidey.update(inp,joy)
    hitboxes.update()
    lastinp=inp
    if config.md5 then
        if not game.md5 then
            -- We have to reload here to make sure the rom hasn't been changed with rom.writebyte.
            if not spidey.reloadfile() then
                spidey.error = function()
                    --#000040d0
                    gui.drawbox(0,0,spidey.screenWidth-1,spidey.screenHeight-1,"#807070a0", "#807070a0")
                    gui.text(20,40,"ERROR: Could not test MD5 properly. Please \nupgrade FCEUX to at least 2.2.3.", "white", "clear")
                end
                config.md5=false
            end
        end
        game.md5 = game.md5 or require 'cv2.md5'
        game.md5Data = game.md5Data or {address=0, size = spidey.getRomSize(), m=game.md5.new()}
        
        for i=1, 2000 do
            local b = game.romUndo[game.md5Data.address] or rom.readbyte(game.md5Data.address)
            
            game.md5Data.m:update(string.char(b))
            game.md5Data.address=game.md5Data.address+1
            
            if game.md5Data.address>=game.md5Data.size then
                game.md5Data.md5 = game.md5.tohex(game.md5Data.m:finish())
                spidey.message("")
                config.md5 = nil
                break
            else
                spidey.message("calculating md5...%d%%", math.floor((game.md5Data.address/262160)*100))
            end
        end
    end
    
    
    if config.testEnding then
        if config.testEnding<1 or config.testEnding>3 then
            spidey.message("Invalid testEnding value %s",testEnding)
            config.testEnding=nil
        else
            memory.writebyte(0x0026, 0) -- make sure we remove pause
            memory.writebyte(0x03c6,0) -- turn on player rendering (it's off if paused)
            
            -- apply number of days to select ending
            config.testEnding = math.max(1,math.min(3, config.testEnding))
            memory.writebyte(0x0083, (config.testEnding-1)*0x12)

            memory.writebyte(0x0018,0x0c) -- set mode to ending
            memory.writebyte(0x002a,0x01) -- set mode countdown to 1
        end
        config.testEnding=nil
    end
    
    game.modeMain=memory.readbyte(0x0018)
    game.mode=memory.readbyte(0x0019)
    game.mode2=memory.readbyte(0x00aa)
    game.modeCursor=memory.readbyte(0x23) -- start or continue
    game.modeCounter =memory.readbyte(0x002a)
    game.resetCounter = memory.readword(0x7410)
    
    game.paused=(memory.readbyte(0x0026)==02)
    pausemenu=(memory.readbyte(0x0026)==01)
    subScreen.realCursorY = memory.readbyte(0x33)
    --subScreen.cursorY = subScreen.cursorY or (subScreen.realCursorY+1)
    subScreen.cursorY = subScreen.cursorY or 1
    --cursorY = memory.readbyte(0x33)
    -- see callback above for mapmenu info
    if not game.paused then mapmenu = false end
    
    actionval=memory.readbyte(0x001c)
    actionval2=memory.readbyte(0x001a)
    action=(actionval==0x01 or (actionval==02 and actionval2==01) or (actionval==04 and actionval2==01))
    if action and (memory.readbyte(0x002c)==0x02) then
        action = false
    end
    
    --action=(memory.readbyte(0x001c)==0x01) -- not perfect; sometimes it can be 02 or 04
    areaFlags=memory.readbyte(0x008f)
    area1=memory.readbyte(0x0030)
    area2=memory.readbyte(0x0050)
    area3=memory.readbyte(0x0051) % 0x80 --adds 0x80 if starting on right side
    returnArea=memory.readbyte(0x004e)
    area4=returnArea
    returnScroll1 = memory.readbyte(0x0458)
    returnScroll2 = memory.readbyte(0x046a)
    returnX = memory.readbyte(0x04a0)
    returnY = memory.readbyte(0x04b2)
    screenload=(memory.readbyte(0x0021)>01) --not perfect yet; goes off on some non-screen loads
    scrollx=memory.readbyte(0x0053)+memory.readbyte(0x0054)*0x100
    scrolly=memory.readbyte(0x0056)+memory.readbyte(0x0057)*0xe0
    msgnum=memory.readbyte(0x007f)
    game.messageNum=msgnum
    msgstatus=memory.readbyte(0x007a) --04 = printing
    --subScreen.enter = false
    subScreen.exit = false
    if pausemenu and joy[1].start_press and msgstatus == 04 then
        --if msgstatus == 0 then subScreen.enter = true end
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
    night = (memory.readbyte(0x0082)==0x01)
    borderColor = "#0070ec"
    if night then borderColor = "#24188c" end
    
    relics.main = memory.readbyte(0x0091)
    relics.current=memory.readbyte(0x004F)
    if cv2data.relics[relics.current] then
        relics.name=cv2data.relics[relics.current].name
        relics.displayName=cv2data.relics[relics.current].displayName or cv2data.relics[relics.current].name
    else
        --emu.message(string.format("%02x",relics.current))
        relics.name=nil
        relics.displayName = nil
    end
    
--    relics.list.rib = (relics.main == bit.bor(relics.main, 0x01))
--    relics.list.heart = (relics.main == bit.bor(relics.main, 0x02))
--    relics.list.eye = (relics.main == bit.bor(relics.main, 0x04))
--    relics.list.nail = (relics.main == bit.bor(relics.main, 0x08))
--    relics.list.ring = (relics.main == bit.bor(relics.main, 0x10))
    
--    relics.list.whiteCrystal = (relics.main == bit.bor(relics.main, 0x20))
--    relics.list.blueCrystal = (relics.main == bit.bor(relics.main, 0x40))
    
--    if relics.list.whiteCrystal and relics.list.blueCrystal then
--        relics.list.redCrystal = true
--        relics.list.whiteCrystal = nil
--        relics.list.blueCrystal = nil
--    end
    
    relics.nParts = 0
    for k,v in pairs(relics.list) do
        if v== true then relics.nParts = relics.nParts + 1 end
    end
    hour=tonumber(string.format("%02x",memory.readbyte(0x0086)))
    minute=tonumber(string.format("%02x",memory.readbyte(0x0085)))

    time=string.format('%02X:%02X',memory.readbyte(0x0086),memory.readbyte(0x0085))
    --timeWithDays =string.format("%02X:", memory.readbyte(0x0087), time)
    day = memory.readbyte(0x0083)
    game.night=(memory.readbyte(0x82)==0x01)
    hearts=string.format('%01X%02X',memory.readbyte(0x0049),memory.readbyte(0x0048))
    pattern1=memory.readbyte(0x0101)
    pattern2=memory.readbyte(0x0102)
    --inTown = (pattern1==0x00 and pattern2==0x01)
    inTown = (area1==0)
    inDoor = (areaFlags==0x01)
    inMansion = (pattern1==0x08)
    
--    pattern1=0
--    pattern2=1
--    memory.writebyte(0x0101, pattern1)
    
    --gui.text(20,50,string.format("mode=%02x mode2=%02x",game.mode, game.mode2))
    
    if game.modeMain==0x0a and memory.readbyte(0x047a)==0x07 then
        local endingCountDown = memory.readbyte(0x047c)
        
        if game.credits.show then
            endingCountDown = 2
        elseif game.credits.done then
            if game.showSaveMenu then
                endingCountDown = 2
            else
                endingCountDown = 1
                -- Need to draw over this one frame so we don't see a flash of ending before reset
                gui.drawbox(0, 0, spidey.screenWidth-1, spidey.screenHeight-1, "black", "black")
            end
        elseif endingCountDown == 1 then
            game.credits.show = true
            game.credits.y = 0
            endingCountDown = 2
        end
        
        memory.writebyte(0x047c, endingCountDown)
    end
    
    if game.credits.show and game.credits.y == 0x94 then
        queueSound(0x3d)
    end
    
    if game.showSaveMenu then
        gui.drawbox(0, 0, spidey.screenWidth-1, spidey.screenHeight-1, "black", "black")
        --gui.drawbox(8*5,8*10,8*20,8*15,"black","black")
        drawfont(8*6,5+8*10,font[current_font], "Save?")
        drawfont(8*9,5+8*12,font[current_font], "Yes   No")
        if ((spidey.counter %4<3) or config.noBlinkCursor) then
            gfx.draw(8*9-8-4 +(8*6)*game.saveCursor,5+8*12,gfx.arrowcursorRight)
            --gui.drawbox(x+28+(subScreen.cursorX*16-16)-2,y+28+8*8-2+16*subScreen.cursorY,x+28+(subScreen.cursorX*16-16)+8+1,y+28+8*8+8+1+16*subScreen.cursorY,"clear","blue")
        end
        if joy[1].right_press_repeat or joy[1].left_press_repeat then
            game.saveCursor = (game.saveCursor +1) % 2
            queueSound(0x05)
        end
        if joy[1].confirm_press then
            if game.saveCursor == 0 then
                newGamePlus()
                saveGame(game.saveSlot)
            end
            game.showSaveMenu = false
        end
    end
    
    if game.mode==0x00 and game.resetCounter > 0 then
        game.resetCounter = game.resetCounter - 1
        memory.writeword(0x7410, game.resetCounter)
        gui.drawbox(0,0,spidey.screenWidth-1,spidey.screenHeight-1,"black","black")
        drawfont(8*11,8*13,font[current_font], "GAME OVER" )
        --drawfont(8*11,8*15,font[current_font], string.format("%d",game.resetCounter))
        if game.resetCounter == 0 or (game.resetCounter < 70 and joy[1].start_press)then
            game.resetCounter = 0
            memory.writeword(0x7410, game.resetCounter)
            emu.softreset()
            --emu.poweron()
            emu.message("") -- suppress the "reset" message
        end
    end
    
    if game.mode==0x04 then
        --gui.text(20,50,"mode screen")
        
        if game.modeCursor == 1 or true then
            drawfont(8*12,8*19,font[current_font], "Continue "..game.saveSlot)
            game.saveCache = game.saveCache or {}
            game.saveCache[game.saveSlot] = game.saveCache[game.saveSlot] or (getGameSaveData(game.saveSlot) or "empty")
            local s = game.saveCache[game.saveSlot]
            
            local x,y
            x=8
            y=8*24
            local borderColor = spidey.nes.palette[0x20]
            --if night then borderColor = "#24188c" end
            
            if s=="empty" then
                gui.drawbox(x,y,x+8*29,y+8*3,"black",borderColor)
                gui.drawbox(x-1,y+1,x+8*29+1,y+8*3-1,"clear",borderColor)
                drawfont(x+8*1,y+8,font[current_font], "empty" )
            else
                -- for now, always display return area since you only save inside church.
                -- need to update this later for cheat saves where you save anywhere.
                
                local displayarea
                if areaFlags == 1 then
                    displayarea = locations.getAreaName(0,s.returnArea,0)
                else
                    displayarea = locations.getAreaName(s.area1,s.area2,s.area3)
                end
                
                --gui.text(20,50,string.format("Simon Level %d %s",s.level+1, displayarea))
                
                local loopText = ""
                if (s.loop or 0) > 0 then loopText = " loop "..s.loop end
                gui.drawbox(x,y,x+8*30,y+8*4,"black",borderColor)
                gui.drawbox(x-1,y+1,x+8*30+1,y+8*4-1,"clear",borderColor)
                drawfont(x+8*1,y+8,font[current_font], string.format("%d. Simon Level %d\n   Day %d %s %s",game.saveSlot, s.level+1,s.day+1, displayarea, loopText) )

                -- draw relics
                for i=1,8 do
                    if s.relicsList[cv2data.relics[i].varName] then
                        gfx.draw(x+8*18+8*i,y+8*1,gfx.relics[i])
                    end
                end
            end
        else
            drawfont(8*12,8*19,font[current_font], "Continue ")
        end
    end
    if game.mode==0x05 then
        --game.mode=0x04
        --memory.writebyte(0x0019, game.mode)
        game.modeCounter = 1
        memory.writebyte(0x002a, game.modeCounter)
        
        memory.writebyte(0x0023, 0)
    end
    
    -- title screen
    if memory.readbyte(0x18)==0x1 and (game.mode==0x00 and memory.readbyte(0xff)~=0xa9) then
        -- Apply a simple fade out.  It's not very smooth, but this actually gives it
        -- more of a NES quality, so I'm ok with that.
        if game.modeCounter<0x18 then
            local c = string.format("#000000%02x", 0x18*4 - game.modeCounter*4)
            gui.drawbox(0, 0, spidey.screenWidth-1, spidey.screenHeight-1, c, c)
        end
--           spidey.message("%02x %02x",game.mode, game.modeCounter)
--        local c = spidey.nes.palette[0x0c]
--        gui.drawbox(0, 0, spidey.screenWidth, 8*3, c,c)
--        gui.drawbox(0, 8*6, spidey.screenWidth, 8*8+9, c,c)
        
--        gui.drawbox(0, 0, 8*5, 8*6, c,c)
--        gui.drawbox(spidey.screenWidth-8*5, 0, spidey.screenWidth, 8*6, c,c)
        
--        gui.drawbox(0, 8*25+2, spidey.screenWidth, spidey.screenHeight, c,c)
--        game.filmScroll = 0
--        for i=1,17 do
--            gui.drawbox(0+8*0+6,i*7*2-game.filmScroll, 0+8*0+6+11,i*7*2+7-game.filmScroll, "black", "black")
--            gui.drawbox(0+8*0+6-1,i*7*2+1-game.filmScroll, 0+8*0+6+11+1,i*7*2+7-1-game.filmScroll, "black", "black")
--            gui.drawbox(spidey.screenWidth-(8*0+6),i*7*2-game.filmScroll, spidey.screenWidth-(8*0+6+11),i*7*2+7-game.filmScroll, "black", "black")
--            gui.drawbox(spidey.screenWidth-(8*0+6-1),i*7*2+1-game.filmScroll, spidey.screenWidth-(8*0+6+11+1),i*7*2+7-1-game.filmScroll, "black", "black")
--        end
        game.film.y = 0
        game.film.counter = 0
        game.film.scroll = 0
    end
    
    if memory.readbyte(0x18)==0x1 and (game.mode==0x01 or (game.mode==0x00 and memory.readbyte(0xff)==0xa9)) then
        if spidey.counter % 2 == 0 then
            --game.film.scroll = (game.film.scroll + 1) % 14
            game.film.y = game.film.y + 1
        end
        game.film.scroll = (game.film.scroll + 2) % 14
        gui.drawbox(0, 0, spidey.screenWidth-1, spidey.screenHeight-1, "black", "black")
        gui.drawbox(0+8*2, 0, spidey.screenWidth-1-8*2, spidey.screenHeight-1, "P0c", "P0c")
        --emu.message(string.format("%s", spidey.nes.palette[0x0c]))
        for i=1,17 do
            gui.drawbox(0+8*2+6,i*7*2-game.film.scroll, 0+8*2+6+11,i*7*2+7-game.film.scroll, "black", "black")
            gui.drawbox(0+8*2+6-1,i*7*2+1-game.film.scroll, 0+8*2+6+11+1,i*7*2+7-1-game.film.scroll, "black", "black")
            gui.drawbox(spidey.screenWidth-(8*2+6),i*7*2-game.film.scroll, spidey.screenWidth-(8*2+6+11),i*7*2+7-game.film.scroll, "black", "black")
            gui.drawbox(spidey.screenWidth-(8*2+6-1),i*7*2+1-game.film.scroll, spidey.screenWidth-(8*2+6+11+1),i*7*2+7-1-game.film.scroll, "black", "black")
        end
        if game.film.y>=0x350 then
        else
            memory.writebyte(0xfd,0xf0) -- prevent scrolling so intro lasts forever
        end
        if game.film.y<=8*34+3 then
            gui.drawbox(0,0, spidey.screenWidth,(8*34+3)-(game.film.y or 0), "black","black")
        end
        
        --drawfont(100,100,font[5], string.format("%02x",game.film.y) )
        --game.film.y = 0x300
        story = cv2data.story
        
        story = string.gsub(story, "\n", "\n\n")
        
        gfx.draw(8*5+48+8*6-8*11,8*40-(game.film.y or 0)+8*10,gfx.castle)
        
        drawfont(8*5+4,8*40-(game.film.y or 0),font[5], story)
        --drawfont(8*5+4,8*40-(game.film.y or 0),font[5], "       PROLOGUE\n\n\n\n\nSTEP INTO THE SHADOWS\n\nOF THE HELL HOUSE.\n\nYOUVE ARRIVED BACK\n\nHERE AT TRANSYLVANIA\n\nON BUSINESS: TO\n\nDESTROY FOREVER THE\n\nCURSE OF THE\n\nEVIL COUNT DRACULA.")
    end
    
--    game.mode=memory.readbyte(0x0019)
--    game.mode2=memory.readbyte(0x00aa)
--    game.modeCounter =memory.readbyte(0x002a)
    
    romPatch()
    
    updateSoundQueue()
    
    
    local bank = 2
    for i=0,0x0f do
        --rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xd9+i, rom.readbyte(0x10+0x20000+bank*0x1000+0x10*0xd9+i+8))
        --rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xf6+i, 0)
        --rom.writebyte(0x10+0x20000+bank*0x1000+0x10*0xf8+i, 0)
        
        --20f60
    end
    
    
    if config.quickDayNight then
        -- day/night toggle thing
        if memory.readbyte(0x002c) == 0x07 then
            memory.writebyte(0x0088, 0x00) -- day/night toggle counter
        end
    end
    
    if action and game.loadAgain then
        if (game.loadTimer or 0) > 1 then
            game.loadTimer = game.loadTimer-1
        else
            loadGame(game.saveSlot, true) -- setArea=true
            --exitSubScreen() --needed to refresh weapon/relic stuff
            game.loadAgain = nil
        end
    end
    
    if spidey.debug.enabled then gui.text(4,4+8*9,string.format('Pattern tables: %02X %02X',pattern1,pattern2)) end
    
--    if quickmessages==true and action and messages[msgnum] and memory.readbyte(0x003f)~=0 then --if close to message
--        quickMessagePopupWait = (quickMessagePopupWait or 0) + 1
--        if quickMessagePopupWait >=40 then
--            local x=0
--            local y=32
--            gui.drawbox(x+28-8, y+28+1-8,x+ 24+8*13+8, y+24+8*08+8, "black", "black")
--            gui.drawbox(x+28-4, y+28-4, x+24+8*13+4,y+ 24+8*08+4+1, "black", "#0070EC")
--            gui.drawbox(x+28-4-1, y+28-4+1, x+24+8*13+4+1, y+24+8*08+4+1-1, "clear", "#0070EC")
--            drawfont(x+28,y+28,font[current_font], messages[msgnum])
--        end
--    else
--        quickMessagePopupWait = 0
--    end

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
        --messages[msgnum]=msg
        --emu.message(msg)
    end
    
    --if memory.readbyte(0x0056)==224 then
    --gui.text(20,20, "*******************"); -- force clear of previous text
    --end
    
    --gui.drawbox(0, 0, 256, 240, "black", "black")
    if action or pausemenu then
        
        objects.player.hp=memory.readbyte(0x0080)
        objects.player.maxHp=memory.readbyte(0x0081)
        --memory.writebyte(0x008b, 0x63) -- level 99
        objects.player.level=memory.readbyte(0x008b)
        objects.player.lives=memory.readbyte(0x0031)
        objects.player.laurels = memory.readbyte(0x004c)
        objects.player.garlic = memory.readbyte(0x004d)
        objects.player.hearts = tonumber(string.format('%01X%02X',memory.readbyte(0x0049),memory.readbyte(0x0048)))
        
        if objects.player.hearts > objects.player.maxHearts then
            objects.player.hearts = objects.player.maxHearts
            memory.writebyte(0x48, tonumber(string.format("%02d",objects.player.hearts % 100),16))
            memory.writebyte(0x49, tonumber(string.format("%02d",(objects.player.hearts-(objects.player.hearts % 100))/100),16))
        end
        
        objects.player.whip = memory.readbyte(0x0434)
        objects.player.items = memory.readbyte(0x004a)+memory.readbyte(0x0092)*0x100
        
        -- new hp formula
        --objects.player.maxHp=0x30+1*objects.player.level+4*relics.nParts
        objects.player.maxHp=0x30+1*relics.nParts
        memory.writebyte(0x0081, objects.player.maxHp)
        
        objects.player.hp=math.min(objects.player.maxHp, objects.player.hp)
        memory.writebyte(0x0080, objects.player.hp)
        
        objects.player.exp = math.min(9999, tonumber(string.format("%02x%02x", memory.readbyte(0x47), memory.readbyte(0x46))))
        objects.player.expNext = getExpNeeded()
        
        getExtraData()
        
        -- this is a first time thing
        if not game.customLoaded then
            objects.custom.destroyall()
            objects.custom.createCandles()
            objects.custom.createLevelObjects()
            game.customLoaded = true
        end
        
         -- joma marsh
         if action and not jomaMarsh() then
             --objects.player.pendant = (locations.getAreaName(area1,area2,area3) == "Joma Marsh" and objects.player.accessory == items.index["Pendant"] then
             objects.player.pendant = (objects.player.accessory == items.index["Pendant"])
         end
    end
    
    if action then
        objects.player.inBossRoom = false
        if spidey.debug.enabled then
            drawfont(0,5+8*5,spidey.debug.font,string.format("HP: %02X/%02X",objects.player.hp or 0,objects.player.maxHp or 0))
            drawfont(0,5+8*6,spidey.debug.font,string.format("Relics: %02X",relics.nParts) )
        end
    end
    
    
    -- Hide graphics for HP
--    if action or pausemenu then
--        memory.writebyte(0x0203,0xff)
--        memory.writebyte(0x0207,0xff)
--        memory.writebyte(0x020b,0xff)
--    end
    --if action or pausemenu then
    
    if config.jumpTweak and action then
        -- Increase downward velocity cap.  it makes you die in marsh if you fall far enough though.
        rom.writebyte( 0xca0a, 0x06)
        rom.writebyte( 0xca10, 0x06)

        game.fallCounter = game.fallCounter or 0
        game.jumpCounter = game.jumpCounter or 0
        local vy = memory.readbyte(0x036c)
        if vy==0 then game.jumpCounter = 0 end
        if vy==0xfc then
            game.jumpCounter = game.jumpCounter + 1
            memory.writebyte(0x040e, 0x11)
            if memory.readbyte(0x0300) ==0x05 then
                memory.writebyte(0x0300, 0x04)
            end
        elseif vy==0xfd then
            memory.writebyte(0x040e, 0x01)
            if memory.readbyte(0x0300) ==0x04 then
                memory.writebyte(0x0300, 0x05)
            end
        end
        
        if memory.readbyte(0x0068)==0x82 then
            if game.fallCounter>07 then
                memory.writebyte(0x040e, 0x11)
                if memory.readbyte(0x0300) ==0x05 then
                    memory.writebyte(0x0300, 0x04)
                end
            end
            game.fallCounter = game.fallCounter + 1
            --if game.fallCounter % 1==0 then
                local vy = memory.readbyte(0x036c)
                --vy=vy*1.06+.25
                if vy>3 then vy=vy+1 end
                --if vy>=5 then vy=vy+1 end
                memory.writebyte(0x036c, vy)
            --end
        else
            game.fallCounter = 0
        end
    end
    
    if game.getItemDelayed then
        if (game.getItemDelayCounter or 0) >1 then
            game.getItemDelayCounter = game.getItemDelayCounter - 1
        else
            getItem(game.getItemDelayed, true)
            game.getItemDelayed = nil
        end
    end
    
    if game.mode==0x04 and game.modeCounter == 0x80 then
        if joy[1].right_press_repeat and game.saveSlot<99 then
            game.saveSlot = math.min(99,game.saveSlot+1)
            queueSound(0x05)
        end
        if joy[1].left_press_repeat and game.saveSlot>1 then
            game.saveSlot = math.max(1,game.saveSlot-1)
            queueSound(0x05)
        end

        if joy[1].up_press or joy[1].down_press then
            -- Allow menu selection with up/down
            memory.writebyte(0x0023, (memory.readbyte(0x0023)+1) % 2)
            queueSound(0x05)
        end
    end
    
    --if subScreen.enter then enterSubScreen() end
    if subScreen.exit then exitSubScreen() end
    
    if (pausemenu) and game.map.visible then
        --if joy[1].up then game.map.y=game.map.y-1 end
        --if joy[1].down then game.map.y=game.map.y+1 end
        if joy[1].left then game.map.x=game.map.x-2 end
        if joy[1].right then game.map.x=game.map.x+2 end
        if game.map.x<0 then game.map.x=0 end
        if game.map.y<0 then game.map.y=0 end
        
        if game.map.x >game.map.width-spidey.screenWidth then
            game.map.x = game.map.width -spidey.screenWidth
        end
        if game.map.y+spidey.screenHeight >game.map.height then
            game.map.y = game.map.height-spidey.screenHeight
        end
    end
    
    if pausemenu then
        if not subScreen.cursorX then enterSubScreen() end
        if joy[1].up_press then
            if subScreen.showClues or game.map.visible then
            elseif subScreen.showRelics or subScreen.showItems or subScreen.showDebug then
                if subScreen.subMenu.y==0 and subScreen.subMenu.scrollY>0 then
                    subScreen.subMenu.scrollY=subScreen.subMenu.scrollY-1
                end
                subScreen.subMenu.y = math.max(0,subScreen.subMenu.y - 1)
            else
                subScreen.cursorY = math.max(1,subScreen.cursorY - 1)
            end
        end
        if joy[1].down_press then
            if subScreen.showClues or game.map.visible then
            elseif subScreen.showRelics or subScreen.showItems or subScreen.showDebug then
                if subScreen.subMenu.y==7 then
                    subScreen.subMenu.scrollY=subScreen.subMenu.scrollY+1
                end
                subScreen.subMenu.y = math.min(7,subScreen.subMenu.y + 1)
            else
                subScreen.cursorY = math.min(4,subScreen.cursorY + 1)
            end
        end
        if joy[1].left_press then
            if subScreen.showClues then
                subScreen.clue=subScreen.clue-1
                --if subScreen.clue<1 then subScreen.clue = #subScreen.clues end
                if subScreen.clue<1 then subScreen.clue = 1 end
            elseif subScreen.showRelics or subScreen.showItems or subScreen.showDebug then
                if subScreen.subMenu.scrollY -8>= 0 then
                    subScreen.subMenu.scrollY=subScreen.subMenu.scrollY-8
                else
                    subScreen.subMenu.scrollY=0
                end
            else
                --subScreen.cursorX = subScreen.cursorX - 1
            end
        end
        if joy[1].right_press then
            if subScreen.showClues then
                subScreen.clue=subScreen.clue+1
                --if subScreen.clue>#subScreen.clues then subScreen.clue=1 end
                if subScreen.clue> 13 then subScreen.clue=13 end
            elseif subScreen.showRelics or subScreen.showItems or subScreen.showDebug then
                subScreen.subMenu.scrollY=subScreen.subMenu.scrollY+8
            else
                --subScreen.cursorX = subScreen.cursorX + 1
            end
        end
        if joy[1].cancel_press then
            if game.map.visible then
                game.map.visible = false
            end
            if subScreen.showItems then
                subScreen.showItems = false
            end
            if subScreen.showRelics then
                subScreen.showRelics = false
            end
            if subScreen.showClues then
                subScreen.showClues = false
            end
            if subScreen.showDebug then
                if game.debugMenuTab == "main" then
                    subScreen.showDebug = false
                else
                    game.setDebugMenuTab("main")
                end
            end
        end
        if joy[1].select_press then
            subScreen.showDebug = not subScreen.showDebug
            game.setDebugMenuTab("main")
        end
        if joy[1].confirm_press then
            if subScreen.showDebug then
                local i = subScreen.subMenu.y+subScreen.subMenu.scrollY+1
                
                local menuItems = {}
                for k,v in ipairs(game.debugMenuItems) do
                    if v.tab==game.debugMenuTab then
                        menuItems[#menuItems+1]=v
                    end
                end
                
                local item = menuItems[i]
                if item and item.action then
                    item.action()
                    --subScreen.showDebug = false
                end
            else
                --if subScreen.cursorY == 1 then subScreen.relic = subScreen.cursorX end
                if subScreen.cursorY == 4 then
                    game.map.visible = not game.map.visible
                end
                if subScreen.cursorY == 0 and subScreen.cursorX == 1 then
                    objects.player.whip = objects.player.whip + 1
                    if objects.player.whip > 4 then objects.player.whip = 0 end
                    memory.writebyte(0x0434, objects.player.whip)
                    emu.pause()
                end
                if subScreen.cursorY == 3 then
                    if subScreen.showClues or (numClues() > 0) then
                        subScreen.showClues = not subScreen.showClues
                    end
                end
                if subScreen.cursorY == 2 then
                    if subScreen.showRelics then
                        subScreen.subMenu.scrollY=0
                        --subScreen.relic = subScreen.subMenu.y+subScreen.subMenu.scrollY+1
                        --setRelic(subScreen.subMenu.y+subScreen.subMenu.scrollY+1)
                        local r = cv2data.relics[subScreen.subMenu.y+subScreen.subMenu.scrollY+1].varName
                        if relics.list[r] then
                            relics.on[r] = not relics.on[r]
                            setRelicState(r, relics.on[r])
                        end
                    else
                        subScreen.showRelics = not subScreen.showRelics
                    end
                end
                if subScreen.cursorY == 1 then
                    if subScreen.showItems then
                        local i = subScreen.subMenu.y+subScreen.subMenu.scrollY+1
                        local item = itemList[i]
                        if item then
                            if item.type=="armor" then
                                setArmor(item.index)
                                --playSound(0x11)
                            end
                            if item.type=="whip" then
                                setWhip(item.index)
                                --playSound(0x11)
                            end
                            if item.type=="weapon" then
                                setWeapon(item.index)
                                --playSound(0x11)
                            end
                            if item.type=="accessory" then
                                setAccessory(item.index)
                                --playSound(0x11)
                            end
                        end
                        --emu.message(string.format("%02x",subScreen.subMenu.y-subScreen.subMenu.scrollY+1))
                        --emu.message(i)
                    end
                    subScreen.showItems = not subScreen.showItems
                end
            end
        end
--        if subScreen.cursorY == 0 and subScreen.cursorX > 1 then subScreen.cursorX = 1 end
--        if subScreen.cursorY == 1 and subScreen.cursorX > 8 then subScreen.cursorX = 8 end
--        if subScreen.cursorY == 2 and subScreen.cursorX > 10 then subScreen.cursorX = 10 end
--        if subScreen.cursorX < 1 then subScreen.cursorX = 1 end
--        if subScreen.cursorY == 3 and subScreen.cursorX > 1 then subScreen.cursorX = 1 end
--        if subScreen.cursorY == 4 and subScreen.cursorX > 1 then subScreen.cursorX = 1 end
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
    
    if action and objects.player.whipItem == items.index["Thief's Dagger"] then
        memory.writebyte(0x0434,0x0d) -- whip
        local whipDelay = memory.readbyte(0x0457)
        whipDelay = math.min(whipDelay, 0x04)
        memory.writebyte(0x0457,whipDelay)
        local whipframe = memory.readbyte(0x0445)
        for i=0, 1 do
            objects.whip[i].frame = 0
            memory.writebyte(0x0301+i, objects.whip[i].frame)
        end
        
        local facing=1
        if objects.player.facing==0 then facing=-1 end
        
        local yo=0
        if objects.player.ducking then yo=yo+3 end
        
        if whipframe==0x03 then
            gui.drawbox(objects.player.x+12*facing, objects.player.y-2+yo, objects.player.x+(12+10)*facing, objects.player.y-2+2+yo, "white", "grey")
            gui.drawbox(objects.player.x+12*facing, objects.player.y-2+yo, objects.player.x+(12+12)*facing, objects.player.y-2+2+yo, "white", "clear")
            gui.drawbox(objects.player.x+12*facing, objects.player.y-4+yo, objects.player.x+(12+2)*facing, objects.player.y-2+4+yo, "white", "clear")
        end
    end
    
    if action and joy[1].down and joy[1].A_press then
        if objects.player.accessory == items.index["Soul of Bat"] then
            if objects.player.batMode == true then
                objects.player.batMode = false
                bat = false
                -- reenable whip better
                whipframe=00
                memory.writebyte(0x0445,whipframe)
            else
                objects.player.batMode = true
                objects.player.batDelay = 0x12
                bat = true
                memory.writebyte(0x03b5,0xff) --help disable whip
            end
        end
    end
    
    if action and bat then
        memory.writebyte(0x0445,0x05) --disable whip
        
        simon_frame=memory.readbyte(0x0300)
        if spidey.counter % 20<10 then
            simon_frame=0xc8
        else
            simon_frame=0xc9
        end
        
        memory.writebyte(0x037e,0x00) --no downward gravity
        
        memory.writebyte(0x036c,0x00)

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


        if joy[1].left then
            local ys = 0
            if config.batWave then ys = spidey.makeNesFloat(math.cos((joy[1].left_press_time-1) *.3)*1.5)+.5 end
            memory.writebyte(0x037e,0)
            memory.writebyte(0x036c,ys)
        end
        if joy[1].right then
            local ys = 0
            if config.batWave then ys = spidey.makeNesFloat(math.cos((joy[1].right_press_time-1) *.3)*1.5)+.5 end
            memory.writebyte(0x037e,0)
            memory.writebyte(0x036c,ys)
        end


        if joy[1].left or joy[1].right then
            if spidey.counter % 8<4 then
                simon_frame=0xc8
            else
                simon_frame=0xc9
            end
        end

        if joy[1].up then
            memory.writebyte(0x036c,0xfe)
            if spidey.counter % 6<3 then
                simon_frame=0xc8
            else
                simon_frame=0xc9
            end
        end
        if joy[1].down then
            memory.writebyte(0x036c,0x02)
            if spidey.counter % 15==2 then
                simon_frame=0xc9
            else
                simon_frame=0xc8
            end
        end
        
        if objects.player.batDelay then
            memory.writebyte(0x006d,0)
            memory.writebyte(0x036c,0)
            if objects.player.batDelay==0x12 then memory.writebyte(0x036c,0xf5) end
            objects.player.batDelay = objects.player.batDelay - 1
            if objects.player.batDelay <=0 then objects.player.batDelay = false end
        end
        
        memory.writebyte(0x0300,simon_frame)
        
    end
    
    --destroy custom objects if going between screens
    if screenload then objects.custom.destroyall() end
    if screenload then objects.custom.createCandles() end
    if screenload then objects.custom.createLevelObjects() end
    
    if (action) then
        if objects.player.lockPosition then
--            memory.writebyte(0x0348, objects.player.lockPosition.x)
--            memory.writebyte(0x0324, objects.player.lockPosition.y)


            -- freeze x and y speed
            memory.writebyte(0x06d, 0)
            memory.writebyte(0x036c, 0)
            
--            memory.writebyte(0x0f1, 0)
            memory.writebyte(0x0f7, 0)
            
            
            -- lock vertical scrolling
            memory.writebyte(0x37e, 0)
            
            -- lock horizontal scrolling ?
            memory.writebyte(0x55, 0)
            --memory.writebyte(0x67, 0)
            
            scrollx=objects.player.lockPosition.scrollX
            scrolly=objects.player.lockPosition.scrollY
            setScroll()
            
            objects.player.frame = objects.player.lockPosition.frame
            memory.writebyte(0x0300, objects.player.frame)
            
            objects.player.frame = objects.player.lockPosition.facing
            memory.writebyte(0x0420, objects.player.facing)

            objects.player.lockPosition.c=objects.player.lockPosition.c-1
            if objects.player.lockPosition.c<=0 then
                objects.player.lockPosition = nil
            end
        end
        
        objects.player.x=memory.readbyte(0x0348)
        objects.player.y=memory.readbyte(0x0324)
        objects.player.inv=memory.readbyte(0x04f8)
        objects.player.frame = memory.readbyte(0x0300)
        objects.player.state=memory.readbyte(0x03d8)
        objects.player.ducking = (objects.player.frame==0x05 or objects.player.frame==0x2a or objects.player.frame==0x2b or objects.player.frame==0x2c)
        
        game.medusa.enabled = false
        for k,v in ipairs(cv2data.medusaHeads) do
            if area1 == v.area[1] and area2 == v.area[2] and area3 == v.area[3] and area4 == (v.area[4] or area4) then
                if objects.player.x+scrollx>=v.x1 and objects.player.x+scrollx<=v.x2 then
                    game.medusa.enabled = true
                end
                if spidey.debug.enabled then
                    gui.drawbox(v.x1-scrollx,79+10,v.x2-scrollx,91+10,"#FF00ff70", "clear")
                    gui.drawline(v.x1-scrollx,60+10,v.x1-scrollx,110+10,"#FF00ff70")
                    gui.drawline(v.x2-scrollx,60+10,v.x2-scrollx,110+10,"#FF00ff70")
                    
                    gui.text(v.x1-scrollx+4,82+10, "Medusa Heads", "#FFFFFF90", "clear")
                    gui.text(v.x2-scrollx-66,82+10, "Medusa Heads", "#FFFFFF90", "clear")
                end
            end
        end
        
        if game.medusa.enabled then
            game.medusaCounter = (game.medusaCounter or 0x20) + 1
            local medusaLimit = 2
            if game.night then medusaLimit=4 end
            if game.night and game.medusaCounter == 0x90 then
                if getCustomCount("medusahead") < medusaLimit then
                    createMedusaHead()
                end
            end
            if game.medusaCounter >=0xb0 then
                if getCustomCount("medusahead") < medusaLimit then
                    createMedusaHead()
                end
                game.medusaCounter = 0
            end
        end
        
        if config.getItems then
            for _,item in ipairs(util.split(config.getItems, ",")) do
                item = util.trim(item)
                if not items.index[item] then
                    spidey.message("Unknown item %s",item)
                elseif not hasInventoryItem(item) then
                    getItem(item, true)
                elseif (itemList[getInventoryIndex(item)].amount or 0) < (items[items.index[item]].stack or 0) then
                    itemList[getInventoryIndex(item)].amount = items[items.index[item]].stack-1
                    getItem(item, true)
                end
            end
        end
        
        if config.equip then
            for _,item in ipairs(util.split(config.equip, ",")) do
                item = util.trim(item)
                if not items.index[item] then
                    spidey.message("Unknown item %s",item)
                elseif not hasInventoryItem(item) then
                    getItem(item, true)
                    equipItem(item)
                elseif (itemList[getInventoryIndex(item)].amount or 0) < (items[items.index[item]].stack or 0) then
                    itemList[getInventoryIndex(item)].amount = items[items.index[item]].stack-1
                    getItem(item, true)
                    equipItem(item)
                else
                    equipItem(item)
                end
            end
            config.equip = false
        end
        
        -- Check if the player is in the in air hurt frame.  If so, reset 
        -- the invincible counter.  This way, you doesn't start flashing until
        -- you hit the ground.
        if objects.player.inv > 0 and objects.player.frame == 0x73 then
            objects.player.inv=0x40
            if objects.player.armor == items.index["Magic Armor"] then
                -- 50% more inv time
                objects.player.inv=objects.player.inv + 0x20
            end
            memory.writebyte(0x04f8, objects.player.inv)
        end
        
        -- Make player flash when hurt.
        if (objects.player.inv > 0 and objects.player.frame~=0x73 and objects.player.frame~=0x74) and objects.player.inv % 4 < 1 then
            --memory.writebyte(0x0300,0) --simon frame
            memory.writebyte(0x03c6,0x04) -- render player off
        else
            memory.writebyte(0x03c6,0x00) -- render player on
        end
        
        
        objects.player.facing=memory.readbyte(0x0420)
        stuff=memory.readbyte(0x004a)
        objects.player.hasgoldendagger=(stuff==bit.bor(stuff, 2^2))
        stuff=memory.readbyte(0x0092)

        for i=0,1 do
            objects.whip[i].type=memory.readbyte(0x03b5+i)
            objects.whip[i].frame=memory.readbyte(0x0301+i)
            objects.whip[i].x=memory.readbyte(0x0349+i)
            objects.whip[i].y=memory.readbyte(0x0325+i)
            objects.whip[i].ys=memory.readbyte(0x036d+i)
            objects.whip[i].xs=memory.readbyte(0x0391+i)
            objects.whip[i].hp=memory.readbyte(0x04c3+i)
            if objects.whip[i].type ~=0 then
                if spidey.debug.enabled then gui.text(objects.whip[i].x,objects.whip[i].y, string.format("%u %02X\n(%3u,%3u) %2i %2i",i,objects.whip[i].type,objects.whip[i].x,objects.whip[i].y,signed8bit(objects.whip[i].xs),signed8bit(objects.whip[i].ys)),"blue",'white') end
            end
        end
        
        
        for i=0,2 do
            objects.weapons[i].type=memory.readbyte(0x03b7+i)
            objects.weapons[i].frame=memory.readbyte(0x0303+i)
            objects.weapons[i].x=memory.readbyte(0x0348+3+i)
            objects.weapons[i].y=memory.readbyte(0x0324+3+i)
            objects.weapons[i].ys=memory.readbyte(0x036c+3+i)
            objects.weapons[i].xs=memory.readbyte(0x0396-3+i)
            objects.weapons[i].hp=memory.readbyte(0x04c8-3+i)
            if objects.weapons[i].type==0 then
                objects.weapons[i].alivetime=0
            else
                objects.weapons[i].alivetime=(objects.weapons[i].alivetime or 0)+1
            end
            --objects.weapons[i].hp=0x01
            
            if false and objects.weapons[i].type==0x01 then
                objects.weapons[i].type=0
                objects.weapons[i].frame=0
                memory.writebyte(0x03ba-3+i,objects.weapons[i].type)
                memory.writebyte(0x0303+i,objects.weapons[i].frame)
                boomerangobj=getunusedcustom()
                if (boomerangobj) then
                    --objects.custom[boomerangobj].type="fireball"
                    objects.custom[boomerangobj].type="bansheeboomerang"
                    objects.custom[boomerangobj].rebound=false
                    objects.custom[boomerangobj].x=objects.weapons[i].x+scrollx
                    objects.custom[boomerangobj].y=objects.weapons[i].y+scrolly
                    objects.custom[boomerangobj].facing=objects.player.facing
                    if objects.custom[boomerangobj].facing==1 then 
                        objects.custom[boomerangobj].xs=1.5 
                    else 
                        objects.custom[boomerangobj].xs=-1.5 
                    end
                    objects.custom[boomerangobj].ys=0
                    objects.custom[boomerangobj].active=1
                end
            end
            
            memory.writebyte(0x04c8-3+i,objects.weapons[i].hp)
            if objects.weapons[i].type ~=0 then
                --gui.text(8,8+8*i, string.format("%02X (%3u, %3u) %2u",objects[i].type,objects[i].x,objects[i].y,objects[i].hp))
                --if debug then gui.text(objects[i].x,objects[i].y, string.format("%u %02X %2u\n(%3u,%3u) %2i %2i",i,objects[i].type,objects[i].hp,objects[i].x,objects[i].y,signed8bit(objects[i].xs),signed8bit(objects[i].ys))) end
                if spidey.debug.enabled then gui.text(objects.weapons[i].x,objects.weapons[i].y, string.format("%u %02X\n(%3u,%3u) %2i %2i",i,objects.weapons[i].type,objects.weapons[i].x,objects.weapons[i].y,signed8bit(objects[i].xs),signed8bit(objects[i].ys)),"red") end
            end
            if objects.weapons[i].type==0x04 then --holy water
                objects.weapons[i].frame=0
                memory.writebyte(0x0303+i,objects.weapons[i].frame)
                -- Replace old holy water sprite with blue bottle.
                gfx.draw(objects.weapons[i].x-8, objects.weapons[i].y-9, gfx.holywater.test)
                --gfx.draw(objects.weapons[i].x-4, objects.weapons[i].y-5, gfx.holywater.new)
            elseif objects.weapons[i].type==0x05 then --diamond
                objects.weapons[i].frame=0
                memory.writebyte(0x0303+i,objects.weapons[i].frame)
                drawfont(objects.weapons[i].x, objects.weapons[i].y,font[4], ".")
                --gui.line(objects.weapons[i].x, objects.weapons[i].y, objects.weapons[i].x+1, objects.weapons[i].y+1)
                createDiamondTrail(objects.weapons[i].x, objects.weapons[i].y)
            elseif objects.weapons[i].type==0x09 then --garlic
                -- make disappear after a while
                if objects.weapons[i].alivetime>400 then
                    objects.weapons[i].type = 0
                    objects.weapons[i].frame = 0
                    memory.writebyte(0x03b7+i, objects.weapons[i].type)
                    memory.writebyte(0x0303+i, objects.weapons[i].frame)
                end
            end
        end
        
        objects.player.platformIndex = nil
        for i=0,objects.count-1 do
            objects[i] = {}
            objects[i].aliveTime = memory.readword(0x7600+i*2)
            objects[i].type=memory.readbyte(0x03ba+i)
            objects[i].name = cv2data.enemies[objects[i].type].name
            objects[i].frame=memory.readbyte(0x0306+i)
            objects[i].x=memory.readbyte(0x0348+6+i)
            objects[i].y=memory.readbyte(0x0324+6+i)
            objects[i].ys=memory.readbyte(0x036c+6+i)
            objects[i].xs=memory.readbyte(0x0396+i)
            --objects[i].show=(memory.readbyte(0x03cc+i) <0x80)
            objects[i].show=(memory.readbyte(0x03cc+i) ==0)
            objects[i].team=memory.readbyte(0x03de+i) --00=uninitialized 01=enemy 40=friendly+talks 80=friendly 08=move with player
            objects[i].anim = memory.readbyte(0x0414+i)
            objects[i].facing=memory.readbyte(0x0420+6+i)
            objects[i].carrying=memory.readbyte(0x0480+i) --platforms: 00 = not carrying simon, ff = carrying simon
            objects[i].stun=memory.readbyte(0x04fe+i)
            objects[i].palette=memory.readbyte(0x0318+i)
            objects[i].state=memory.readbyte(0x044a+i) --sometimes it's counter
            objects[i].state2=memory.readbyte(0x046e+i)
            objects[i].statecounter=memory.readbyte(0x04b6+i) --used with drac, carmilla, others?
            objects[i].xdist=math.abs(objects.player.x-objects[i].x)
            objects[i].ydist=math.abs(objects.player.y-objects[i].y)
            objects[i].facingplayer=((objects[i].x<objects.player.x and objects[i].facing==1) or (objects[i].x>objects.player.x and objects[i].facing==0))
            objects[i].hp=memory.readbyte(0x04c8+i) --note: if hp==0, it can't be hit
            objects[i].message=memory.readbyte(0x04da+i) --note: merchant messages use different values.
            
            if objects[i].carrying == 0xff then
                -- platform is carrying Simon
                objects.player.platformIndex = i
            end
            
            if objects[i].type ~=0 and objects[i].hp>0-1 and objects[i].show then
                --gui.text(8,8+8*i, string.format("%02X (%3u, %3u) %2u",objects[i].type,objects[i].x,objects[i].y,objects[i].hp))
                if spidey.debug.enabled then gui.text(objects[i].x,objects[i].y-32, string.format("%u %02X %2u\n(%3u,%3u) %2i %2i",i,objects[i].type,objects[i].hp,objects[i].x+scrollx,objects[i].y+scrolly,signed8bit(objects[i].xs),signed8bit(objects[i].ys))) end
                if spidey.debug.enabled then
                    if game.data and game.data.enemies and game.data.enemies[objects[i].type] and game.data.enemies[objects[i].type].damage then
                        local dnum=1
                        if game.night then dnum=2 end
                        gui.text(objects[i].x,objects[i].y+8*2, string.format("damage: %u",game.data.enemies[objects[i].type].damage[dnum] or 0))
                    end
                end
            end
            
            
--            objects[i].palette=0
--            memory.writebyte(0x0318+i, objects[i].palette)
            
            if objects[i].type==0x30 then
                objects[i].hp=1 --give fireballs hp so they can be killed
                memory.writebyte(0x04c8+i,objects[i].hp)
            end
            
            -- ferryman doesn't bounce off docks (needs work)
            if objects[i].type == 0x3c then
                --gui.text(50,50, string.format("state: %02X %02X %02X",objects[i].state,objects[i].state2,objects[i].statecounter))
                if objects[i].x+scrollx==270 and objects[i].facing==0 then
                    objects[i].state=0x01; memory.writebyte(0x044a+i,objects[i].state)
                    memory.writebyte(0x0396+i,0) --xs
                    memory.writebyte(0x0372+i,0) --ys
                end
                if objects[i].x+scrollx==241 and objects[i].facing==1 then
                    objects[i].state=0x01; memory.writebyte(0x044a+i,objects[i].state)
                    memory.writebyte(0x0396+i,0) --xs
                    memory.writebyte(0x0372+i,0) --ys
                end
            end
            
            
            -- custom heart object
            if false then
            --if objects[i].type==0x37 and objects[i].team~=01 and objects[i].hp~=99 then
                objects[i].type=0x00
                memory.writebyte(0x03ba+i,objects[i].type)
                objects[i].frame=0x00
                memory.writebyte(0x0306+i, objects[i].frame)
                heartobj=getunusedcustom()
                if (heartobj) then
                    objects.custom[heartobj].type="heart"
                    objects.custom[heartobj].x=objects[i].x+scrollx
                    objects.custom[heartobj].y=objects[i].y+scrolly
                    objects.custom[heartobj].facing=objects.player.facing
                    objects.custom[heartobj].xs=0
                    objects.custom[heartobj].ys=0
                    objects.custom[heartobj].active=1
                end
            end
        end

    if config.testMarker then gui.text(100,100,"test marker 1") end
--    if objects.player.platformIndex then
--        spidey.message("%02x", objects.player.platformIndex)
--    end
    
    --do extra enemy stuff
    for i=0,objects.count-1 do
        local this = objects[i]
        if objects[i].name=="Merchant" then
            if config.stationaryMerchant then
                objects[i].stun=1
                memory.writebyte(0x04fe+i, objects[i].stun)
                
                objects[i].palette=0
                memory.writebyte(0x0318+i, objects[i].palette)
                
                if objects[i].xdist < 0x30 and objects[i].ydist < 0x30 and (not objects[i].facingplayer) and spidey.counter % 20 == 0 then
                    objects[i].facing=1-objects[i].facing
                    memory.writebyte(0x0420+6+i, objects[i].facing)
                end
            end
        end

        if objects[i].show and objects[i].name == "Skeleton" then
            objects[i].statecounter=(objects[i].statecounter+1) % 256
            memory.writebyte(0x04b6+i, objects[i].statecounter)
            local nBones = 1
            local interval = 120
--            nBones=2
--            interval=100
            if objects[i].statecounter % 128==0 then
                if game.night then
                    nBones = 2
                    interval = 100
                end
                for j=1, nBones do
                    if objects[i].stun == 0 and objects[i].facingplayer then
                        createBone(objects[i].x,objects[i].y)
                    end
                end
            end
        end
        if objects[i].name == "Jumping Skeleton" then
            --gui.text(objects[i].x,objects[i].y+8*2, string.format("state: %02x %02x %02x %d %d",objects[i].state, objects[i].state2, objects[i].statecounter, objects[i].xs, objects[i].ys))
        end
        if objects[i].name == "Book" then
            for clueNum,clue in ipairs(cv2data.clues) do
                if objects[i].hp == clue and objects.player.clues[clueNum] then
                    objects[i].type=0
                    objects[i].frame=0
                    memory.writebyte(0x03ba+i,objects[i].type)
                    memory.writebyte(0x0306+i,objects[i].frame)
                end
            end
        end
        if objects[i].name == "Orb" then
            for _,v in ipairs(cv2data.mansions) do
                if locations.getAreaName(area1, area2, area3) == v.name then
                    if relics.list[v.relic] then
                        -- orbs/bags don't appear if you already have the item
                        objects[i].type=0
                        objects[i].frame=0
                        memory.writebyte(0x03ba+i,objects[i].type)
                        memory.writebyte(0x0306+i,objects[i].frame)
                    else
                        -- fix for an obscure bug
                        objects[i].hp = v.orbValue
                        memory.writebyte(0x04c8+i,objects[i].hp)
                    end
                end
            end
        end
        if objects[i].name == "Heart" then
            --spidey.message("%02x",objects[i].team)
            if objects[i].xs==1 then -- we set this to mark it as custom damager heart
            else
                -- hearts always small
--                objects[i].hp=0xef
--                objects[i].hp=1
--                memory.writebyte(0x04c8+i, objects[i].hp)
--                objects[i].frame=0x8b
--                memory.writebyte(0x0306+i, objects[i].frame)
                --objects[i].destroy = true
            end
        elseif objects[i].name == "High Jump Blob" and not inMansion then
            objects[i].hp=1
            memory.writebyte(0x04c8+i, objects[i].hp)

            objects[i].frame=0x00
            memory.writebyte(0x0306+i, objects[i].frame)
            
            local frame = math.floor(spidey.counter /7) % 2+1
            --gfx.draw(objects[i].x, objects[i].y-8, gfx.fleaman[objects[i].facing % 2][frame])
            if this.show then
                gfx.draw(objects[i].x-8, objects[i].y-9, gfx.fleaman[1-(objects[i].facing % 2)+1][frame])
            end
        elseif this.name == "Death" then
--            objects[i].y=objects[i].y+math.cos((spidey.counter+80*i) *.046)*.6
--            objects[i].x=objects[i].x+math.sin((spidey.counter+80*i) *.036)*.6
--            memory.writebyte(0x0348+6+i,objects[i].x)
--            memory.writebyte(0x0324+6+i,objects[i].y)
--            objects[i].anim = 8
--            memory.writebyte(0x0414+i, objects[i].anim)


--            if this.hp>1 then
--                objects[i].hp=1
--                memory.writebyte(0x04c8+i, objects[i].hp)
--            end
            
            objects.boss.maxHp = cv2data.enemies[this.type].hp
            
            if hasInventoryItem("Golden Knife") and not refight_bosses then
                --Only fight boss once
                this.destroy=true
            end
            
            if config.deathAI then
                if this.aliveTime <= 0x30 then
                    if this.aliveTime<0x30 then this.stun=1 end
                    memory.writebyte(0x04fe+i,this.stun)
                    this.palette=0
                    memory.writebyte(0x0318+i, this.palette)
                    
                    if this.aliveTime %2==0 then
                        this.y=this.y-1
                        memory.writebyte(0x0324+6+i,objects[i].y)
                    end
                else
                    if this.stun>0 then
                        local x,y = this.x-6,this.y-2
                        spidey.drawCircle(x+7,y+4,math.max(1,this.stun*3), "#00000060")
                    else
                        this.y=this.y+math.cos((this.aliveTime+80) *.046)*.8-.18
                        this.x=this.x+math.sin((this.aliveTime+80) *.036)*.7

                        this.y=this.y+math.cos((this.aliveTime) *.02)*1
                        this.x=this.x+math.sin((this.aliveTime) *.02)*1
                        
                        this.confine={0x20,0x48, 0xe5,0xb2}
                        memory.writebyte(0x0348+6+i,objects[i].x)
                        memory.writebyte(0x0324+6+i,objects[i].y)
                    end
                end
            end
            
            
--            this.frame=0x45
--            memory.writebyte(0x0306+i, this.frame)
            
            
            
            --spidey.drawCircle(x+7,y+4,math.max(1,this.aliveTime % 0x20*2), "#00000030")

                        
--            this.y=this.y+math.sin((this.aliveTime) *.16)*1.7
--            this.x=this.x+math.cos((this.aliveTime) *.16)*1.7
--            memory.writebyte(0x0348+6+i,objects[i].x)
--            memory.writebyte(0x0324+6+i,objects[i].y)

            
            objects.player.bossdoor()
        elseif this.name == "Death hatchet" then
            objects[i].hp=0
            memory.writebyte(0x04c8+i,objects[i].hp)

            objects.player.loop = 2
            -- faster starting at loop==2
            if this.aliveTime==1 and objects.player.loop >= 2 then
                if this.xs>=0x80 then
                    this.xs=this.xs - 1
                else
                    this.xs=this.xs + 1
                end
                if this.ys>=0x80 then
                    this.ys=this.ys - 1
                else
                    this.ys=this.ys + 1
                end
                memory.writebyte(0x0396+i,this.xs) --xs
                memory.writebyte(0x0372+i,this.ys) --ys
            end
            
        elseif objects[i].type == 0x19 then
            --objects[i].destroy=true
--            local o=objects[1]
--            local o2=objects[3]
--            objects[1].unknown = memory.readbyte(0x0414+1)
--            objects[3].unknown = memory.readbyte(0x0414+3)
--            objects[i].unknown = memory.readbyte(0x0414+i)
            --spidey.message("02x",memory.readbyte(0x0414+i))
            --memory.writebyte(0x0414+i,0x3e)
--            if i==3 then
--                objects[i].state = 0x0b
--                memory.writebyte(0x044a+i,objects[i].state)
                
--                objects[i].team=0x80
--                memory.writebyte(0x03de+i, objects[i].team) --00=uninitialized 01=enemy 40=friendly+talks 80=friendly 08=move with player
--            end
            
--            spidey.message("%02x %02x",o.unknown,o2.unknown)
            
--            if i==3 then
--            else
--                spidey.message("%02x",objects[i].frame)
--            end
            -- skeledrag segment

            --objects[i].frame=0x81
            --memory.writebyte(0x0306+i, objects[i].frame)


        elseif objects[i].name == "Werewolf" then
            -- The werewolf's senses are better at night; greater rush distance and they can turn to rush at night.
            local rushDistance = 0x32
            if game.night then rushDistance=0x5f end
            
            --gui.text(objects[i].x,objects[i].y+8*2, string.format("state: %02x %02x %02x %d %d",objects[i].state, objects[i].state2, objects[i].statecounter, objects[i].xs, objects[i].ys))
            if objects[i].state == 1 and objects[i].state2==3 then
                -- reset after a jump (state2=0)
                objects[i].state2=0
                memory.writebyte(0x046e+i, objects[i].state2)
                objects[i].statecounter=0
                memory.writebyte(0x04b6+i, objects[i].statecounter)
            end
            
            if objects[i].state == 1 and objects[i].state2==0 and objects[i].xdist < rushDistance and objects[i].ydist <0x05 and (objects[i].facingplayer or night) then
                -- rush (state2=2)
                if not objects[i].facingplayer then
                    objects[i].facing=1-objects[i].facing
                    memory.writebyte(0x0420+6+i, objects[i].facing)
                    objects[i].xs=(0x100-objects[i].xs) % 0x100
                    memory.writebyte(0x0396+i, objects[i].xs)
                    objects[i].facingplayer = true
                end
                objects[i].state2=2
                memory.writebyte(0x046e+i, objects[i].state2)
            end
            if objects[i].state2 == 2 and objects[i].statecounter == 0 then
                objects[i].statecounter=1
                memory.writebyte(0x04b6+i, objects[i].statecounter)
                if objects[i].xs==0 then
                    
                    objects[i].x=objects[i].x+6
                    memory.writebyte(0x0348+6+i,objects[i].x)
                    --memory.writebyte(0x0324+6+i,objects[i].y)
                    
                    
                    objects[i].xs=1+1
                    memory.writebyte(0x0396+i,objects[i].xs)
                end
                if objects[i].xs==255 then

                    objects[i].x=objects[i].x-6
                    memory.writebyte(0x0348+6+i,objects[i].x)

                    objects[i].xs=254-1
                    memory.writebyte(0x0396+i,objects[i].xs)
                end
            end

            if objects[i].state == 2 and objects[i].state2 == 2 and objects[i].statecounter==1 then
                objects[i].state2=3
                memory.writebyte(0x046e+i, objects[i].state2)
                objects[i].statecounter=1
                memory.writebyte(0x04b6+i, objects[i].statecounter)
                
                
                if objects[i].xs==0 then
                    objects[i].xs=1+1
                    memory.writebyte(0x0396+i,objects[i].xs)
                end
                if objects[i].xs==255 then
                    objects[i].xs=254-1
                    memory.writebyte(0x0396+i,objects[i].xs)
                end
            end
            
            if objects[i].state == 2 and objects[i].state2 == 3 then
                objects[i].statecounter=objects[i].statecounter+1
                memory.writebyte(0x04b6+i, objects[i].statecounter)
                if objects[i].statecounter==0x0a then
                    objects[i].ys = 255
                    memory.writebyte(0x036c+6+i, objects[i].ys)
                end
            end
            
--            if objects[i].state == 2 and objects[i].ys == 253 then
--                objects[i].ys = 255
--                objects[i].state = 1
--                memory.writebyte(0x036c+6+i, objects[i].ys)
--                memory.writebyte(0x044a+i,objects[i].state)
--                if objects[i].xs==0 then
--                    objects[i].xs=1
--                    memory.writebyte(0x0396+i,objects[i].xs)
--                end
--                if objects[i].xs==255 then
--                    objects[i].xs=254
--                    memory.writebyte(0x0396+i,objects[i].xs)
--                end
--            end
        end
        
        if objects[i].type==0x03 and objects[i].stun==0 and objects[i].xdist < 40 and objects[i].xdist > 16 and objects[i].ydist<10 and objects[i].facingplayer==false and (emu.framecount() % 48) then
            --skeletons turn to face player sometimes
            objects[i].facing=1-objects[i].facing; memory.writebyte(0x0420+6+i,objects[i].facing)
            objects[i].xs=255-objects[i].xs; memory.writebyte(0x0396+i,objects[i].xs)
            --gui.text(objects[i].x,objects[i].y-8, "*")
        end
        
        if objects[i].type==0x30 then -- Fireballs
            if signed8bit(objects[i].xs) >= 0 then
                if objects[i].facing==0 then objects[i].facing=1; memory.writebyte(0x0420+6+i, objects[i].facing) end
            else
                if objects[i].facing==1 then objects[i].facing=0; memory.writebyte(0x0420+6+i, objects[i].facing) end
            end
            
            
            -- fireballs get faster each game loop
            if this.aliveTime==1 then
                if this.facing==1 then
                    this.xs=this.xs + math.min(7, objects.player.loop)
                else
                    this.xs=this.xs - math.min(7, objects.player.loop)
                end
            end
            
            memory.writebyte(0x0396+i,this.xs) --xs
            memory.writebyte(0x0372+i,this.ys) --ys

        end
        if objects[i].type==0x32 then --Fire guy fireballs: 
            -- Fix it so they face the proper direction
            if objects[i].xs ==bit.bor(objects[i].xs, 2^7) then
                if objects[i].facing==1 then objects[i].facing=0; memory.writebyte(0x0420+6+i, objects[i].facing) end
            else
                if objects[i].facing==0 then objects[i].facing=1; memory.writebyte(0x0420+6+i, objects[i].facing) end
            end
            objects[i].hp=1 --give fireballs hp so they can be killed
            memory.writebyte(0x04c8+i,objects[i].hp)
        end
        
        if config.floatingEyes and objects[i].name=="Eyeball" then --floating eyes
                -- They first start by slowly heading towards you (state=0).
                -- Then, they kite (state=1).
                -- If you turn away, they strike periodically (state=2).
                
                --objects[i].skullc = ((objects[i].skullc or 0) +1) % 1000
                
                if objects[i].state <2 then
                    objects[i].state2=(objects[i].state2+1) % 0x100
                    memory.writebyte(0x046e+i, objects[i].state2)
                end
                
                if objects[i].state==0 then
                    if objects[i].xdist < 0x40 and objects[i].ydist < 0x40 then
                        --spidey.message("circle")
                        objects[i].state = 1
                        memory.writebyte(0x044a+i, objects[i].state)
                        --memory.writebyte(0x046e+i, objects[i].state2)
                    else
                    end
                elseif objects[i].state==1 then
                    if objects[i].xdist < 0x60 and objects[i].ydist < 0x60 then
                        --objects[i].skullc = ((spidey.counter or 0) +1) % 1000
                        objects[i].skullc = objects[i].state2
                        objects[i].y=objects[i].y+math.cos(objects[i].skullc *.08)*2
                        
                        if objects[i].facing==0 then
                            objects[i].x=objects[i].x+math.sin(objects[i].skullc *.01)*2
                        else
                            objects[i].x=objects[i].x+math.sin(objects[i].skullc *.01)*-2
                        end
                        memory.writebyte(0x0348+6+i,objects[i].x)
                        memory.writebyte(0x0324+6+i,objects[i].y)
                        
                        -- if player back turned
                        if (objects[i].x<objects.player.x and objects.player.facing==1) or (objects[i].x>objects.player.x and objects.player.facing==0) then
                            if objects[i].state2 % 28 ==0x10 then
                                objects[i].state = 2
                                memory.writebyte(0x044a+i, objects[i].state)
                                objects[i].state2=0x2d
                                memory.writebyte(0x046e+i, objects[i].state2)
                            end
                        end
                    end
                elseif objects[i].state==2 then
                    objects[i].state2=objects[i].state2-1
                    memory.writebyte(0x046e+i, objects[i].state2)

                    --spidey.message("attack")
                    if objects[i].xdist>0x0e then
                        if objects[i].facing==1 then
                            objects[i].x=objects[i].x+2
                        else
                            objects[i].x=objects[i].x-2
                        end
                    end
                    
                        -- if player facing the eye
                        if (objects[i].x<objects.player.x and objects.player.facing==0) or (objects[i].x>objects.player.x and objects.player.facing==1) then
                            objects[i].state = 1
                            memory.writebyte(0x044a+i, objects[i].state)

                        end
                    
                    --objects[i].y=objects[i].y+math.cos(objects[i].state2 *.04)*2
                    memory.writebyte(0x0348+6+i,objects[i].x)
                    memory.writebyte(0x0324+6+i,objects[i].y)
                    if objects[i].state2==0 then
                        objects[i].state = 1
                        memory.writebyte(0x044a+i, objects[i].state)
                    end
                    
                end
        end
        
        if objects[i].name == "MedusaX" then
            --objects[i].
            
            if objects[i].state==0 then
                objects[i].state=objects[i].x
                objects[i].state2=objects[i].y
                memory.writebyte(0x044a+i, objects[i].state)
                memory.writebyte(0x046e+i, objects[i].state2)
            end
            
            local x = objects[i].state
            local y = objects[i].state2
            
            objects[i].statecounter = ((objects[i].statecounter or 0) +1) % 0x100
            memory.writebyte(0x04b6+i, objects[i].statecounter)
--            y=y+math.cos(objects[i].statecounter *.04)*2
--            x=x-math.sin(objects[i].statecounter *.01)*2
            y=y+math.cos(objects[i].statecounter *.04)*1
            x=x-math.sin(objects[i].statecounter *.01)*1

            memory.writebyte(0x0348+6+i,x)
            memory.writebyte(0x0324+6+i,y)
            
            memory.writebyte(0x044a+i,x)
            memory.writebyte(0x046e+i,y)


--            if objects[i].state+objects[i].state2+objects[i].statecounter > 0 then
--                emu.pause()
                
--            end
            emu.message(string.format("%02x %02x %02x",objects[i].state, objects[i].state2, objects[i].statecounter or 0))
        end
        
        if objects[i].type==0x0a and false then --medusa heads
                --needs work but at least they're wavy
--                emu.message(string.format("%02x",objects[i].statecounter))
--                emu.pause()
                objects[i].skullc = ((objects[i].skullc or 0) +1) % 10000
                objects[i].y=objects[i].y+math.sin(objects[i].skullc *.06)*2
                memory.writebyte(0x0324+6+i,objects[i].y)
                
--                objects[i].x = objects[i].lastX or objects[i].x
--                memory.writebyte(0x034e+i, objects[i].x)
                

--                objects[i].x = objects[i].x + 1
                
                
--                objects[i].xs=2
--                memory.writebyte(0x0396+i, objects[i].xs)
                
--                objects[i].xs=2
--                objects[i].xs=objects[i].lastXs or objects[i].xs
--                memory.writebyte(0x0396+i, objects[i].xs)
--                objects[i].lastXs = objects[i].xs
                
--                objects[i].xs=memory.readbyte(0x0396+i)
--                objects[i].team=memory.readbyte(0x03de+i) --00=uninitialized 01=enemy 40=friendly+talks 80=friendly 08=move with player
                
                objects[i].facing=objects[i].lastFacing or objects[i].facing
                memory.writebyte(0x0420+6+i, objects[i].facing)
                
                objects[i].lastFacing=objects[i].facing
                objects[i].lastX = objects[i].x
                
                
        end
        
        if objects[i].type==0x10 then --skulls
                objects[i].skullc = spidey.counter
                objects[i].skullc = ((objects[i].skullc or 0) +1) % 1000
                --objects[i].y=objects[i].y+math.sin(objects[i].skullc *.1)*2
                objects[i].y=objects[i].y+math.sin(objects[i].skullc *.1)*2
                memory.writebyte(0x0324+6+i,objects[i].y)
        end
        
        if objects[i].type==0x38 then --hands
            --gui.text(8,8*2, string.format("%02x %02X %02X",i,objects[i].state,objects[i].state2,objects[i].statecounter))
            if objects[i].xdist>64 then objects[i].frame=0 end
            --[[
            if objects[i].xdist>64 then 
                objects[i].frame=0x8e
                --objects[i].y=180
                --objects[i].state=1
                --objects[i].state2=0
            end
            ]]--
            --memory.writebyte(0x0324+6+i,objects[i].y)
            memory.writebyte(0x044a+i,objects[i].state)
            memory.writebyte(0x046e+i,objects[i].state2)
            memory.writebyte(0x0306+i,objects[i].frame)
        end
        
        if config.ghosts and objects[i].type==0x39 then --ghosts
            objects[i].skullc = ((objects[i].skullc or 0) +1) % 1000
            objects[i].y=objects[i].y+math.cos(objects[i].skullc *.05)*1
            objects[i].frame=0x20 + (math.floor(objects[i].skullc / 6) % 2)
            if (emu.framecount() % 4==0) then objects[i].frame=0 end
            memory.writebyte(0x0324+6+i,objects[i].y)
            memory.writebyte(0x0306+i,objects[i].frame)
        end
        
        if objects[i].type==0x48 then
            if objects[i].frame >=0x7a and objects[i].frame<=0x7d then
            else
                objects[i].destroy=true
                spidey.message("%02x",objects[i].frame)
            end
            --if frame~=0x29 then
            --memory.writebyte(0x0306+i,objects[i].frame)
        end
        if objects[i].type==0x48 and false then --drac weapon
            objects[i].frame=0x29
            objects[i].type=0x30
            --29 fireball
            --ad knife
            --a8 holy fire
            --d3-d6 big flame (drac spawn)
            --e9-ec big flame (drac death)
            memory.writebyte(0x03ba+i,objects[i].type)
            memory.writebyte(0x0306+i,objects[i].frame)
        end
        
        if objects[i].type==0x49 then -- magic cross item
            if hasInventoryItem("Cross") and displayarea=="Laruba" then objects[i].destroy = true end
            if hasInventoryItem("Golden Knife") and displayarea=="Brahm" then objects[i].destroy = true end
        end
        
        if objects[i].type==0x42 then --Carmilla (mask boss)
            objects.boss.maxHp=240
            if hasInventoryItem("Cross") and not refight_bosses then
                --Only fight boss once
                objects[i].destroy = true
            end
            
            --gui.text(8,8*2, string.format("%02x %02X %02X",i,objects[i].state,objects[i].state2,objects[i].statecounter))
            
            objects[i].skullc = ((objects[i].skullc or 0) +1) % 1000
            --objects[i].y=objects[i].y+math.cos(objects[i].skullc *.03)*2
            objects[i].x=objects[i].x+math.sin(objects[i].skullc *.01)*1
            --objects[i].y=objects[i].y+math.cos(emu.framecount()*.04)*1
            objects[i].x=objects[i].x+math.sin(emu.framecount()*.04)*2
            n=40
            if objects[i].x<0+n then objects[i].x=0+n end
            if objects[i].x>255-n then objects[i].x=255-n end
            if objects[i].y<0+n then objects[i].y=0+n end
            if objects[i].y>255-n then objects[i].y=255-n end
            
            memory.writebyte(0x0348+6+i,objects[i].x)
            memory.writebyte(0x0324+6+i,objects[i].y)
            
            objects.player.bossdoor()

            memory.writebyte(0x03ba+i,objects[i].type)
            memory.writebyte(0x04fe+i,objects[i].stun)
            memory.writebyte(0x0348+6+i,objects[i].x)
            memory.writebyte(0x0324+6+i,objects[i].y)
            memory.writebyte(0x044a+i,objects[i].state)
            memory.writebyte(0x046e+i,objects[i].state2)
            memory.writebyte(0x04b6+i,objects[i].statecounter)
            memory.writebyte(0x0306+i,objects[i].frame)
            memory.writebyte(0x03de+i,objects[i].team)
        end
        
        if objects[i].type==0x47 then -- Dracula
            objects.player.inBossRoom=true
            objects.boss.maxHp=cv2data.enemies[this.type].hp
        end
        if objects[i].type==0x47 and config.draculaAI then -- Dracula
            objects.dracula = objects.dracula or {}
            
            objects.player.inBossRoom=true
            objects.boss.maxHp=240
            --gui.text(objects[i].x,objects[i].y, string.format("%u %02X %2u\n(%3u,%3u) %2i %2i",i,objects[i].type,objects[i].hp,objects[i].x,objects[i].y,signed8bit(objects[i].xs),signed8bit(objects[i].ys)))
            
            objects.dracula.move = objects.dracula.move or ""
            objects.dracula.movec = objects.dracula.movec or 0
            
            if emu.framecount() % 4==0 then objects.dracula.movec=objects.dracula.movec+1 end
            --if spidey.counter % 4==0 then objects[i].movec=objects[i].movec+1 end
            --if spidey.counter % 40==0 then objects[i].movec=objects[i].movec+1 end
            
            
            --objects.dracula.movename=''
            --objects[i].movename=objects[i].movename or ""
            --objects[i].state2=0xff
            objects[i].draccount=memory.readbyte(0x04b6)
            --objects[i].draccount=(objects[i].draccount or 1)
            --objects[i].draccount=1
            --if objects[i].frame==0x34 and not joy[2].B and not joy[2].idle then objects[i].frame=0x33 end
            dracsp=2
--            if joy[2].left then objects[i].x=objects[i].x-dracsp end
--            if joy[2].right then objects[i].x=objects[i].x+dracsp end
--            if joy[2].up then objects[i].y=objects[i].y-dracsp end
--            if joy[2].down then objects[i].y=objects[i].y+dracsp end
--            if joy[2].B_press and objects[i].move=='' then
--                objects[i].move='shoot'
--                objects[i].movec=0
--            end
            
            --[[
            if joy[2].A then
                n=joy[2].A_press_time
                --objects[i].x=math.random(0,256)
                objects[i].y=objects[i].y+math.sin(n *.05)*3
                --objects[i].x=objects[i].x+math.cos(emu.framecount() *.15)
                objects[i].movename='hover'
            end
            ]]--
--            if joy[2].select then
--                objects[i].stun=0x08
--                objects[i].x=40+87*math.random(0,2)
--                objects[i].movename='warp'
--            end
            
            if objects.dracula.move=='' and not objects.dracula.moveindex==false then
                objects.dracula.moveindex=(objects.dracula.moveindex+1) % #objects.dracula.movequeue
                objects.dracula.move=objects.dracula.movequeue[objects.dracula.moveindex]
                objects.dracula.movec=0
                if objects.dracula.move=='sway' then
                    objects[i].x=128
                    objects[i].y=64
                    objects.dracula.swaycount=0
                end
            end
            
--            if joy[2].A_press and objects[i].move=='' then
--                objects[i].x=128
--                objects[i].y=64
--                objects[i].move='sway'
--                objects[i].movec=0
--                swaycount=0
--            end

--            if joy[2].start_press and objects[i].move=='' then
--                objects[i].movequeue={'warp2','warp2','warp2','warp2','warp2','warp2','warp2','warp2','warp2','warp2'}
--                objects[i].moveindex=1
--            end
            
            if objects[i].draccount==1 and objects.dracula.move=='' then
                --objects[i].movequeue={'warp2','warp2','warp2','warp2','warp'}
                objects.dracula.movequeue={'warp','warp','shoot','warp','warp','shoot','warp','shoot','warp','shoot','warp','warp','shoot','shoot','shoot','shoot','warp2','warp2','warp2','sway','warp2','warp2','warp2'}
                objects.dracula.moveindex=1
            end
            
            if objects.dracula.move=='shoot' then
                if objects.dracula.movec==1 then
                    --pass
                elseif objects.dracula.movec==2 then
                    objects[i].frame=0x34
                elseif objects.dracula.movec==4 then
                    objects[i].state2=0x11
                    objects.dracula.movec=objects.dracula.movec+1
                elseif objects.dracula.movec==7 then
                    --objects[i].frame=0x33
                elseif objects.dracula.movec==8 then
                    objects.dracula.move=''
                end
            end
            
            if objects.dracula.move=='warp' then
                objects[i].frame=0x33
                objects[i].stun=0x08
                objects[i].x=40+87*math.random(0,2)
                objects[i].y=64
                if objects.dracula.movec==1 then
                    --pass
                elseif objects.dracula.movec==20 then
                    objects.dracula.move=''
                end
            end
            
            if objects[i].move=='sway' and emu.framecount() % 9==0 then
            --if objects.dracula.move=='sway' and spidey.counter % 9==0 then
                onum=getunusedcustom()
                if (onum) then
                    objects.custom[onum].type="fireball"
                    objects.custom[onum].x=objects[i].x+scrollx
                    objects.custom[onum].y=objects[i].y+scrolly
                    objects.custom[onum].xs=math.random(-5,5)*.4
                    objects.custom[onum].ys=math.random(-5,5)*.2-2
                    objects.custom[onum].active=1
                end
            end
            
            if objects.dracula.move=='sway' then
                objects[i].stun=0x10
                objects[i].team=0x80
                n=objects.dracula.swaycount
                objects[i].y=objects[i].y+math.sin(n*.1)*1
                objects[i].x=objects[i].x+math.cos(n*.2)*16
                if objects.dracula.movec==1 then
                    --pass
                elseif objects.dracula.movec==200 then
                    objects[i].stun=0
                    objects[i].team=1
                    objects.dracula.move=''
                end
                objects.dracula.swaycount=objects.dracula.swaycount+1
            end
            
            if objects.dracula.move=='warp2' then
                if objects.dracula.movec==1 then
                    objects[i].team=0x80
                    objects[i].frame=0xe9
                    objects[i].stun=0xff
                elseif objects.dracula.movec==2 then
                    objects[i].frame=0xea
                elseif objects.dracula.movec==4 then
                    objects[i].frame=0xeb
                elseif objects.dracula.movec==5 then
                    objects[i].frame=0xec
                elseif objects.dracula.movec==6 then
                    objects[i].frame=0
                    objects[i].y=170
                elseif objects.dracula.movec==7 then
                    --objects[i].x=40+87*math.random(0,2)
                    objects[i].x=40+22*math.random(0,8)
                elseif objects.dracula.movec==30 then
                    objects[i].frame=0xec
                elseif objects.dracula.movec==31 then
                    objects[i].frame=0xeb
                    objects[i].stun=0xff
                elseif objects.dracula.movec==32 then
                    objects[i].frame=0xea
                elseif objects.dracula.movec==33 then
                    objects[i].frame=0xe9
                elseif objects.dracula.movec==34 then
                    objects[i].frame=0x33
                elseif objects.dracula.movec==43 then
                    objects[i].stun=0x00
                    objects[i].team=1
                elseif objects.dracula.movec==53 then
                    onum=getunusedcustom()
                    spx=-2.4
                    if objects.player.x < objects[i].x+scrollx then spx=-spx; facing=0 else facing=1 end
                    if (onum) then
                        objects.custom[onum].type="dracfire"
                        objects.custom[onum].x=objects[i].x+scrollx
                        objects.custom[onum].y=objects[i].y+scrolly-8-4
                        objects.custom[onum].xs=spx
                        objects.custom[onum].ys=-.39
                        objects.custom[onum].facing=facing
                        objects.custom[onum].active=1
                    end
                    onum=getunusedcustom()
                    if (onum) then
                        objects.custom[onum].type="dracfire"
                        objects.custom[onum].x=objects[i].x+scrollx
                        objects.custom[onum].y=objects[i].y+scrolly-8
                        objects.custom[onum].xs=spx
                        objects.custom[onum].ys=0
                        objects.custom[onum].facing=facing
                        objects.custom[onum].active=1
                    end
                    onum=getunusedcustom()
                    if (onum) then
                        objects.custom[onum].type="dracfire"
                        objects.custom[onum].x=objects[i].x+scrollx
                        objects.custom[onum].y=objects[i].y+scrolly-8+4
                        objects.custom[onum].xs=spx
                        objects.custom[onum].ys=.39
                        objects.custom[onum].facing=facing
                        objects.custom[onum].active=1
                    end
                    objects.dracula.movec=objects.dracula.movec+1
                elseif objects.dracula.movec==63 then
                    objects[i].stun=0
                    objects[i].team=1
                    objects.dracula.move=''
                end
            end
            
            memory.writebyte(0x04fe+i,objects[i].stun)
            memory.writebyte(0x0348+6+i,objects[i].x)
            memory.writebyte(0x0324+6+i,objects[i].y)
            memory.writebyte(0x046e+i,objects[i].state2)
            memory.writebyte(0x0306+i,objects[i].frame)
            memory.writebyte(0x03de+i,objects[i].team)
            --[[
            if objects[i].stun>1 then
                objects[i].stun=0
                objects[i].y=objects[i].y-4
                objects[i].x=128+math.random(-32,32)
                memory.writebyte(0x04fe+i,objects[i].stun)
                memory.writebyte(0x0348+6+i,objects[i].x)
                memory.writebyte(0x0324+6+i,objects[i].y)
            end
            ]]--
            --if objects[i].movename~='' then emu.message(objects[i].movename) end
            
            if spidey.debug then
                drawfont(0,50,font[current_font], string.format("move=%s movec=%02x draccount=%02x",objects.dracula.move or "", objects.dracula.movec or 0, objects[i].draccount or 0))
                drawfont(0,50+8,font[current_font], string.format("moveindex=%02x",objects.dracula.moveindex or 0))
            end
        end
        
        objects[i].aliveTime = (objects[i].aliveTime+1) % 0x10000
        memory.writeword(0x7600+i*2, objects[i].aliveTime)
        
        if this.confine then
            this.x = math.min(math.max(this.x,this.confine[1]), this.confine[3])
            this.y = math.min(math.max(this.y,this.confine[2]), this.confine[4])
            memory.writebyte(0x0348+6+i,objects[i].x)
            memory.writebyte(0x0324+6+i,objects[i].y)
        end
        
        if objects[i].destroy then
            objects[i].type=0
            objects[i].frame=0
            objects[i].hp = 0
            memory.writebyte(0x03ba+i,objects[i].type)
            memory.writebyte(0x0306+i,objects[i].frame)
            memory.writebyte(0x04c8+i, objects[i].hp)
        end
        if config.testMarker then gui.text(100,100+8*2,"test marker 3") end
    end
    
    if config.testMarker then gui.text(100,100+8,"test marker 2") end
    
    
    if inp.leftbutton_press then
        local i=getunusedcustom()
        i=false --DISABLE
        if (i) then
            --objects.custom[i].type="fireball"
            objects.custom[i].type="bansheeboomerang"
            objects.custom[i].rebound=false
            objects.custom[i].x=inp.xmouse+scrollx
            objects.custom[i].y=inp.ymouse+scrolly
            --objects.custom[i].xs=math.random(-5,5)*.1
            objects.custom[i].xs=1
            --objects.custom[i].ys=math.random(-5,5)*.1-2
            objects.custom[i].ys=0
            objects.custom[i].active=1
        end
    end
    
    
    if config.leftClick =="fallingBlocks" and inp.leftbutton_press then
        local x,y
        y=0x2d
        local blocks={}
        for i=1,8 do
            x=math.random(0,15)*16
            y=0x32-math.random(0,10)
            if not blocks[x] then
                local obj = createObject("fallingblock",x+scrollx, y+scrolly)
                obj.delaySpawn = i*10
                blocks[x] = true
            end
        end
        queueSound(0x6) --rumble
        --local obj = createObject("fallingblock",inp.xmouse+scrollx, inp.ymouse+scrolly)
    end
    
    if cheats.active and (cheats.battest or cheats.leftClick == "battest") and inp.leftbutton_press then
        local i=getunusedcustom()
        if (i) then
            objects.custom[i].type="bigbat"
            objects.custom[i].x=inp.xmouse+scrollx
            objects.custom[i].y=inp.ymouse+scrolly
            objects.custom[i].xs=0
            objects.custom[i].ys=0
            objects.custom[i].active=1
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
            drawfont(0,5+8*7,spidey.debug.font, string.format("%02x %02x %02x",levelEdit.cursor.x,levelEdit.cursor.y, levelEdit.block))
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
    
    --if inp.leftbutton_press then game.applyNight=true end
    
    --cheats.leftClick="itemPopUp"
    if inp.leftbutton_press and config.leftClick=="itemPopUp" then
        createItemPopUp()
    end
    
    if inp.leftbutton_press and config.leftClick=="levelup" then
    --if inp.leftbutton_press then
        createLevelUpText()
        playSound(0x27)
    end
    
    
--    if inp.leftbutton_press then
--        relics.list.blueCrystal=true
--        setRelicState("blueCrystal", true)
--    end
    
    if cheats.active and inp.leftbutton_press and cheats.leftClick=="item" then
        local i=getunusedcustom()

        local c = {}
        c.type="item"
        --c.name = "Gold Ring"
        --c.name = "Axe"
        c.name = "Grab Bag"
        c.area={area1,area2,area3,returnArea}
        c.x=math.floor((inp.xmouse+scrollx)/16)*16+8
        c.y=math.floor((inp.ymouse+scrolly)/16)*16-3
        c.outscreen=true
        c.active=1
        levelObjects[#levelObjects+1] = c
        
        if i then
            objects.custom[i].type=c.type
            objects.custom[i].area={area1,area2,area3,returnArea}
            objects.custom[i].x=math.floor((inp.xmouse+scrollx)/16)*16+8
            objects.custom[i].y=math.floor((inp.ymouse+scrolly)/16)*16-3
            objects.custom[i].outscreen=true
            objects.custom[i].active=1
            objects.custom[i].itemName = c.name
        end
        emu.message(string.format("Placed item %02x %02x area=%02x %02x %02x %02x", objects.custom[i].x, objects.custom[i].y, objects.custom[i].area[1],objects.custom[i].area[2],objects.custom[i].area[3],objects.custom[i].area[4]))
    end
    
    
    --if inp.leftbutton_press and cheats.leftClick=="candle" then
    
    if config.editCandles then
        if inp.middlebutton_press then
            local x=math.floor((inp.xmouse)/16)*16
            local y=math.floor((inp.ymouse)/16)*16
            local areaX = math.floor((inp.xmouse+scrollx)/16)*16
            local areaY = math.floor((inp.ymouse+scrolly)/16)*16
            
            local candleIndex = false
            for i,candle in ipairs(candles) do
                if candle.area[1]==area1 and candle.area[2]==area2 and candle.area[3]==area3 and candle.area[4]==areaFlags and candle.x == areaX and candle.y==areaY then
                    candleIndex = i
                end
            end
            
            if candleIndex then
                table.remove(candles, candleIndex)
                spidey.message("Candle removed %02x %02x",x,y)
                
                for i,obj in ipairs(objects.custom) do
                    if obj.type=="candle" and obj.active==1 and objects.custom.isOnScreen(i) and obj.x==areaX and obj.y==areaY then
                        obj.destroy = true
                    end
                end
            end
            saveCandles()
        end
    end
    
    
    if inp.leftclick then
        --memory.writebyte(0x0169, 0x0f)
        
        -- force whip
        --memory.writebyte(0x03ea, 0x80)
        --memory.writebyte(0x03b5, 0xff)
    end
    
    if config.editCandles and inp.doubleclick then
        if bat then
            spidey.message("Error: Cannot place candle in bat mode.",x,y)
        else
            local i=getunusedcustom()
            local x=math.floor((inp.xmouse)/16)*16
            local y=math.floor((inp.ymouse)/16)*16
            
            local areaX = math.floor((inp.xmouse+scrollx)/16)*16
            local areaY = math.floor((inp.ymouse+scrolly)/16)*16
            
            local candleIndex = false
            for i,candle in ipairs(candles) do
                if candle.area[1]==area1 and candle.area[2]==area2 and candle.area[3]==area3 and candle.area[4]==areaFlags and candle.x == areaX and candle.y==areaY then
                    candleIndex = i
                end
            end
            
            if candleIndex then
                table.remove(candles, candleIndex)
                spidey.message("Candle replaced %02x %02x",x,y)
                
                for i,obj in ipairs(objects.custom) do
                    if obj.type=="candle" and obj.active==1 and objects.custom.isOnScreen(i) and obj.x==areaX and obj.y==areaY then
                        obj.destroy = true
                    end
                end
            end
            
            --spidey.message("%02x %02x",x,y)
            

            local c = {}
            c.type="candle"
            c.area={area1,area2,area3,areaFlags}
            c.x=math.floor((inp.xmouse+scrollx)/16)*16
            c.y=math.floor((inp.ymouse+scrolly)/16)*16
            c.outscreen=true
            c.active=1
            c.floor = objects.player.y+scrolly+12
            c.location = displayarea
            c.item = config.candleItem
            
            candles[#candles+1] = c
            
            if i then
                objects.custom[i].type="candle"
                objects.custom[i].area={area1,area2,area3,areaFlags}
                objects.custom[i].x=math.floor((inp.xmouse+scrollx)/16)*16
                objects.custom[i].y=math.floor((inp.ymouse+scrolly)/16)*16
                objects.custom[i].outscreen=true
                objects.custom[i].active=1
                --objects.custom[i].floor = objects.player.y+12
                objects.custom[i].floor = c.floor
                objects.custom[i].item = c.item
            end
            --local txt = '    {x=0x%02x, y=0x%02x, area = {0x%02x,0x%02x,0x%02x,0x%02x}, floor=0x%02x, location="%s", },\n'
            
            --spidey.appendToFile("cv2/candles.txt", string.format(txt, c.x,c.y,c.area[1],c.area[2],c.area[3],c.area[4],objects.player.y,displayarea))
            saveCandles()
        end
    end
    
    
    --if cheats.active and not cheats.battest and inp.leftbutton_press then
    --if cheats.bonetest and inp.leftbutton_press then
    if cheats.active and inp.leftbutton_press and cheats.leftClick =="bone" then
    --if cheats.active and cheats.bonetest and inp.leftbutton_press then
        local i=getunusedcustom()
        if (i) then
            objects.custom[i].type="bone"
            objects.custom[i].x=inp.xmouse+scrollx
            objects.custom[i].y=inp.ymouse+scrolly
            objects.custom[i].xs=math.random(-5,5)*.2
            --objects.custom[i].xs=1
            objects.custom[i].ys=math.random(-5,5)*.1-2.8
            --objects.custom[i].ys=0
            --objects.custom[i].xs=0
            --objects.custom[i].ys=0
            objects.custom[i].active=1
        end
    end
    
    for i=0,objects.custom.count-1 do
        local this = objects.custom[i]
        if objects.custom[i].active==0 then
            --objects.custom[i].aliveTime=0
        end
        if objects.custom[i].active==1 and objects.custom.isOnScreen(i) then
            objects.custom[i].xdist=math.abs(objects.player.x-objects.custom[i].x+scrollx)
            objects.custom[i].ydist=math.abs(objects.player.y-objects.custom[i].y+scrolly)
            objects.custom[i].aliveTime=math.min((objects.custom[i].aliveTime or 0)+1,100000)
            objects.custom[i].alivetime = objects.custom[i].aliveTime
            --gui.drawrect(objects.custom[i].x-2-scrollx, objects.custom[i].y-2-scrolly, objects.custom[i].x+2-scrollx, objects.custom[i].y+2-scrolly, "yellow","red")
            --gfx.draw(objects.custom[i].x-2-scrollx, objects.custom[i].y-2-scrolly, cv2fire)
            
            objects.custom[i].x=objects.custom[i].x+objects.custom[i].xs
            objects.custom[i].y=objects.custom[i].y+objects.custom[i].ys
            
            if objects.custom[i].type=="fireball" then
                gfx.draw(objects.custom[i].x-2-scrollx, objects.custom[i].y-2-scrolly, cv2fire)
                objects.custom[i].ys=objects.custom[i].ys+.1
                if objects.custom[i].xdist<10 and objects.custom[i].ydist<10 then
                    objects.custom[i].destroy = true
                    hurtplayer()
                end
            elseif objects.custom[i].type=="marker" then
                gui.text(objects.custom[i].x-scrollx, objects.custom[i].y-scrolly, objects.custom[i].eName or "X","white","clear")
            elseif objects.custom[i].type=="item" then
                if objects.custom[i].alivetime == 1 and hasInventoryItem(objects.custom[i].itemName) then 
                    if (items[items.index[objects.custom[i].itemName]].stack or 0)>0 then
                    else
                        objects.custom[i].active = 0
                    end
                end
                
                local item
                if items.index[objects.custom[i].itemName] then
                    item = items[items.index[objects.custom[i].itemName]]
                    if item.type=="gold" then 
                        objects.custom[i].gfx=gfx.moneybag
                    end
                end
                
                
                if objects.custom[i].alivetime == 1 then
                    objects.custom[i].ys = .2
                    objects.custom[i].falling = true
                end
                
                if objects.custom[i].falling then
                    objects.custom[i].ys = math.min(2.2, objects.custom[i].ys * 1.4)
                end
                
                if objects.custom[i].floor then
                    if objects.custom[i].y>objects.custom[i].floor then
                        objects.custom[i].y=objects.custom[i].floor
                        objects.custom[i].ys = 0
                        objects.custom[i].falling=false
                    end
                else
                    objects.custom[i].ys = 0
                    objects.custom[i].falling=false
                end
                
                local x,y=objects.custom[i].x-scrollx, objects.custom[i].y-scrolly
                --gfx.draw(objects.custom[i].x-scrollx-4, objects.custom[i].y-scrolly+8, objects.custom[i].gfx or gfx.items.bag)
                
                local xo,yo = -2,-6
                if item.type=="gold" then 
                    objects.custom[i].gfx = gfx.moneybag
                    xo=-2
                    yo=-10
                end
                
                gfx.draw(objects.custom[i].x-scrollx+xo, objects.custom[i].y-scrolly+yo, objects.custom[i].gfx or gfx.items.bag)
                
                if objects.custom[i].xdist <= 12 and objects.custom[i].ydist <= 12 then
                    objects.custom[i].destroy = 1
                    --playSound(0x10)
                    getItem(objects.custom[i].itemName, true)
                    --spidey.message("getitem")
                    
--                        for i=0,255 do
--                            local itemIndex
--                            local itemAmount
--                            if itemList[i+1] and itemList[i+1].name then
--                                itemIndex = items.index[itemList[i+1].name]
--                                itemAmount = itemList[i+1].amount or 1
--                            else
--                                itemIndex = 0
--                                itemAmount = 0
--                            end
--                            memory.writebyte(0x7100+i*2, itemIndex)
--                            memory.writebyte(0x7100+i*2+1, itemAmount)
--                        end
                end
            elseif this.type == "fallingblock" then
                if this.aliveTime - this.delaySpawn == 1 then
                    this.ys = .05
                end
                this.ys=math.min(5,this.ys*1.12)
                gfx.draw(this.x-scrollx-8, this.y-scrolly-8, gfx.block)
                
                if this.xdist<12 and this.ydist<10 then
                    this.hurtTimer=15
                    hurtplayer(0x0a)
                end

                
                local x=objects.custom[i].x-scrollx
                local y=objects.custom[i].y-scrolly
                local rect = {x-5,y-4-8,x+9,y+7-4}
                objects.custom[i].hitbox = rect
                
                if this.y-scrolly>0xc6 then
                    this.y=0xc6+scrolly
                    this.ys=0
                    this.destroy=true
                    local obj = createObject("poof",this.x-8, this.y-4)
                    queueSound(0xc)
                end
                
--                memory.writebyte(0x0056,spidey.counter % 3)
--                memory.writebyte(0x0057,1)
                
            elseif objects.custom[i].type=="poof" then
                local x,y=objects.custom[i].x-scrollx+1, objects.custom[i].y-scrolly
                if objects.custom[i].alivetime<0x0e then 
                    spidey.drawCircle(x+7,y+4,math.max(1,20-objects.custom[i].alivetime*2), string.format("#ffff80%02x",math.max(0,0x3d+spidey.counter % 0x04 - objects.custom[i].alivetime*2) ))
                end
                if objects.custom[i].alivetime>0x10 then 
                    objects.custom[i].die = true
                end
            elseif this.type=="candle" then
                --if this.isOnScreen(i) or true then
                if objects.custom.isOnScreen(i) then
                    f=math.floor(this.alivetime/06) % 2
                    local x,y=this.x-scrollx+1, this.y-scrolly-4
                    --o.flicker = 8
                    this.flicker = this.flicker or 0
                    if this.flicker == 0 then
                        if math.random(1,50)==1 then this.flicker = math.random(4,10) end
                    end
                    
--                    spidey.drawCircle(x+7-3,y+4,3, "#FFFF9910")
--                    spidey.drawCircle(x+7+3,y+4,3, "#FFFF9910")
                    if ((this.flicker or 0) == 0) or this.alivetime %4>=1 then
                        --spidey.drawCircle(x+7,y+4,40, "#FFFF9910")
                        if config.qualityPreset == "high" then
                            spidey.drawCircle(x+7,y+4,30+(math.floor(spidey.counter * .25) % 3)*2, string.format("#ffff80%02x",0x0d+spidey.counter % 0x04 ))
                        end
                        --spidey.drawCircle(x+7,y+4,6, "#FFFF9950")
                        if config.qualityPreset ~= "low" then
                            spidey.drawCircle(x+7,y+4,6, "#FFFF9930")
                        end
                    else
                        if config.qualityPreset ~= "low" then
                            spidey.drawCircle(x+7,y+4,5, "#FFFF9920")
                        end
                    end
                    this.flicker = math.max(this.flicker - 1,0)
                    gfx.draw(this.x-scrollx+1, this.y-scrolly-4, gfx.candles[f])

                    local x=this.x-scrollx
                    local y=this.y-scrolly
                    local rect = {x-5+7,y-1-3,x+7+7,y+14-3}
                    if config.hitboxes or spidey.debug.enabled then
                        gui.box(rect[1],rect[2],rect[3],rect[4],"#0040ff60", "#0040ff80")
                    end
                    
                    this.hitbox = rect
                    
                    --if collision(rect, hitboxes.whip.rect) then
                    
                    this.getHit = function()
                        this.destroy = true
                        playSound(0x04)
                        local obj = createObject("poof",this.x, this.y)
                        if obj and this.item then
                            if hasInventoryItem(this.item) then
                                obj.item = {type="bigheart", x=this.x+4, y=this.y+2, floor=this.floor}
                            else
                                obj.item = {type="item", x=this.x+4, y=this.y+2, floor=this.floor, itemName=this.item}
                            end
                        else
                            obj.item = {type="heart", x=this.x+4, y=this.y+2, floor=this.floor}
                        end
                        --obj.item = {type="item", x=objects.custom[i].x+4, y=objects.custom[i].y+2, floor=objects.custom[i].floor, itemName="Gold"}
--                        floor = objects.custom[i].floor
                        --local h = createObject("heart",objects.custom[i].x, objects.custom[i].y)
                        --h.floor = objects.custom[i].floor
                    end
                end
            elseif objects.custom[i].type=="holyfire" then
                objects.custom[i].frame = objects.custom[i].frame or 0
                --if objects.custom[i].alivetime > 8 and objects.custom[i].alivetime %4>2 then
                if objects.custom[i].alivetime % 5==0 then
                    objects.custom[i].frame = (objects.custom[i].frame + 1) % 5
                end
                
                --gfx.draw(objects.custom[i].x-2-scrollx, objects.custom[i].y-2-scrolly, gfx.holyfire.test)
                gfx.draw(objects.custom[i].x-2-scrollx, objects.custom[i].y-2-scrolly-15, gfx.holyfire[objects.custom[i].frame])
                for ii=0,objects.count-1 do
                    if objects[ii].type~=0 and objects[ii].team==1 then
                        xdist=math.abs(objects[ii].x-objects.custom[i].x+scrollx)
                        ydist=math.abs(objects[ii].y-objects.custom[i].y+scrolly)
                        if xdist<10 and ydist<30 then
                            --objects.custom[i].active=0
                            hurtenemy(ii)
                            break
                        end
                    end
                end
                if objects.custom[i].alivetime > 55 then
                    objects.custom[i].destroy=1
                end
            elseif objects.custom[i].type=="heart" or objects.custom[i].type=="bigheart" then
                local big = (objects.custom[i].type == "bigheart")
                gfx.draw(objects.custom[i].x-2-scrollx, objects.custom[i].y-6-scrolly, big and gfx.bigheart or gfx.heart)
--                if big then
--                    gfx.draw(objects.custom[i].x-2-scrollx, objects.custom[i].y-6-scrolly, big and gfx.bigheart or gfx.cv2heart)
--                else
--                    gfx.draw(objects.custom[i].x-2-scrollx, objects.custom[i].y-6-scrolly, gfx.cv2heart)
--                end
                
                --objects.custom[i].ys=objects.custom[i].ys+.1

                if objects.custom[i].alivetime == 1 then
                    objects.custom[i].ys = .1
                    if big then objects.custom[i].ys = 1 end
                    objects.custom[i].falling = true
                end
                
                if objects.custom[i].falling then
                    if big then
                        objects.custom[i].ys = math.min(3, objects.custom[i].ys * 1.2)
                    else
                        objects.custom[i].ys = math.min(.7, objects.custom[i].ys * 1.05)
                        objects.custom[i].x = objects.custom[i].x+math.sin(objects.custom[i].alivetime *.09)*1
                    end
                end
                


                if objects.custom[i].floor then
                    if objects.custom[i].y>objects.custom[i].floor then
                        objects.custom[i].y=objects.custom[i].floor
                        objects.custom[i].ys = 0
                        objects.custom[i].falling=false
                    end
                elseif objects.custom[i].y>objects.custom[i].originY+0x10*3+12 then
                    objects.custom[i].y=objects.custom[i].originY+0x10*3+12
                    objects.custom[i].ys = 0
                    objects.custom[i].falling=false
                end
                if objects.custom[i].xdist<11 and objects.custom[i].ydist<18 then
                    objects.custom[i].active=0
                    if config.candlesRealHearts then
                        getheart()
                    else
                        if objects.custom[i].type=="bigheart" then
                            addHearts(5)
                        else
                            addHearts(1)
                        end
                        playSound(0x1f)
                    end
                end
                if objects.custom[i].alivetime > 1000 then
                    objects.custom[i].destroy = true
                end
            elseif objects.custom[i].type=="diamondtrail" then
                if objects.custom[i].alivetime == 1 then objects.custom[i].fade = 0xff end
                if objects.custom[i].alivetime %1==0 then
                    if objects.custom[i].alivetime>30 then
                        objects.custom[i].fade = (objects.custom[i].fade or 0xff) - 5
                        if objects.custom[i].fade<0 then objects.custom[i].fade = 0 end
                    end
                    gui.pixel(objects.custom[i].x+5-scrollx, objects.custom[i].y+5-scrolly,"#ffffff"..string.format("%02x",objects.custom[i].fade or 255))
                    --drawfont(objects.custom[i].x+5-scrollx, objects.custom[i].y+5-scrolly,font[4], ".")
                    --gui.drawtext(objects.custom[i].x+2-scrollx, objects.custom[i].y-2-scrolly, ".", "white", "clear")
                    
                end
                if objects.custom[i].alivetime>=100 then
                    objects.custom[i].active = 0
                end
            elseif objects.custom[i].type=="itemPopUp" then
                local x = 8*15
                local y = 8*26+4
                local text = objects.custom[i].text or ""
                local borderColor = "#0070ec"
                if night then borderColor = "#24188c" end
                gui.drawbox(x-2, y-3, x+8*16+2, y+8*2+3, "black", "#10101040")
                gui.drawbox(x, y, x+8*16, y+8*2, "#000", borderColor)
                gui.drawbox(x+1, y-1, x+8*16-1, y+8*2+1, "clear", borderColor)
                
                drawfont(x+13,y+5,font[current_font], text)
                if objects.custom[i].alivetime>=80 then
                    objects.custom[i].active = 0
                end

            elseif objects.custom[i].type=="levelup" then
                local x = 70
                local y = 100
                local text = "- Level up! -"
                local borderColor = "#0070ec"
                if night then borderColor = "#24188c" end
                objects.custom[i].textIndex = objects.custom[i].textIndex or 1
                if objects.custom[i].alivetime % 2 == 0 then
                    objects.custom[i].textIndex = math.min(objects.custom[i].textIndex + 1, #text)
                end
                
                
                gui.drawbox(x-2, y-3, x+8*16+2, y+8*2+3, "black", "black")
                gui.drawbox(x, y, x+8*16, y+8*2, "#000", borderColor)
                gui.drawbox(x+1, y-1, x+8*16-1, y+8*2+1, "clear", borderColor)
                
                drawfont(x+13,y+5,font[current_font], text:sub(1,objects.custom[i].textIndex))
                

                if objects.custom[i].alivetime==1 then
                    memory.writebyte(0x04f8,0x40) -- make invincible
                end
                
                -- add brief laurel effect, but don't cancel an actual laurel
                local l = memory.readbyte(0x0197)
                memory.writebyte(0x0197, math.max(l, 1))
                
                -- heal
                if objects.player.hp < objects.player.maxHp and objects.custom[i].alivetime % 1 ==0 then
                    objects.player.hp = objects.player.hp + 1
                    memory.writebyte(0x0080, objects.player.hp)
                end

                if objects.custom[i].alivetime>=80 then
                    objects.custom[i].active = 0
                end
                objects.custom[i].deSpawn = function()
                    objects.player.hp = objects.player.maxHp
                    memory.writebyte(0x0080, objects.player.hp)
                end
            elseif objects.custom[i].type=="poisonDrip" then
                local target = objects.custom[i].target
                
                if objects.custom[i].alivetime == 1 then
                    objects.custom[i].x = objects[target].x-4
                    objects.custom[i].y = objects[target].y-14
                    objects.custom[i].x=objects.custom[i].x+math.random(-7,7)
                else
                    objects.custom[i].y=objects.custom[i].y+1
                end
                gui.drawpixel(objects.custom[i].x, objects.custom[i].y, "green")
                if objects.custom[i].alivetime>30 then
                    objects.custom[i].active=0
                end
            elseif objects.custom[i].type=="poison" then
                local target = objects.custom[i].target
                if objects.custom[i].alivetime==1 then
                    objects.custom[i].targetType = objects[target].type
                    objects.custom[i].poisonTicks = 0
                end

                if objects.custom[i].alivetime % 3 ==0 then
                    createPoisonDrip(target)
                    --local obj = createObject("poof",objects[objects.custom[i].target].x+scrollx-8, objects[objects.custom[i].target].y+scrolly-8)
                end
                
                if objects.custom[i].alivetime % 90 == 0 and objects[target].hp>0 then
                    objects[target].hp = objects[target].hp - 1
                    objects.custom[i].poisonTicks = objects.custom[i].poisonTicks +1
                    memory.writebyte(0x04c8+target, objects[target].hp)
                    if objects[target].hp <= 0 then
                        objects[target].stun = 0 -- make sure it isn't stunned so we can kill it
                        memory.readbyte(0x04fe+target, objects[target].stun)
                        objects[target].hp = 1 -- have to give it hp again so we can damage it
                        memory.writebyte(0x04c8+target, objects[target].hp)
                        hurtenemy(target)
                    end
                end
                
                if objects[target].type==0 or objects[target].hp<=0 or objects[target].type~= objects.custom[i].targetType then
                    objects.custom[i].active = 0
                end
                
                if objects.custom[i].poisonTicks >= 3 then
                    objects.custom[i].active=0
                end
            
            elseif objects.custom[i].type=="bone" then
                objects.custom[i].rnd=objects.custom[i].rnd or math.random(0,90000)
                f=math.floor((objects.custom[i].alivetime+objects.custom[i].rnd)/06) % 3
                if objects.custom[i].facing==0 then f=2-f end
                gfx.draw(objects.custom[i].x-2-scrollx-bone.xo[f], objects.custom[i].y-2-scrolly-8-bone.yo[f], gfx.bone[f])
                objects.custom[i].ys=objects.custom[i].ys+.09
                if objects.custom[i].xdist<15 and objects.custom[i].ydist<17 then
                    --objects.custom[i].destroy=true
                    hurtplayer()
                end

                local x=objects.custom[i].x-scrollx
                local y=objects.custom[i].y-scrolly
                local rect = {x-5,y-4-8,x+7,y+7-8}
                if config.hitboxes or spidey.debug.enabled then
                    gui.box(rect[1],rect[2],rect[3],rect[4],"#0040ff60", "#0040ff80")
                end
                if collision(rect, hitboxes.whip.rect) then
                    objects.custom[i].destroy = true
                    if config.boneJuggle then
                        -- bone juggle
                        createBone(objects.custom[i].x-scrollx, objects.custom[i].y-scrolly-8)
                    else
                        local obj = createObject("poof",objects.custom[i].x-4, objects.custom[i].y-8)
                        obj.aliveTime = 3
                    end
                end

            elseif objects.custom[i].type=="axe" then
                objects.custom[i].rnd=objects.custom[i].rnd or math.random(0,90000)
                f=math.floor((objects.custom[i].alivetime+objects.custom[i].rnd)/06) % 4
                if objects.custom[i].facing==0 then f=3-f end
                gfx.draw(objects.custom[i].x-2-scrollx-bone.xo[f], objects.custom[i].y-2-scrolly-8-bone.yo[f], gfx.axe[f])
                objects.custom[i].ys=objects.custom[i].ys+.09
                for ii=0,objects.count-1 do
                    if objects[ii].type~=0 and objects[ii].team==1 and (not objects.custom[i].hasHift) then
                        xdist=math.abs(objects[ii].x-objects.custom[i].x+scrollx)
                        ydist=math.abs(objects[ii].y-objects.custom[i].y+scrolly)
                        if xdist<10 and ydist<10 then
                            --objects.custom[i].active=0
                            objects.custom[i].hasHit=true
                            hurtenemy(ii)
                            break
                        end
                    end
                end
                
                local x=objects.custom[i].x-scrollx
                local y=objects.custom[i].y-scrolly
                local rect = {x-8,y-20,x+9,y+0}
                objects.custom[i].attackbox = rect
                
                if config.hitboxes or spidey.debug.enabled then gui.box(rect[1],rect[2],rect[3],rect[4],"#ff400060", "#ff400080") end
                
            elseif objects.custom[i].type=="bigbat" then
                objects.custom[i].outscreen=true
                f=math.floor(objects.custom[i].alivetime/10) % 2+1
                --if objects.custom[i].facing==0 then f=2-f end
                gfx.draw(objects.custom[i].x-2-scrollx-bigbat.xo[f], objects.custom[i].y-2-scrolly-8-bigbat.yo[f], gfx.bigbat[f])

                --objects.custom[i].y=objects.custom[i].y+math.cos(objects.custom[i].alivetime *.03)*2
                --objects.custom[i].x=objects.custom[i].x+math.sin(objects.custom[i].alivetime *.01)*1
                if objects.player.x+scrollx>objects.custom[i].x then dx=1 else dx=-1 end
                if objects.player.y+scrolly>objects.custom[i].y then dy=1 else dy=-1 end
                objects.custom[i].ys=objects.custom[i].ys+math.cos(objects.custom[i].alivetime *.03)*.004*dy
                objects.custom[i].xs=objects.custom[i].xs+math.sin(objects.custom[i].alivetime *.01)*.004*dx
                objects.custom[i].ys=objects.custom[i].ys+.006*dy
                objects.custom[i].xs=objects.custom[i].xs+.006*dx
                objects.custom[i].ys=objects.custom[i].ys-math.cos(objects.custom[i].alivetime *.03)*.022
                if objects.custom[i].alivetime % 30==0 then
                    objects.custom[i].xs=objects.custom[i].xs+dx*.5
                end
                if objects.custom[i].alivetime % 200==0 then
                    --objects.custom[i].xs=0
                    --objects.custom[i].ys=0
                    objects.custom[i].ys=.07*dy
                    objects.custom[i].xs=.17*dx
                    
                end
                --objects[i].y=objects[i].y+math.cos(emu.framecount()*.09)*1
                --objects[i].x=objects[i].x+math.sin(emu.framecount()*.09)*1
                --n=40

                if objects.custom[i].xdist<26 and objects.custom[i].ydist<17 then
                    --objects.custom[i].active=0
                    hurtplayer()
                end
            
            elseif objects.custom[i].type=="medusahead" then
                if objects.custom[i].onScreen then objects.custom[i].outscreen=false end
--                if objects.custom[i].alivetime == 2 then
--                    objects.custom[i].y=objects.player.y+16
--                end
                
                objects.custom[i].y=objects.custom[i].y+math.cos((objects.custom[i].alivetime+80) *.056)*2
                
                local frame = math.floor(objects.custom[i].aliveTime /10) % 2+1
                gfx.draw(objects.custom[i].x-scrollx-6, objects.custom[i].y-scrolly-12, gfx.medusa[objects.custom[i].facing+1][frame])
                
                if (objects.custom[i].hurtTimer or 0) > 0 then
                    objects.custom[i].hurtTimer=(objects.custom[i].hurtTimer or 0)-1
                elseif objects.custom[i].xdist<10 and objects.custom[i].ydist<10 then
                    --objects.custom[i].active=0
                    objects.custom[i].hurtTimer=15
                    hurtplayer(0x0a)
                end
                
                
                local x=objects.custom[i].x-scrollx
                local y=objects.custom[i].y-scrolly
                local rect = {x-5,y-4-8,x+9,y+7-4}
                objects.custom[i].hitbox = rect
                
                if config.hitboxes or spidey.debug.enabled then gui.box(rect[1],rect[2],rect[3],rect[4],"#0040ff60", "#0040ff80") end
                
                objects.custom[i].getHit = function()
                    objects.custom[i].die = true
                    objects.custom[i].deathSound = 0x1a
                    objects.custom[i].item = {type="poof", x=objects.custom[i].x-4, y=objects.custom[i].y-10}
                end
                
            elseif objects.custom[i].type=="bansheeboomerang" then
                
                f=math.floor(objects.custom[i].alivetime/5) % 3
                if objects.custom[i].facing==0 then f=2-f end
                gfx.draw(objects.custom[i].x-2-scrollx, objects.custom[i].y-2-scrolly-8, gfx.boomerang[f])
                --objects.custom[i].xs=objects.custom[i].xs+.1
                if objects.custom[i].rebound == false then
                    if objects.custom[i].xs>0 then
                        if objects.custom[i].x-scrollx>240 then objects.custom[i].xs=-objects.custom[i].xs; objects.custom[i].x = 255+scrollx-10; objects.custom[i].rebound=true end
                    elseif objects.custom[i].xs<0 then
                        if objects.custom[i].x-scrollx<0 then objects.custom[i].xs=-objects.custom[i].xs; objects.custom[i].x = 0+scrollx+0; objects.custom[i].rebound=true end
                    end
                end
                for ii=0,objects.count-1 do
                    if objects[ii].type~=0 and objects[ii].team==1 then
                        xdist=math.abs(objects[ii].x-objects.custom[i].x+scrollx)
                        ydist=math.abs(objects[ii].y-objects.custom[i].y+scrolly)
                        if xdist<10 and ydist<10 then
                            --objects.custom[i].active=0
                            hurtenemy(ii)
                            break
                        end
                    end
                end
                xdist=math.abs(objects.player.x-objects.custom[i].x+scrollx)
                ydist=math.abs(objects.player.y-objects.custom[i].y+scrolly)
                if objects.custom[i].alivetime>20 and xdist<10 and ydist<10 then
                    --catch
                    objects.custom[i].active=0
                    break
                end
            elseif objects.custom[i].type=="dracfire" then
                gfx.draw(objects.custom[i].x-2-scrollx, objects.custom[i].y-2-scrolly, cv2fire)
                objects.custom[i].ys=objects.custom[i].ys*.99
                if objects.custom[i].facing==1 then 
                    objects.custom[i].xs=objects.custom[i].xs+.13
                else
                    objects.custom[i].xs=objects.custom[i].xs+-.13
                    
                end
                if objects.custom[i].xdist<10 and objects.custom[i].ydist<10 then
                    objects.custom[i].active=0
                    hurtplayer()
                end
            else
                gfx.draw(objects.custom[i].x-2-scrollx, objects.custom[i].y-2-scrolly, cv2fire)
            end
            
            --if collision(rect, hitboxes.whip.rect) then
            if objects.custom[i].hitbox and objects.custom[i].getHit then
                local getHit=false
                if collision(objects.custom[i].hitbox, hitboxes.whip.rect) then getHit=true end
                
                for ii = 2,19 do
                    local hb=hitboxes.object[ii] or {}
                    if hb.subType=="SimonProjectile" and collision(objects.custom[i].hitbox, hb.rect) then getHit=true end
                end
                
                for k,v in ipairs(objects.custom) do
                    if v.attackbox and collision(objects.custom[i].hitbox, v.attackbox) then getHit=true end
                end
                
                if getHit then objects.custom[i].getHit() end
            end
            
            if objects.custom[i].destroy then
                objects.custom[i].active = 0
            end
            if objects.custom[i].die then
                if objects.custom[i].deathSound then
                    queueSound(objects.custom[i].deathSound)
                end
                if objects.custom[i].item then
                    local obj = createObject(objects.custom[i].item.type,objects.custom[i].item.x, objects.custom[i].item.y)
                    for k,v in pairs(objects.custom[i].item) do
                        obj[k]=v
                    end
                end
                objects.custom[i].active = 0
            end
            
            if objects.custom[i].x-scrollx<0 or objects.custom[i].y-scrolly<0 or objects.custom[i].x-scrollx>255 or objects.custom[i].y-scrolly>255  then
                if objects.custom[i].outscreen then
                    objects.custom[i].onScreen = false
                else
                    objects.custom[i].active=0
                end
            else
                objects.custom[i].onScreen = true
            end
            
        end
    end
    
    if objects[0].type==0x03 and false then
        if (emu.framecount() % 48)==0 then
            local i=getunused()
            if i~=-1 then
                gui.text(20,20, string.format("%3u",i))
                objects[i].type=0x30
                objects[i].x=objects[0].x
                objects[i].y=objects[0].y
                memory.writebyte(0x03ba+i,objects[i].type)
                --memory.writebyte(0x0306+i,objects[i].frame)
                memory.writebyte(0x0348+6+i,objects[i].x)
                memory.writebyte(0x0324+6+i,objects[i].y)
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
    
    if msgstatus==0x07 then
        memory.writebyte(0x7000+3, 0x00)
    end
    
    msgMode = memory.readbyte(0x7000+3)
    msgChoice = memory.readbyte(0x7000+4)
    
    -- skip horrible night message
--    if msgnum==0x00 and msgstatus<=0x08 then
--        msgstatus=0x08
--        memory.writebyte(0x007a, msgstatus)
--    end
    
    -- church message
    if not pausemenu and (msgstatus==0x03 or msgstatus==0x06) and msgnum==0x31 and msgindex == 0x16 then
        --emu.pause()
        if msgMode==0x00 and (joy[1].right_press or joy[1].left_press) then
            msgChoice=(msgChoice+1) %2
            memory.writebyte(0x7000+4, msgChoice)
        end
        if joy[1].cancel_press then
            -- Still refill hp if not saving.
            objects.player.hp = objects.player.maxHp
            memory.writebyte(0x0080, objects.player.hp)

            memory.writebyte(0x7000+3, 1)
            msgstatus=0x06
            memory.writebyte(0x007a, msgstatus)
        end
        if msgMode==0x00 and joy[1].confirm_press then
            objects.player.hp = objects.player.maxHp
            memory.writebyte(0x0080, objects.player.hp)
            
            memory.writebyte(0x7000+3, 1)
            msgstatus=0x05
            memory.writebyte(0x007a, msgstatus)
            if msgChoice==0x00 then
                saveGame(game.saveSlot)
            end
        else
            if msgMode == 0x01 then
                msgstatus=0x04
                memory.writebyte(0x007a, msgstatus)
                memory.writebyte(0x7000+3, 0x02)
            elseif msgMode==0x00 then
                --emu.message(msgstatus)
                msgstatus=0x05
                memory.writebyte(0x007a, msgstatus)
                drawfont(8*6,5+8*10,font[current_font], "Save?")
                drawfont(8*9,5+8*12,font[current_font], "Yes   No")
                
                if msgChoice == 0x00 then
                    gfx.draw(8*9,5+8*11,gfx.arrowcursor)
                    --drawfont(8*09,5+8*11,font[current_font], "x")
                else
                    gfx.draw(8*15,5+8*11,gfx.arrowcursor)
                    --drawfont(8*15,5+8*11,font[current_font], "x")
                end
            end
        end
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
    if action and (cheats.active) then
        
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
            objects.player.dance=objects.player.dance or {stepCount=0, headBangCount=0}
            objects.player.dance.headBangCount = objects.player.dance.headBangCount or 0
            music1=memory.readbyte(0x00a3)
            if music1==0x3d then
                if memory.readbyte(0x00b5)==0x02 then
                    memory.writebyte(0x300,0x0c)
                else
                    memory.writebyte(0x300,0x0d)
                end
                objects.player.dance = {stepCount=0, headBangCount=0}
            elseif music1==0x40 then
                if objects.player.dance.headBangCount<=16 then
                    if memory.readbyte(0x00b5)==0x03 then
                        objects.player.dance.lastHeadBang = true
                        memory.writebyte(0x239,0x3d) -- head banger
                    else
                        if objects.player.dance.lastHeadBang == true then
                            objects.player.dance.lastHeadBang = false
                            objects.player.dance.headBangCount=objects.player.dance.headBangCount+1
                        end
                    end
                else
                    -- turn step dance
                    if memory.readbyte(0x00b5)==0x03 then
                        objects.player.dance.lastStep = true
                        memory.writebyte(0x300,0x08)
                    else
                        if objects.player.dance.lastStep then
                            objects.player.dance.lastStep = false
                            objects.player.dance.stepCount=objects.player.dance.stepCount+1
                        end
                        memory.writebyte(0x300,0x04)
                    end
                    
                    if (objects.player.dance.stepCount %4 > 2) or objects.player.dance.stepCount > 20 then
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
--        if whipframe==01 then --fast whip
--            whipframe=02
--        end
        
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
        if objects.player.hp < objects.player.maxHp and os.time() % 10==0 then
            objects.player.hp = objects.player.hp + 1
            memory.writebyte(0x0080, objects.player.hp)
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
            for k,item in ipairs(items) do
                if item.type =="food" or item.type=="gold" or item.type=="bag" then
                    -- don't get non-carry items
                elseif not hasInventoryItem(item.name) then
                    getItem(item.name)
                end
            end
            updateItems()
        end
        if cheats.flamewhip then
            if not hasInventoryItem("Flame Whip") then
                getItem("Flame Whip")
                setWhip(items.index["Flame Whip"])
            end
        end
        if cheats.invincible then memory.writebyte(0x04f8,0x20) end
        memory.writebyte(0x0086,0x06) --hours = 06
        memory.writebyte(0x0085,0x01) --minutes = 00
        
        objects.player.gold = math.max(objects.player.gold, 5000)
        memory.writeword(0x7000+1, objects.player.gold)
        
        if cheats.refightbosses then refight_bosses=true end
        
    end
    
--    if action or (pausemenu and frame_tester) then
--        drawHUD()
--    end
    
    mnu.background = not frame_tester -- don't show menu background if using the frame tester
    
    if specialPause and joy[1].select_press then
        exitSpecialPause = true
    end
    
    if config.debug and game.paused and cheats.enabled and mapmenu == false then
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
    
    --gfx.draw(100,100, testGraphics)
    
    hideHP()
    
    if pausemenu and game.map.visible then
        gui.drawbox(0, 0, spidey.screenWidth-1,spidey.screenHeight-1, "black","black")
        gfx.draw(-game.map.x, -game.map.y, gfx.map)
        local x = 87
        local y = 209
        
        local mapLabel = function(x,y,n)
            gui.text(-game.map.x+x-1,-game.map.y+y-1,n, "#888","clear")
            gui.text(-game.map.x+x+1,-game.map.y+y+1,n, "black","clear")
            gui.text(-game.map.x+x+1,-game.map.y+y,n, "black","clear")
            gui.text(-game.map.x+x+1,-game.map.y+y+1,n, "black","clear")
            gui.text(-game.map.x+x,-game.map.y+y,n, "#c0b0ff","clear")
            if n==locations.getAreaName(area1,area2,area3,areaFlags) and spidey.counter%6<3 then
                gui.text(-game.map.x+x,-game.map.y+y,n, "white","clear")
            end
        end
        
        for _,item in ipairs(game.map.locations) do
            mapLabel(item.x,item.y, item.text)
        end
        
        gui.text(8,8*2,string.format("%02x %02x",game.map.x+spidey.inp.xmouse,game.map.y+spidey.inp.ymouse),"white","black")
        
        return
    end
    
    if action then
        -- Bordia Mountains
        if area1==0x02 and area2==0x09 and area3==0x02 and scrollx >= 0x265 then
            -- make invisible stairs visible if you have the eye
            if relics.list.eye then
                local x=0x2f0+0x79-scrollx
                local y=0x6e
                for i=1,24 do
                    gui.drawbox(x,y,x+3,y+2,"clear","#2040a060")
                    gui.drawbox(x,y,x+4,y+1,"clear","#80808060")
                    x=x+4
                    y=y+4
                end
            end
        end
    
    
        -- fixes issue where you can use a door to cancel day.
        if time == "06:00" and inDoor and night then
            memory.writebyte(0x0082, 0)
            night = false
--            memory.writebyte(0x002c, 0x06) -- day/night toggle thing
--            memory.writebyte(0x0088, 0x01) -- day/night toggle counter
        end
    end
    
    if action and (config.hitboxes or spidey.debug.enabled) then
        hitboxes.draw()
    end
    
    if action or (pausemenu and frame_tester) or (game.paused and not config.debug) then
        drawHUD()
    elseif pausemenu then
        drawSubScreen()
    end
    
    if (action or pausemenu) and objects.player.inBossRoom==true then
        if displayarea=="Castlevania" then
            -- Don't bother with blocks for final Dracula fight
        else
            gfx.draw(0,13+16*10,gfx.block)
            gfx.draw(0,13+16*11,gfx.block)
            gfx.draw(16*15,13+16*10,gfx.block)
            gfx.draw(16*15,13+16*11,gfx.block)
        end
    end
    
--    for k,v in ipairs(game.boxes or {}) do
--        gui.drawbox(v[1],v[2],v[3],v[4],v[5],v[6])
--    end
--    game.boxes={}
    
    
    if action and config.testStats then
        local stats= getStats()
        gui.text(10,50,string.format("level %d, hp %d/%d\nstr %d, atk %d, con %d, def %d\nexp %d, next %d",objects.player.level+1,objects.player.hp,objects.player.maxHp, stats.str, stats.atk, stats.con, stats.def, getCurrentExp(), objects.player.expNext),"white","#00002080")
    end
    
    if game.credits.show then
        if spidey.counter % 3 == 0 then
            game.credits.y = game.credits.y + 1
        end
        
        local c = string.format("#000000%02x",math.min(0xff, game.credits.y))
        gui.drawbox(0, 0, spidey.screenWidth-1, spidey.screenHeight-1, c, c)
        
        local txt = cv2data.credits
        txt = string.gsub(txt, "\n", "\n\n")
        
        --gfx.draw(8*5+48+8*6-8*11,8*40-(game.film.y or 0)+8*10,gfx.castle)
        
        drawfont(10,8*36-(game.credits.y or 0),font[5], txt)
        --spidey.message("credits %02x",game.credits.y)
        
        c = string.format("#000000%02x",math.min(0x90, game.credits.y))
        for i=1,8 do
            gui.drawbox(0, 0, spidey.screenWidth-1, 6*(i-1), c, c)
            gui.drawbox(0, spidey.screenHeight-1-6*i, spidey.screenWidth-1, spidey.screenHeight-1, c, c)
        end
        
        if game.credits.y>=0x2d0 then
            game.credits.show=false
            game.credits.done=true
            game.showSaveMenu=true
        end
        
    end
    
    if game.md5Data and game.md5Data.md5 then
        if game.md5Data.md5 == string.lower("1B827C602C904D8C846499C9F54B93E0") then
            gui.drawbox(0,0,spidey.screenWidth-1,spidey.screenHeight-1,"#00006080", "#00006080")
            gui.text(20,40,string.format("Rom matches No-Intro. \nchecksum=%s", game.md5Data.md5), "white", "clear")
        else
            gui.drawbox(0,0,spidey.screenWidth-1,spidey.screenHeight-1,"#8070c0a0", "#8070c0a0")
            gui.text(20,40,string.format("Unknown rom. \nchecksum=%s", game.md5Data.md5), "white", "clear")
        end
    end

--    if emu.framecount() % 100 >=50 then
--        gui.drawbox(50,50,150,150,"#80808080", "#60606080")
--        gui.drawtext(50,50-8-2,"Current", "white","clear")
--    else
--        gui.drawbox(50,50,150,150,"#80808080", "clear")
--        gui.line(50,50,150-1,50,"#60606080")
--        gui.line(150,50,150,150-1,"#60606080")
--        gui.line(150,150,50+1,150,"#60606080")
--        gui.line(50,150,50,50+1,"#60606080")
--        gui.drawtext(50,50-8-2,"Expected", "white","clear")
--    end

end

spidey.run()