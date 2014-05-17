-- script by SpiderDave
-- version 2014.05.17
-- for dehumanization :)

--[[
Changes/Features:
    * Various cheats when enabled (hold jump button for a float move when active)
    * Guest enemies.  These enemies can be placed with left mouse button, and removed
      with middle mouse button.  The changes can be saved and loaded.  Use the in-game
      menu item "Edit Type" to change the object to place.  The spawn positions are
      visible when "Show Debug" is enabled.
        -- Birds
        -- Flying Shells
        -- Fire Wheels
    * Hamburgers give 2 hp instead of 4.
Bugs/Issues:
    * Bombs sometimes fail to destroy custom objects when the player is getting hit
    * Script menu is shared with normal pause menu
    * Placing a fire wheel low to screen will have it show on screen below.  It's fine, but looks out of place for NES.
ToDo:
    * More enemy types
    * Mouse-free editing option
    * Support for Power Blazer
      * Detect if rom is Power Blade or Power Blazer
--]]

spidey=require "Spidey.SpideyStuff"
font=require "Spidey.default_font"
require "Spidey.TSerial"

-- Don't enable this unless all the files exist; it's for
-- rebuilding the gfx file when new images are added.
makeGfxFile=false

if makeGfxFile then
    gfx={
        cursor=getfilecontents("Spidey/images/powerblade_cursor.gd"),
        bird={
            [1]={[0]=getfilecontents("Spidey/images/ng_bird1l.gd"),
                 getfilecontents("Spidey/images/ng_bird1r.gd")},
            [2]={[0]=getfilecontents("Spidey/images/ng_bird2l.gd"),
                 getfilecontents("Spidey/images/ng_bird2r.gd")}
        },
        hammerBro={
            [1]={[0]=getfilecontents("Spidey/images/smb_hammerbro1l.gd"),
                 getfilecontents("Spidey/images/smb_hammerbro1r.gd")},
            [2]={[0]=getfilecontents("Spidey/images/smb_hammerbro2l.gd"),
                 getfilecontents("Spidey/images/smb_hammerbro2r.gd")},
            [3]={[0]=getfilecontents("Spidey/images/smb_hammerbro3l.gd"),
                 getfilecontents("Spidey/images/smb_hammerbro3r.gd")}
        },
        flyingShell={
            [1]=getfilecontents("Spidey/images/mm1_flyingshell1.gd"),
            [2]=getfilecontents("Spidey/images/mm1_flyingshell2.gd"),
            [3]=getfilecontents("Spidey/images/mm1_flyingshellbullet.gd"),
        },
        fire={
            [1]=getfilecontents("Spidey/images/cv2fire.gd")
        }
    }

    local t= TSerial.pack(gfx)
    writetofile('Spidey/PowerBlade.gfx', t)
    emu.message("saved.")

else -- use premade gfx file instead

    temp=getfilecontents('Spidey/PowerBlade.gfx')
    if temp then
        temp=TSerial.unpack(temp)
        gfx=temp
        emu.message("loaded.")
     else
        emu.message("Error: could not load data.")
     end
end

enableddisabled={[true]="enabled",[false]="disabled"}


game={}
player={}
current_font=6

game.paused=false

cheats={
    enabled=true,
    active=false,
    invincible=false,
    lives=true,
    bombs=true,
    heals=true,
    hp=true,
    control_boss=true,
    suit=true,
    showmem=false
}
debug={
    show=false,
    showBoxes=true,
    bird=true,
    wind=true,
    --editType={index=1,"bird","flying shell","hammer brother"}
    editType={index=1,"bird","flying shell","fire wheel (clockwise)", "fire wheel (counter-clockwise)"}
}

--converts unsigned 8-bit integer to signed 8-bit integer
function signed8bit(_b)
if _b>255 or _b<0 then return false end
if _b>127 then return (255-_b)*-1 else return _b end
end

