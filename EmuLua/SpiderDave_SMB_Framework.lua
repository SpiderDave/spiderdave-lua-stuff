-- SMB Lua script by SpiderDave

-- Load the Spidey library with all the bells and whistles.
spidey=require "Spidey.SpideyStuff"

-- Default font used in Spidey menu.
local font=require "Spidey.default_font"

-- Utilities.
local util = require "Spidey.util"

-- Config file loading.  This will also hold the loaded values.
local config = util.config

config.load("smb/config.default.txt")
config.load("smb/config.txt")

-- The smb library.
local smb = require("smb.smb")

local Thing = require("smb.thing")
local obj = Thing.holder

local ai = require("smb.ai")
ai.init(smb)
obj.setAI(ai)

-- smb specific callback functions.
require("smb.callbacks")

--local jetpack = require("smb.jetpack")

local graphics = require("Spidey.graphics")
graphics:init(config.graphics_mode or "")

local gfx = require("smb.gfx")
gfx.init(graphics)
gfx.gdPath = "smb/images/gd/"
gfx.pngPath = "smb/images/png/"

gfx.blooper = gfx.load("blooper2")
gfx.bulletBill = gfx.load("bulletbill")
gfx.medusa = gfx.load("medusa1")
gfx.bullet = gfx.load("bullet")
gfx.bullet.xo = 8
gfx.bullet.yo = 8

gfx.brickTop = gfx.load("brickTop")

if config.convert then
    local convert=function(f)
        local img = gd.createFromPng(gfx.pngPath..f..".png")
        --local newFile = string.gsub(f, "%.png", "%.gd")
        local newFile = f..".gd"
        img:gd(gfx.gdPath..newFile)
    end

    convert("blooper2")
    convert("bulletbill")
    convert("medusa1")
    convert("bullet")
    convert("brickTop")
end

game = {
    player={}
}
local player=game.player
game.paused = false

--current_font=2
current_font=1

cheats={
    enabled=true,
    active=false,
    hp=true,
    cantDie=true,
    lives=true
}

game.tile=0