function getUnused()
    local i
    for i=0,0x0f-1 do
        if memory.readbyte(0x404+i)==0x00 then
            --memory.writebyte(0x4e8+i,inp.xmouse or 0x30) --enemy x
            --memory.writebyte(0x4c2+i,(inp.ymouse or 0x30+8)-8) --enemy y
            --memory.writebyte(0x404+i,0x31) -- soldier bullet
            return i
        end
    end
    return nil
end


function createObject(x,y,t,xSpeed,ySpeed)
    local i=getUnused()
    if not i then return nil end
    memory.writebyte(0x4e8+i,x) -- x
    memory.writebyte(0x4c2+i,y) -- y
    memory.writebyte(0x404+i,t) -- type
    memory.writebyte(0x534+i,xSpeed or 0xff) -- x speed
    memory.writebyte(0x50e+i,ySpeed or 0x00) -- y speed
    -- memory.writebyte(0x476+i,0x04) -- palette
    --difference = 0x26
    
    return i
end


game={}
game.time=0
game.message={}
player={blades={}}
o={}
o.max=1000
for i=1,o.max do o[i]={} end
enemies={}


function game.load()
    temp=getfilecontents('Spidey/Power_Blade.dat')
    if temp then
        temp=TSerial.unpack(temp)
        o:clear()
        for i=1,o.max do
            if temp[i] then o[i]=temp[i] end
        end
        emu.message("loaded.")
     else
        emu.message("Error: could not load data.")
     end
end


function player:hurt()
    local i
    if self.invincible then return end
    i=createObject(self.x-self.scrollX, self.y-self.scrollY-16, 0x02, 0x00,0x00) -- type=explode/item
    if not i then return nil end
    memory.writebyte(0x463+i,0x00) -- ??
    memory.writebyte(0x593+i,0x05) -- 05=explode/item is in item state
    memory.writebyte(0x43d+i,0x01) -- item type=star
    memory.writebyte(0x580+i,0x05) -- item countdown
    memory.writebyte(0x43d+i,0x00) -- gfx = blank
    memory.writebyte(0x42a+i,0x00) -- 40 = collectable (make sure we can get hit by it)
end

function o:getUnused()
    for _i=1,self.max do
      if not self[_i] then self[_i]={} end
      if not self[_i].type then
        self.lastIndex=_i
        return _i
      end
    end
    return false
end

-- will have parameters later
function o:clear()
    for _i=1,#self do
      o[_i]={}
    end
end

function o:exists(type, id)
    for _i=1,#self do
      if not self[_i] then return nil end
      if not self[_i].type then return nil end
      if self[_i].type==type and self[_i].id==id then
        return true
      end
    end
    return nil
end

function o:new(type, x,y, area)
    local i=self:getUnused()
    if not i then return nil end
    self[i]={}
    self[i].type=type
    self[i].x=x
    self[i].y=y
    self[i].area=area or game.area
    self[i].aliveTime=0
    self[i].xSpeed=0
    self[i].ySpeed=0
    self[i].armed=true
    self[i].facing=0 --left
    self[i].action=nil
    self[i].actionCount=0
    self[i].center={x=0,y=0}
    o[i].outScreen_destroy=false
    if self[i].type=="bird" or self[i].type=="flying shell" or self[i].type=="hammer brother" then
        self[i].destroyable=true
        self[i].bombable=true
    else
        self[i].destroyable=nil
        self[i].bombable=nil
    end
    if self[i].type=="bullet" then
        self[i].bombable=true
    end
    return i
end


classMenu=spidey.classes.Menu
mnu=classMenu:new()
mnu.font=font[current_font]
mnu.background="small"
mnu.cursor_image=gfx.cursor
--mnu.background_color=spidey.nes.palette[0x01]
--mnu.background_color="P01"
--mnu.background_color="#24188cf0"
mnu.background_color="P0F"
mnu.items={}
mnu.items={
    {text="Load Enemy Data",
    action=function()
        temp=getfilecontents('Spidey/Power_Blade.dat')
        if temp then
            temp=TSerial.unpack(temp)
            o:clear()
            for i=1,o.max do
                if temp[i] then o[i]=temp[i] end
            end
            emu.message("loaded.")
         else
            emu.message("Error: could not load data.")
         end
    end},
    
    {text="Save Enemy Data",
    action=function()
        local temp={}
        for i=1,o.max do
            if o[i] and o[i].type=="spawn" then
                temp[i]=o[i]
            end
        end
        local t= TSerial.pack(temp)
        writetofile('Spidey/Power_Blade.dat', t)
        emu.message("saved.")
    end},
    
    {text="Boss",
    action=function()
        --memory.writebyte(0x004d,0x00) -- unpausing seems to cause errors, even with frameadvance
        memory.writebyte(0x004c,0x06)
    end},
    
    {text="Edit Type",
    action=function()
        debug.editType.index=debug.editType.index+1
        if not debug.editType[debug.editType.index] then debug.editType.index=1 end
        emu.message(string.format("%02X %s",debug.editType.index,debug.editType[debug.editType.index]))
        game.message.text=string.format("%02X %s",debug.editType.index,debug.editType[debug.editType.index])
        game.message.counter=100
    end}
}
mnu:addStandard()

-- Import the address class.
Address=spidey.classes.Address

--game.messageID=Address:new(0x0067)
--game.characters={{},{},{},{}}
--game.characters[1].xSpeed=Address:new(0x068ab)
--game.characters[1].x=Address:new(0x06ad3)
--game.characters[1].y=Address:new(0x06ad4)


--[[
Window=spidey.classes.Window
window1=Window:new("test")
window1:show()
]]--

game.load() -- load extra enemies