classMenu=spidey.classes.Menu
mnu=classMenu:new()
mnu.font=font[current_font]
mnu.background="small"
mnu.background_color="black"
mnu.items={}
mnu.items={
    {
        text=function()
            --local world, level = smb.getLocation()
            return string.format("World %d-%d", game.world+1, game.level+1)
        end,
        
        left = function()
            game.level=game.level-1
            if game.level == -1 then
                game.world=game.world-1
                game.level = 3
                if game.world==-1 then game.world = 7 end
            end
        end,
        right = function()
            game.level=game.level+1
            if game.level == 4 then
                game.world=game.world+1
                game.level = 0
                if game.world==8 then game.world = 0 end
            end
        end,
        
        action=function()
            smb.warp(game.world+1,game.level+1)
        end,
    },
    {
        text = function()
            return string.format("tile %02x", game.tile)
        end,

        left = function()
            game.tile=math.max(0, game.tile-1)
        end,
        
        right = function()
            game.tile=math.min(255, game.tile+1)
        end,
        
        action = function()
            smb.warp(game.world+1,game.level+1)
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


-- needs work
function onSquare1SfxHandler(sfx)
--    if sfx==32 then sfx=0 end
--    sfx=16
--    return sfx
end

function onCheckIfFiery(status)
    --return 2
end


function onPlayerInjury(abort)
    if config.invulnerable then abort=true end
    return abort
end

function onSetEnemySpeed(eType, speed, sign)
    if eType==0x06 then
        --spidey.message(speed)
        --speed=speed*3
    end
    return speed
end

function onSetPlayerPalette(CurrentPlayer, PlayerStatus, index, c)
-- dark mario
--if index==0 then return 0x06 end
--if index==1 then return c-0x10 end
--if index==2 then return c-0x10 end
--if index==3 then return c-0x10 end

--    if index==1 or index==3 then
--        if CurrentPlayer==0 then
--            return c-3
--        else
--            return c+5
--        end
--    end
end


function onLoadBackgroundMetatile(n)
    --if n==3 then n=0 end
    --if n==2 then n=85 end
    --n=0x0a
--    n=game.tile
--    n=n+1
    return n
end

function onLoadForegroundMetatile(n)
--    if n==84 then
--        if math.random(0,1)==1 then
--            n=85
--        end
--    end
    
--    if n==84 then
--        n=0x61
--    elseif n==0x61 then
--        n=84
--    end
--    n=0x61
    
    return n
end


function onTileTest(a, index)
    -- attribute
    --memory.writebyte(0x03,0xff)
    return a
end

function onMusic(music, event)
--    if event then
--        spidey.message("Music: %s", util.flipTable(smb.constants.eventMusic)[music])
--    else
--        spidey.message("Music: %s", util.flipTable(smb.constants.music)[music])
--    end
    
    if config.music == false then
        music = smb.constants.music.Silence
    end
    
    return music
end


function onStomp()
--    memory.writebyte(0x1d,0x01)
--    spidey.message("test")
--    local y=memory.readbyte(0x9f)
--    y=0xf4
    --return y
end

function onSetFireballSpeed(axis, s, sign)
    if config.fireballSpeedX and (axis=="x") then s=config.fireballSpeedX*sign end
    if config.fireballSpeedY and (axis=="y") then s=config.fireballSpeedY*sign end
    --if axis=="y" then s=-3 end
    --if axis=="x" then s=30*sign end
    
--    if axis=="x" then s = math.random(20,50)*sign end
--    if axis=="y" then s = math.random(1,3)*-1 end
    return s
end

function onSetFireballDownwardForce(yf)
    if config.fireballDownwardForce then yf=config.fireballDownwardForce end
    return yf
end


function onGameTimer(useTimer)
    if config.noTimer then
        useTimer = 0
    end
    return useTimer
end

function onSetLakituTimer(t)
    if config.lakituTimer then t = config.lakituTimer end
    return t
end

function onSetCheepCheepTimer(t)
    t=0x0a
    return t
end

function onHitWall(side, facing)
    if side== facing then
        --spidey.message("bump %02x %02x", side, facing)
        --gui.text(30,30, "bump")
        game.wallBump = 10
        game.wallBumpFacing = facing
    end
    --memory.writebyte(0x9f, 0xff)
end

-- if textNumber==0 it's top status bar
-- c is used for position (nametable address), length of text and characters
-- nametable address hi, nametable address lo, x-position, length of text, text characters, terminated by 0xff
-- 0x20, 0x43, 0x05, "MARIO", 0x20, 0x52, 0x0b, "WORLD  TIME", 0x20, 0x68, 0x05, "0  ", 0x2e (coin icon), "x",
function onPrintText(textNumber, c, index)
    local a,x,y,s,p,pc=spidey.getregisters()
    --if c==0xff then return c end
    
    if textNumber == 0x00 then
        --if index==0x09 then c=0 end
        if index==0x26 then c=0x20 end -- y
        if index==0x27 then c=0x48 end -- x
        if index==0x28 then c=0x01 end -- nCharacters
        if index==0x29 then c=0x2b end -- "!"
        if index==0x2a then c=0xff end -- 0xff terminator
        
--        if c==0xff then
--            spidey.message("%02x",index)
--        end
    end
    
    
--    gui.text(40,40,string.format("%02x",textNumber))
--    emu.pause()
    
--    if textNumber==0 then
--        if index==0x00 then c = 0x20 end
--        if index==0x01 then c = 0x6b end
--        if index==0x02 then c=  0x01 end
--        if index==0x03 then c=  0x2e end
--        if index==0x04 then c=  0xff end
--    else
--        c=0xff
--    end
--    if textNumber == 0x00 then
--        if index==0x11 then c=0 end
--    end
    --spidey.message("%04x %02x", stackAddress, n)
    
    return c
end

--function onCheckEnemyType(e)
--    if e==0x8b then e=63 end
--    e=0x60
--    return e
--end

--function onLoadEnemyData(e)
--    spidey.message("enemy %02x", e)
--    return e
--end


function onCheckScrollable(canScroll)
    --canScroll=true
    
    --if smb.getUnusedEnemyIndex()~=0 then canScroll = false end
    
    return canScroll
end

function onCheckFrameForColorRotation(f)
    
--    local tileNum = 0x24
--    local r = math.random(0,0x10-1)
--    local n = math.random(0,255)

--    for i = 0,16-1 do
--        rom.writebyte(0x10+0x8000+0x1000+tileNum*0x10+r,0)
--        rom.writebyte(0x10+0x8000+0x1000+tileNum*0x20+r,0)
--    end


--    if f>0 then
--        rom.writebyte(0x10+0x8000+0x1000+tileNum*0x10+r-1,0xff)
--        rom.writebyte(0x10+0x8000+0x1000+tileNum*0x20+r-1,0xff)
--    end
--    n=f % 64
    
--    rom.writebyte(0x10+0x8000+0x1000+tileNum*0x10+r,0x00)
--    rom.writebyte(0x10+0x8000+0x1000+tileNum*0x20+r,0x00)
    
    if false then
        -- corrupt background
        local tileNum = math.random(0,255)
        local r = math.random(0,0x10-1)
        local n = math.random(0,255)
        rom.writebyte(0x10+0x8000+0x1000+tileNum*0x10+r,n)
        
        -- corrupt foreground
        local tileNum = math.random(0,255)
        local r = math.random(0,0x10-1)
        local n = math.random(0,255)
        rom.writebyte(0x10+0x8000+tileNum*0x10+r,n)
    end
    
    --if f % 0x40 == 0 then createEnemy(math.random(0x10)) end
    --if f % 0x40 == 0 then createEnemy(0x0c) end -- poodaboo
    --if f % 0x40 == 0 then createEnemy(0x05) end -- hammer bro
    --if f % 0x40 == 0 then smb.createEnemy(0x2e) end -- mushroom (needs work)
    
    --if f % 0x40 == 0 then 
    if (f % 0x20 == 0) and false then 
        if math.random(3)==1 then
            -- bullet bill
            if smb.createEnemy(0x08, 255,math.random(200), -3,0) then
                memory.writebyte(0xfe, 0x08) -- store #Sfx_Blast in Square2SoundQueue
            end
        end
    end
    
    
    --f=1
--    spidey.message(f)
--    f=math.random(255)
    return f
end

--function onSetIntermediateBackgroundColor(c)
--    c=0x15
--    return c
--end

--function onIntermediate()
--    spidey.message("boop")
--end

function _onSetIntermediateSprite(x,y)
    x=0xc8
    --x=0xb0
    --y=y+3
    y=0x20
    return x,y
end


--function onSetPlayerMaximumSpeed(d, s, sign)
--    if game.flying then
--        s=60
--        if d=="left" then s=200-s end
--    end
--    return s
--end


function onLoadBlockSolidity(b)
    --if b==0x51 then b=0 end
    return b
end

function onLivesDisplay(digit, n, lives)
    if config.fixLivesDisplay then
        if digit==0 then
            -- write 0x00 to VRAM_Buffer1+0x17 to set the palette of the first digit to white
            memory.writebyte(0x317,0x00)
        end

        if lives>99 then
            -- just display 99 lives if > 99
            return 9
        end

        return tonumber(string.sub(string.format("%02d",lives),digit+1,digit+1))
    end
end

function onGameRoutine(n)
--    if n~=8 then
--        spidey.message("Routine: %02x %s",n, util.flipTable(smb.constants.gameRoutines)[n])
--    end
    return n
end


function onPlayerChangeSize(n)
    --spidey.message("change size")
    --n=08
    return n
end

emu.registerexit(function(x) emu.message("") end)
function spidey.update(inp,joy)
    lastinp=inp
    
    if smb.paused() then
        if not game.paused then
            game.world, game.level = smb.getLocation()
        end
    end
    
    game.paused = smb.paused()
    game.frozen = smb.frozen() -- Game is frozen for example when you collect a mushroom
    game.action = smb.action()
    
    player.control = (memory.readbyte(0x0e)==0x08)
    player.isOnScreen = smb.playerOnScreen()
    local ScreenEdge_X_Pos = memory.readbyte(0x71c)
    local ScreenEdge_PageLoc = memory.readbyte(0x71a)
    local scrollX = ScreenEdge_PageLoc *0x100 + ScreenEdge_X_Pos
    game.scrollX = scrollX
    game.ScreenEdge_X_Pos = ScreenEdge_X_Pos
    local mouseTileX = math.floor((inp.xmouse+ScreenEdge_X_Pos % 16)/16)
    local mouseTileY = math.floor(inp.ymouse/16)
    smb.getHitBoxes()
    
--    if game.action then gui.text(50,50,"action") end
--    if game.frozen then gui.text(50,50+8*1,"frozen") end
--    if game.paused then gui.text(50,50+8*2,"paused") end
    
    -- game.location id is a string like "1-2 0225".
    local world, level, area, areaPointer = smb.getLocation()
    game.location = {world=world, level=level, area=area, areaPointer=areaPointer, id = string.format("%x-%x %02x%02x",world+1, level+1, area, areaPointer)}
    
    gui.text(50,50, game.location.id)
    gui.text(50,50+8, string.format("%02x %02x",mouseTileX,mouseTileY))
    
--    if cheats.active then
--        if cheats.hp then memory.writebyte(0x0065, 0x10) end
--        if cheats.lives then memory.writebyte(0x0076, 0x09) end
--    end
    
    if spidey.debug.enabled then
    end
    
    -- Float
    if config.float and player.control then
        player.floatTimer=player.floatTimer or 0
        
        local playerState = memory.readbyte(0x1d)
        local xs, ys = smb.getPlayerSpeed()
        local xmf, ymf = smb.getPlayerMoveForce()
        
        if (playerState==1 or playerState==2) and joy[1].A_press and player.hasFloated == false then
            player.floatTimer = 80
        elseif joy[1].A_release then
            player.floatTimer = 0
        elseif playerState == 0 then
            player.floatTimer = 0
            player.hasFloated = false
        elseif joy[1].A and player.floatTimer > 0 then
            if ys>-1 then
                player.hasFloated = true
                ys=0
                ymf=0
                smb.setPlayerSpeed(xs, ys)
                smb.setPlayerMoveForce(xmf,ymf)
                player.floatTimer = player.floatTimer - 1
            end
        end
    end
    
    
    --game.flying=true
    if game.flying then
        local xs, ys = smb.getPlayerSpeed()
        local xmf, ymf = smb.getPlayerMoveForce()
        ys=0
        xs=0
        ymf=0
        xmf=0
        if joy[1].left then
            xs=-60
            --xs=60
        elseif joy[1].right then
            xs=60
        end
        if joy[1].up then
            ys=-4
        elseif joy[1].down then
            ys=4
        end
        
--        memory.writebyte(0x450, smb.intToNESByte(-64)) -- MaximumLeftSpeed
--        memory.writebyte(0x456, smb.intToNESByte(64)) -- MaximumRightSpeed
        
        smb.setPlayerSpeed(xs, ys)
        smb.setPlayerMoveForce(xmf,ymf)
    end

    if joy[1].A_press and game.wallBump and config.wallJump then

        if memory.readbyte(0x754)==0 then
            memory.writebyte(0xff, 0x01) -- store #Sfx_BigJump in Square1SoundQueue
        else
            memory.writebyte(0xff, 0x80) -- store #Sfx_SmallJump in Square1SoundQueue
        end
        
        memory.writebyte(0x33, (1-game.wallBumpFacing)+1) -- PlayerFacingDir
        memory.writebyte(0x45, (1-game.wallBumpFacing)+1) -- Player_MovingDir
        
        xs=22
        if game.wallBumpFacing==0 then
            xs = 256-xs
        end
        
        memory.writebyte(0x0433,0xff)
        
        memory.writebyte(0x57, xs)
        
        memory.writebyte(0x9f, 0xfa) -- Player_Y_Speed
        --emu.pause()
    end
    if game.wallBump and config.wallJump then
        game.wallBump = game.wallBump - 1
        if game.wallBump==0 then game.wallBump = false end
    end
    
    if joy[1].select_press then
        --smb.createEnemy(0x07, 0x10, 0x10, 8, 1)
        --smb.createEnemy(0x08, 240,math.random(200), -1,0)
        
--        memory.writebyte(0xfe, 0x08) -- store #Sfx_Blast in Square2SoundQueue
        
--        for i=1,100 do
--            local o=obj.add()
--            o.image = "medusa"
--            o.x = game.scrollX+255+math.random(2000)
--            o.y = math.random(200)
--            o.xs = -1.3
--            o.ai = {"medusa","movement"}
--        end
    end
    
    
    if inp.leftbutton_press or inp.lefbutton then
        local o=obj.add()
        
        game.changeBlock = {
            p = ScreenEdge_PageLoc,
            x=mouseTileX,
            y=mouseTileY,
            tile = 0x51,
        }
        
        
        o.image = "brickTop"
        o.x = game.scrollX + mouseTileX*16
        o.x = game.ScreenEdge_X_Pos + inp.xmouse
        o.x = game.scrollX + inp.xmouse
        o.y = inp.ymouse
        
        o.x = math.floor(o.x / 16)*16
        o.y = math.floor(o.y / 16)*16
    end
    
    if not smb.frozen() then
        player.shootTime = math.max(0,(player.shootTime or 0) -1)
        
        if joy[1].B_press and player.shootTime == 0 and smb.playerHasControl() and player.isOnScreen then
            player.shootTime = 40
        end
        
        if (player.shootTime > 0 and player.shootTime % 3 == 0) and (smb.frozen()~=true) and player.isOnScreen then
            player.shootTime=player.shootTime-1
            local px,py = smb.getPlayerPosition()
            
            memory.writebyte(0xff, 0x20) -- play fireball sfx in square1 sound queue
            
            for i=1,4 do
                local o=obj.add()
                o.image = "bullet"
                o.y = py+8
                o.x=px
                o.xs = 1
                if memory.readbyte(0x33) == 0x02 then o.xs = o.xs*-1 end
                o.ai = {"bullet","sine2","movement"}
            end
        end
    end
    
    if joy[1].select_press then
        --smb.warp(2,2)
    end
    
    
    if game.action then
        for y=0,14 do
            for x=0,16 do
                local x1= math.floor((scrollX+x*16) / 16)
                local y1= y-2
                local p = ScreenEdge_PageLoc
                local x2= x1 % 0x20
                if game.changeBlock then
                    if game.changeBlock.p == p and game.changeBlock.x == x and game.changeBlock.y==y and y1>=0 then
                        memory.writebyte(0x500+math.floor(x2/16)*0xd0+(x2 % 16)+(y1*0x10), game.changeBlock.tile)
                        game.changeBlock = nil
                    end
                end
            end
        end
    end
    
    if game.action and config.showGrid then
        --c2=coin
        --c3
        --c5=axe
        --c6
        --60=hidden 1 up
        for y=0,14 do
            for x=0,16 do
                gui.drawbox(x*16-(ScreenEdge_X_Pos % 16), y*16, x*16+15-(ScreenEdge_X_Pos % 16), y*16+15, 'clear',"#ccccff60")
                
                --gui.text(x*16-(ScreenEdge_X_Pos % 16)+2, y*16+4, "00", "#ccccff60","clear" )
                
                
                local x1= math.floor((scrollX+x*16) / 16)
                local y1= y-2
                local p = ScreenEdge_PageLoc
                
                local x2= x1 % 0x20
                
                -- each page: 0x10 * 0x0d = 0xd0
                
                --if x1 >= 0 and x1<= 15+16*2 and y1>=0 and y1<=12 then
                if y1>=0 and y1<=12 then
                    local tile = memory.readbyte(0x500+math.floor(x2/16)*0xd0+(x2 % 16)+(y1*0x10))
                    if tile~=0 then
                        gui.text(x*16-(ScreenEdge_X_Pos % 16)+2, y*16+4, string.format("%02x",tile), "white","clear" )
                    end
                end
                
--                if game.changeBlock then
--                    if game.changeBlock.p == p and game.changeBlock.x == x and game.changeBlock.y==y and y1>=0 then
--                        memory.writebyte(0x500+math.floor(x2/16)*0xd0+(x2 % 16)+(y1*0x10), game.changeBlock.tile)
--                        game.changeBlock = nil
--                    end
--                end
                
                if mouseTileX==x and mouseTileY==y then
                    if y1>=0 then
                        local tile = memory.readbyte(0x500+math.floor(x2/16)*0xd0+(x2 % 16)+(y1*0x10))
                        gui.drawbox(x*16-(ScreenEdge_X_Pos % 16), y*16, x*16+15-(ScreenEdge_X_Pos % 16), y*16+15, 'white',"black")
                        gui.text(x*16-(ScreenEdge_X_Pos % 16)+2, y*16+4, string.format("%02x",tile), "blue","clear" )
                        
                        local tileP = 0
                        local tileIndex = tile
                        if tileIndex >=0x80 then
                            tileIndex= tileIndex-0x80
                            tileP = tileP + 2
                        end
                        if tileIndex >=0x40 then
                            tileIndex= tileIndex-0x40
                            tileP = tileP + 1
                        end
                        local desc = smb.constants.metaTiles[tileP][tileIndex] or "unknown"
                        
                        spidey.outlineText(x*16-(ScreenEdge_X_Pos % 16)+8-util.textWidth(desc)*2, y*16+4+9, desc, "blue","white" )
                    else
                        gui.drawbox(x*16-(ScreenEdge_X_Pos % 16), y*16, x*16+15-(ScreenEdge_X_Pos % 16), y*16+15, 'clear',"black")
                    end
                end
                
                --memory.readbyte(0x5d4+
                --gui.text(x*16-(ScreenEdge_X_Pos % 16)+2, y*16+4, "00", "#ccccff60","clear" )
            end
        end
        
        local playerX = memory.readbyte(0x86)
        local playerY = memory.readbyte(0xce)
        local Player_PageLoc = memory.readbyte(0x6d)
        local Player_X_Scroll = memory.readbyte(0x6ff)
        
        local px = Player_PageLoc*0x100+playerX-scrollX
        local py = playerY
        --gui.text(px,py, "*", "red","clear" )
        
        --gui.text(20,20, string.format("%04x",Player_PageLoc*0x100+playerX-scrollX))
        
        --gui.text(0,8,string.format("%04x", scrollX))
        --gui.text(0,8,string.format("%04x", inp.xmouse-(ScreenEdge_X_Pos % 16) ))
        --gui.text(0,8,string.format("%04x %04x", math.floor((inp.xmouse+ScreenEdge_X_Pos % 16)/16), math.floor(inp.ymouse/16) ))
    end
    
    if game.action and config.showHitBoxes then
        for i = 0, 17 do
            local state
            local show = false
            local c = "purple"
            if i==0 then
                c = "blue"
                show = (memory.readbyte(0xb5) <= 1) -- Player_Y_HighPos
            end
            if i>=1 and i<=5 then
                c = "green"
                show = (memory.readbyte(0x0e+i) > 0)
            end
            if i==6 then
                c = "orange"
                state = memory.readbyte(0x23)
                if state>6 then show=true end
            end
            if i>=7 and i<=8 then
                c = "red"
                show = (memory.readbyte(0x1d+i) > 0)
            end
            if i>=9 then
                state = memory.readbyte(0x2a+i-9)
                if state>=0x80 then
                    c="grey"
                else
                    c="yellow"
                end
                show = (memory.readbyte(0x2a+i-9) > 0)
                
            end
            
            if show then
                local x1 = memory.readbyte(0x4ac+i*4)
                local y1 = memory.readbyte(0x4ac+i*4+1)
                local x2 = memory.readbyte(0x4ac+i*4+2)
                local y2 = memory.readbyte(0x4ac+i*4+3)
                --if (x1 > 0 and x1 < 255 and x2 > 0 and x2 < 255 and y1 > 0 and y1 < 224 and y2 > 0 and y2 < 224) then
                --if (x1 > 0 and x1 < 255 and x2 > 0 and x2 < 255 and y1 > 0 and y1 < 224 and y2 > 0 and y2 < 255) then
                    gui.drawbox(x1,y1,x2,y2,"clear", c)
                    spidey.outlineText(x1,y1, string.format("%02x",i), c,"white")
                --end
            end
        end
    end
    
    --if config.jetpack then jetpack.mainLoop() end
    
    if game.action and not smb.frozen() then
        for i,o in ipairs(obj) do
            if o.active then
                if o.x-game.scrollX >=0-16 and o.x-game.scrollX<=255+16 then
                    o.onScreen = true
                    o.initialOffScreen = false
                else
                    o.onScreen = false
                end
                o:update()
                if o.initialOffScreen == false and o.onScreen==false then
                    o:destroy()
                end
            end
        end
    end
    
    if game.paused and cheats.enabled then
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
    --for i,o in ipairs(obj) do
    for i = 1, #obj do
        local o = obj[i]
        
        if o.active and o.onScreen then
            gfx.draw(o.x-game.scrollX,o.y,o.image)
        end
    end
end

spidey.run()