function spidey.update(inp,joy)
    --game.messageID:get()
    --game.characters[1].x:get()
    --game.characters[1].y:get()
    --player.character:get()
    game.paused=(memory.readbyte(0x004d)==0x01)
    game.action=not game.paused
    
    if debug.show then
        --drawfont(0+4,8+4,font[current_font], string.format("message %02X",game.messageID.value))
        --drawfont(0+4,8*2+4,font[current_font], string.format("game mode     %02X %02X",game.mode.value, game.modeCounter.value))
    end
    
    -- checks if whole palette is black via game palette.  good for detecting screen transitions, etc.
    dark=true
    for i=0,31 do
        if memory.readbyte(0x03e1+i)~=0x0f and memory.readbyte(0x03e1+i)~=0x00 then
            dark=nil
            break
        end
    end
    game.time=game.time+1
    game.area=memory.readbyte(0x02a)
    if memory.readbyte(0x080)==0x01 then
        -- If in boss room, we'll increase the area by 256 as a convenience.
        game.area=game.area+0x100
    end
    game.checkpoint=memory.readbyte(0x028) -- 02=boss door
    
    -- 2a=in game
    game.mode=memory.readbyte(0x042)
    game.mode2=memory.readbyte(0x019)
    game.mode3=memory.readbyte(0x03d)
    
    -- 04=normal (not climbing, etc), 08=in boss room
    game.action2= (memory.readbyte(0x04c)==0x04 or memory.readbyte(0x04c)==0x08)
    
    player.state=memory.readbyte(0x0426)
    player.dying=(player.state==0x80)
    --action=(not paused) and (not screenTransition) and (not dark) and game.mode==0x2a
    game.action=(not game.paused) and (not screenTransition) and (not dark) and game.mode==0x2a
    player.invincible=(memory.readbyte(0x0569)>0)
    player.usingBomb=(memory.readbyte(0x0094)~=0x00) -- in bombing state
    player.useBomb=(memory.readbyte(0x0094)==0x07) -- one time thing for convenience
    screenTransition=(memory.readbyte(0x0040)==0x02) and not player.usingBomb
    player.scrollX=memory.readbyte(0x069)*0x100 + memory.readbyte(0x06a)
    player.scrollY=memory.readbyte(0x02b)*0x100
    scrollX=player.scrollX
    scrollY=player.scrollY
    player.x=memory.readbyte(0x04e4)+scrollX
    player.y=memory.readbyte(0x04be)+scrollY
    
    for i=1,3 do
        player.blades[i]={}
        player.blades[i].type = memory.readbyte(0x0401+i-1)
        player.blades[i].x = memory.readbyte(0x04e5+i-1)+player.scrollX
        player.blades[i].y = memory.readbyte(0x04bf+i-1)+player.scrollY+8
    end
    
    gui.text(0,0, ""); -- force clear of previous text

    
    -- Draw extra text at title screen
    if game.mode==0x2e and game.mode2~=0x00 then
        drawfont(8*14-4,8*12+4,font[current_font], "SpiderDave Mode")
    end
    
    --if cheats.showmem then showmem(0x0400) end
    
    -- draw player hit box (this is just a guess atm)
    --gui.drawbox(player.x-scrollX-8, player.y-scrollY-24, player.x-scrollX+8, player.y-scrollY+8, 'clear',"blue")
    --gui.drawbox(player.x-scrollX-8, player.y-scrollY-16, player.x-scrollX+8, player.y-scrollY+8, 'clear',"blue")
    
    --gui.drawbox(player.blades[1].x-scrollX-8, player.blades[1].y-scrollY-8, player.blades[1].x-scrollX+8, player.blades[1].y-scrollY+8, 'clear',"blue")
    
    -- get enemy data
    for i=0,0x0f-1 do
        enemies[i]={}
        enemies[i].x=memory.readbyte(0x4e8+i)
        enemies[i].y=memory.readbyte(0x4c2+i)
        enemies[i].type=memory.readbyte(0x404+i)
        enemies[i].gfx=memory.readbyte(0x43d+i)
        enemies[i].state=memory.readbyte(0x593+i) -- robo skeleton getting up
        enemies[i].state2=memory.readbyte(0x5a6+i) -- robo skeleton dead time
        enemies[i].state3=memory.readbyte(0x417+i) -- bits; 08=platform invisible, 81=enemy out of screen+invis?
        
        enemies[i].outScreen=nil
        if enemies[i].state3 ~= enemies[i].state3 % 0x80 and enemies[i].state3 ~= enemies[i].state3 % 0x01 then
            enemies[i].outScreen=true
        end
        
        --enemies[i].facing=memory.readbyte(0x496+i)
        enemies[i].facing=memory.readbyte(0x489+i)
        
        if enemies[i].type~=0 and (not enemies[i].outScreen) and debug.show then
            --drawfont(enemies[i].x,enemies[i].y,font[current_font], string.format("%02X",enemies[i].type))
            drawfont(enemies[i].x,enemies[i].y,font[current_font], string.format("%02X %02X %02X %02X",enemies[i].type, enemies[i].state, enemies[i].state2, enemies[i].state3))
            drawfont(enemies[i].x,enemies[i].y-8,font[current_font], string.format("%02X",i))
        end
        
        if enemies[i].type==0x31 and memory.readbyte(0x4fb+i)>=0x30 then
            -- turn soldier bullets into bouncing bullets (after a short time)
            --memory.writebyte(0x404+i,0x44)
        end
        
        if enemies[i].type==0x3f then
            -- change running soldier into trap gun thing
            --memory.writebyte(0x404+i,0x3e)
        end
        
        if debug.bird and enemies[i].type==0x31 and memory.readbyte(0x4fb+i)>=0x3 then
            -- turn soldier bullets into birds (!!!) (after a short time)
            --memory.writebyte(0x404+i,0x00) -- remove old object
            --o:new("bird",enemies[i].x+scrollX,enemies[i].y+scrollY)
        end
        if false and enemies[i].type==0x31 then-- and memory.readbyte(0x4fb+i)>=0x3 then
            -- turn soldier bullets into spread (after a short time)
            memory.writebyte(0x404+i,0x00) -- remove old object
            n=o:new("bullet",enemies[i].x+scrollX,enemies[i].y+scrollY)
            o[n].xSpeed=-2
            o[n].ySpeed=-1
            n=o:new("bullet",enemies[i].x+scrollX,enemies[i].y+scrollY)
            o[n].xSpeed=-2
            n=o:new("bullet",enemies[i].x+scrollX,enemies[i].y+scrollY)
            o[n].xSpeed=-2
            o[n].ySpeed=1
        end
        
        if enemies[i].type==0x0c then
            -- add shooting ability to specific flying enemy
            if game.time % 200==50 then
                n=o:new("bullet",enemies[i].x+scrollX,enemies[i].y+scrollY)
                o[n].xSpeed=-1
                o[n].ySpeed=0
                if enemies[i].facing==0x01 then o[n].xSpeed=o[n].xSpeed*-1 end
            end
        end
        if enemies[i].type==0x22 then
            -- add shooting ability to robo skeleton things
            if game.time % 200==50 and enemies[i].state==1 then
                n=o:new("bullet",enemies[i].x+scrollX,enemies[i].y+scrollY-3)
                o[n].xSpeed=-2
                o[n].ySpeed=0
                if enemies[i].facing==0x01 then o[n].xSpeed=o[n].xSpeed*-1 end
            end
        end
        
        if enemies[i].type==0x38 then
            -- contact guy
            --enemies[i].gfx=0x00
            --memory.writebyte(0x43d+i,enemies[i].gfx)
            --memory.writebyte(0x439+i,0)
        end
        
    end
    
    if memory.readbyte(0x002F)==0x04 then
        memory.writebyte(0x002F,0x02) -- half healing from burgers
        --memory.writebyte(0x0026,0x01)
    end
    
    if game.action and inp.leftbutton_press and not spidey.imgEdit.capture then
        -- create object
        --n=o:new("spawn",(inp.xmouse or 0x30)+scrollX,(inp.ymouse or 0x30+8)+scrollY-8)
        n=o:new("spawn",(inp.xmouse or 0x30)+scrollX,(inp.ymouse or 0x30)+scrollY)
        o[n].spawnType=debug.editType[debug.editType.index]
        o[n].id=string.format("%02X%02X%02X",o[n].x,o[n].y, game.area)
        o[n].armed=nil
    end
    
    for i=1,#o do
        if o[i] and o[i].type and game.action and game.action2 then
            o[i].lastOutScreen=o[i].outScreen
            o[i].outScreen=(o[i].area~=game.area or o[i].x-scrollX<0 or o[i].x-scrollX>0xff or o[i].y-scrollY<0 or o[i].y-scrollY>0xf0)
            o[i].enterScreen = (o[i].lastOutScreen and not o[i].outScreen)
            if o[i].outScreen and o[i].outScreen_destroy then
                o[i].type=nil
            end
        end
        if o[i] and o[i].type and game.action and game.action2 and o[i].area==game.area then
            if debug.show then
                --gui.drawbox(o[i].x-scrollX, o[i].y-scrollY, o[i].x-scrollX+8, o[i].y-scrollY+8, 'clear',"yellow")
            end
            
            if o[i].type=="spawn" then
                o[i].outScreen_destroy=nil
                o[i].center={x=4,y=4}
                if debug.show then
                    gui.drawbox(o[i].x-scrollX-o[i].center.x, o[i].y-scrollY-o[i].center.y, o[i].x-scrollX+8-o[i].center.x, o[i].y-scrollY+8-o[i].center.y, 'clear',"teal")
                    --drawfont(o[i].x-scrollX-o[i].center.x+8, o[i].y-scrollY-o[i].center.y,font[current_font], string.format("%s",o[i].spawnType))
                end

                if o[i].enterScreen then
                    if debug.show then gui.drawbox(o[i].x-scrollX-o[i].center.x, o[i].y-scrollY-o[i].center.y, o[i].x-scrollX+8-o[i].center.x, o[i].y-scrollY+8-o[i].center.y, 'red',"red") end
                    if o:exists(o[i].spawnType, o[i].id) then
                    else
                        n=o:new(o[i].spawnType,o[i].x,o[i].y)
                        o[n].id=o[i].id
                    end
                end
                if not spidey.imgEdit.capture then
                    if math.dist(inp.xmouse,inp.ymouse, o[i].x-scrollX,o[i].y-scrollY)<8 then
                        gui.drawbox(o[i].x-scrollX-o[i].center.x, o[i].y-scrollY-o[i].center.y, o[i].x-scrollX+8-o[i].center.x, o[i].y-scrollY+8-o[i].center.y, 'teal',"blue")
                        drawfont(o[i].x-scrollX-o[i].center.x+8, o[i].y-scrollY-o[i].center.y,font[current_font], string.format("%s",o[i].spawnType))
                        if inp.middlebutton_press then
                            o[i]=nil
                        end
                    end
                end
            elseif o[i].type=="gun" then
                o[i].outScreen_destroy=true
                if o[i].aliveTime % 20 == 0 then
                    createObject(o[i].x-scrollX, o[i].y-scrollY, 0x31, 0xfe,0x00)
                end
            elseif o[i].type=="bird" then
                o[i].outScreen_destroy=true
                if o[i].aliveTime % 20 == 0 then
                    if o[i].x>player.x then
                        o[i].facing=0
                        o[i].xSpeed=o[i].xSpeed*.94
                        if o[i].aliveTime>20 then
                            o[i].xSpeed=o[i].xSpeed-1.3
                            o[i].x=o[i].x-.9
                        else
                            o[i].xSpeed=o[i].xSpeed-.2
                        end
                    elseif o[i].x<player.x then
                        o[i].facing=1
                        o[i].xSpeed=o[i].xSpeed*.94
                        if o[i].aliveTime>20 then
                            o[i].xSpeed=o[i].xSpeed+1.3
                            o[i].x=o[i].x+.9
                        else
                            o[i].xSpeed=o[i].xSpeed+.2
                        end
                    end
                    if o[i].y>player.y then
                        --o[i].ySpeed=-2
                        --o[i].ySpeed=o[i].ySpeed-1
                        o[i].ySpeed=o[i].ySpeed-.6
                        o[i].ySpeed=o[i].ySpeed*.7
                        o[i].y=o[i].y-2
                    elseif o[i].y<player.y then
                        --o[i].ySpeed=2
                        --o[i].ySpeed=o[i].ySpeed+1
                        o[i].ySpeed=o[i].ySpeed+.6
                        o[i].ySpeed=o[i].ySpeed*.7
                        o[i].y=o[i].y+2
                    end
                    if o[i].xSpeed>5 then o[i].xSpeed=5 end
                    if o[i].xSpeed<-5 then o[i].xSpeed=-5 end
                    if o[i].ySpeed>5 then o[i].ySpeed=5 end
                    if o[i].ySpeed<-5 then o[i].ySpeed=-5 end
                end
                o[i].center={x=12,y=16}
                if o[i].aliveTime %12>6 then
                    o[i].gfx=gfx.bird[1][o[i].facing]
                else
                    o[i].gfx=gfx.bird[2][o[i].facing]
                end
            elseif o[i].type=="bullet" then
                o[i].outScreen_destroy=true
                o[i].gfx=gfx.flyingShell[3]
                o[i].center={x=4,y=4}
                if o[i].outScreen then
                    o[i].type=nil
                end
            elseif o[i].type=="flying shell" then
                o[i].outScreen_destroy=true
                -- These are those things from Megaman 1 that shoot in 8 directions
                if o[i].aliveTime==0 then o[i].action="move" end
                o[i].center={x=12,y=12}
                if o[i].action=="shoot" then
                    o[i].gfx=gfx.flyingShell[2]
                    o[i].xSpeed=0
                    if o[i].actionCount==8 then
                        --shoot
                        o[i].spawnType="bullet"
                        n=o:new(o[i].spawnType,o[i].x,o[i].y)
                        o[n].ySpeed=-3
                        n=o:new(o[i].spawnType,o[i].x,o[i].y)
                        o[n].ySpeed=3
                        n=o:new(o[i].spawnType,o[i].x,o[i].y)
                        o[n].xSpeed=-3
                        n=o:new(o[i].spawnType,o[i].x,o[i].y)
                        o[n].xSpeed=3
                        n=o:new(o[i].spawnType,o[i].x,o[i].y)
                        o[n].xSpeed=-2
                        o[n].ySpeed=-2
                        n=o:new(o[i].spawnType,o[i].x,o[i].y)
                        o[n].xSpeed=2
                        o[n].ySpeed=-2
                        n=o:new(o[i].spawnType,o[i].x,o[i].y)
                        o[n].xSpeed=-2
                        o[n].ySpeed=2
                        n=o:new(o[i].spawnType,o[i].x,o[i].y)
                        o[n].xSpeed=2
                        o[n].ySpeed=2
                    end
                    if o[i].actionCount==32 then
                        o[i].action="move"
                        o[i].actionCount=0
                    end
                else
                    o[i].gfx=gfx.flyingShell[1]
                    o[i].xSpeed=-1
                    if o[i].actionCount==64 then
                        o[i].action="shoot"
                        o[i].actionCount=0
                    end
                end
                if o[i].x-scrollX<8 then
                    o[i].x=scrollX+0xff
                    o[i].action="move"
                    o[i].actionCount=0
                end
                o[i].actionCount=o[i].actionCount+1
                if o[i].outScreen then
                    o[i].type=nil
                end
            elseif o[i].type=="hammer brother" then
                o[i].outScreen_destroy=true
                if o[i].x<player.x then
                    o[i].facing=1
                else
                    o[i].facing=0
                end
                
                o[i].gfx=gfx.hammerBro[1][o[i].facing]
                o[i].center={x=6,y=8}
                o[i].actionCount=o[i].actionCount+1
                if o[i].outScreen then
                    o[i].type=nil
                end
            elseif o[i].type=="fire wheel (clockwise)" or o[i].type=="fire wheel (counter-clockwise)" then
                if o[i].aliveTime==0 then
                    o[i].spawnType="fire"
                    for f=0,6 do
                        n=o:new(o[i].spawnType,o[i].x,o[i].y)
                        o[n].fireDistance=f
                        if o[i].type=="fire wheel (clockwise)" then
                            o[n].fireDirection=1
                        else
                            o[n].fireDirection=-1
                        end
                    end
                end
                o[i].outScreen_destroy=nil
            elseif o[i].type=="fire" then
                if o[i].aliveTime == 0 then
                    o[i].action="move"
                    o[i].startX=o[i].x
                    o[i].startY=o[i].y
                end
                o[i].x=o[i].startX+math.cos(o[i].fireDirection*o[i].aliveTime *.02)*((o[i].fireDistance or 0)*10)
                o[i].y=o[i].startY+math.sin(o[i].fireDirection*o[i].aliveTime *.02)*((o[i].fireDistance or 0)*10)
                o[i].outScreen_destroy=true
                o[i].outScreen_destroy=nil
                
                o[i].gfx=gfx.fire[1]
                --o[i].center={x=6,y=8}
                o[i].center={x=4,y=4}
                o[i].actionCount=o[i].actionCount+1
                if o[i].outScreen then
                    --o[i].type=nil
                end
            end
            if o[i] and o[i].type and o[i].area==game.area then
                if o[i].gfx then gui.gdoverlay(o[i].x-scrollX-o[i].center.x, o[i].y-scrollY-o[i].center.y, o[i].gfx) end
                if game.action then
                    o[i].x=o[i].x+o[i].xSpeed
                    o[i].y=o[i].y+o[i].ySpeed
                    
                    o[i].aliveTime = o[i].aliveTime +1 
                    if o[i].armed and math.dist(player.x,player.y-8, o[i].x,o[i].y)<19 then
                        player:hurt()
                    end
                    
                    if player.useBomb and o[i].bombable then
                        -- destroy object, create explosion
                        o[i].type=nil
                        createObject(o[i].x-scrollX,o[i].y-scrollY, 0x02, 0x00,0x00)
                    elseif o[i].destroyable then
                        local b=0
                        for b=1,3 do
                            if player.blades[b].type~=0 and math.dist(player.blades[b].x,player.blades[b].y, o[i].x,o[i].y)<24 then
                                o[i].type=nil
                                createObject(o[i].x-scrollX,o[i].y-scrollY, 0x02, 0x00,0x00)
                            end
                        end
                    end
                end
            end
        end
    end
    
    if (cheats.active) then
        if cheats.lives then memory.writebyte(0x0027,0x09) end
        if cheats.bombs then memory.writebyte(0x005a,0x09) end
        if cheats.heals then memory.writebyte(0x005b,0x09) end
        if cheats.hp then memory.writebyte(0x04ab,0x10) end
        if cheats.suit then memory.writebyte(0x009c,0x03) end
        if cheats.invincible then
            -- Note: can't pick up items when invincible
            memory.writebyte(0x0569,0x11) -- Invincible
            memory.writebyte(0x0413,0x01) -- no flashing
        end
        if memory.readbyte(0x04ab)>0x01 then
            -- 1 hit kill
            -- memory.writebyte(0x04ab,0x01)
        end
        
        if nil and inp.leftbutton_press and not spidey.imgEdit.capture then
            -- create 3 bullets
            createObject(inp.xmouse, (inp.ymouse or 0x30+8)-8, 0x31, 0xff,0xff)
            createObject(inp.xmouse, (inp.ymouse or 0x30+8)-8, 0x31, 0xfe,0x00)
            createObject(inp.xmouse, (inp.ymouse or 0x30+8)-8, 0x31, 0xff,0x01)
        end
        
        if cheats.control_boss then
            boss={}
            boss.state1=memory.readbyte(0x059e)
            boss.state2=memory.readbyte(0x05b1)
            boss.gfx=memory.readbyte(0x0448)
            
            --boss.state1=0x03
            --boss.state2=0x00
            --[[
            if boss.state1==0x02 and boss.gfx==0x00 then
                boss.state2=0
                boss.state1=02
                boss.gfx=BD
            end
            ]]--
            --boss_gfx=0x00
            memory.writebyte(0x059e,boss.state1)
            memory.writebyte(0x05b1,boss.state2)
            memory.writebyte(0x0448,boss.gfx)
        end
        
        --[[
        enemystate= memory.readbyte(0x05a0)
        enemystatec= memory.readbyte(0x05b3)
        if enemystate==02 and enemystatec ==0x04 then
            memory.writebyte(0x05a0,0x03)
            memory.writebyte(0x05b3,0x00)
        end
        ]]--
        
        if false and joy[1].A_press and game.action and player.state==0x01 and memory.readbyte(0x050a) <=0x03 then
            --memory.writebyte(0x0439,0x16)
            memory.writebyte(0x0439,0x19) -- frame (visual)
            memory.writebyte(0x050a,0xfa)
            memory.writebyte(0x051d,0x70)
        end
        
        if joy[1].A_press_time > 30 and game.action and game.action2 and player.state==0x01 then
            --hold jump button for a float move
            memory.writebyte(0x04d1,0x88)
            if joy[1].up and player.y-scrollY>20 then
                memory.writebyte(0x050a,0xfd)
            elseif joy[1].down and player.y-scrollY<0xff-20 then
                memory.writebyte(0x050a,0x01)
            else
                memory.writebyte(0x050a,0xff)
                
            end
            memory.writebyte(0x051d,0x70) -- gravity
        end
    end
    if game.action and debug.show then
        drawfont(0+4,8+4,font[current_font], string.format("state = %02X",player.state))
        drawfont(0+4+8*16,8+4,font[current_font], string.format("x %02X y %02x",inp.xmouse or 0,inp.ymouse or 0))
        drawfont(0+4,8*10+4,font[current_font], string.format("scroll %02X",scrollX))
    end

    
    if fontChar then
        x=0
        y=8
        for i=0x20,0x7e do
            if fontChar[i] then
                gui.gdoverlay(x,y, fontChar[i].img)
                --gui.text(x,y,"*","white","clear")
                x=x+8
                --x=x+fontChar[i].imgWidth
            end
            if x>255 then
                y=y+8
                x=0
            end
        end
    end
    
--    game.characters[1].x:set()
--    game.characters[1].y:set()
    
    if game.paused and cheats.enabled then
        --memory.writebyte(0x0020,0x00)
        mnu:show()
    else
        mnu:hide()
    end
end

spidey.run()