-- SMB Lua script by SpiderDave

-- To Do / ideas / issues:
--
--   * wavy effect in water
--   * animated palette for podobo
--   * sound effect for correct path in castles
--   * animated water/lava
--   * name entry screen
--   * continue screen
--   * Store player status and star time on player when switching.
--   * Update font to use SMB's font.  use "?" from Kamikaze Mario DX+.
--   * Make jumping off enemies work for all enemies
--   * Add Kubiro's shoe.

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
smb.init{config=config, util=util} --pass a table to make some things available to smb library.

local Thing = require("smb.thing")
local obj = Thing.holder

local blocks = require("smb.blocks")

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
gfx.bigBill = gfx.load("bigBill")
gfx.customBlock = gfx.load("customBlock")
gfx.cursor = gfx.load("cursor")

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
    convert("bigBill")
    convert("customBlock")
    convert("cursor")
    spidey.message("conversion finished")
end

game = {
    player={}
}
local player=game.player
game.paused = false

current_font=1
--current_font=6

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

mnu.cursor_image=gfx.cursor.image
if type(mnu.cursor_image)=="userdata" then
    mnu.cursor_image = mnu.cursor_image:gdStr()
end


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
            --return string.format("tile %02x", game.tile)
            return string.format("font %02x", current_font)
        end,

        left = function()
            --game.tile=math.max(0, game.tile-1)
            current_font = math.max(0, current_font-1)
            mnu.font=font[current_font]
        end,
        
        right = function()
            --game.tile=math.min(255, game.tile+1)
            current_font = math.min(255, current_font+1)
            mnu.font=font[current_font]

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

function onLoadState(n)
    --if n then emu.pause() end
    game.continueMode = false
    --spidey.message("State %d loaded!",n)
end

function onSaveState()
end

function onSetPlayerStatusAfterInjury(s)
    if config.demoteToBig then
        local playerStatus = memory.readbyte(0x0756)
        if playerStatus>1 then
            memory.writebyte(0x0756, 1) -- playerStatus
            return 1 -- demote to big
        end
    end
end


-- Triggered by getting hit or getting a power up only.
function onSetPlayerSize(s)
    local playerStatus = memory.readbyte(0x0756)
    
    -- Fixes for when demoteToBig is active
    if playerStatus == 0x01 and s == 0x01 then return 0 end
    if playerStatus == 0x02 and s == 0x01 then return 0 end
    
    return s
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
    --if PlayerStatus == 2 then emu.pause() end
    local pName = ((CurrentPlayer==0) and "Mario") or "Luigi"
    local configItem = pName.. (((PlayerStatus == 0x02) and "PaletteFiery") or "Palette" )
    
    if config[configItem] then
        local p = util.split(config[configItem],",")
        p[1] = tonumber(p[1])
        p[2] = tonumber(p[2])
        p[3] = tonumber(p[3])
        --spidey.message("%02x %02x %02x %s", p[1],p[2],p[3], configItem)
        
        if index>=1 and index<=3 then return p[index] end
    else
        --spidey.message("Not found: ".. configItem )
    end

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
    --n=0x61 -- 3d blocks
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
    
    local p = memory.readbyte(0x725) -- CurrentPageLoc
    local x = memory.readbyte(0x726) -- CurrentColumnPos
    local y = memory.readbyte(0x01)
    
    
    -- 0 2
    -- 1 3
    local tilePos = {
        [0] = {x=0,y=0},
        {x=0,y=1},
        {x=1,y=0},
        {x=1,y=1},
    }
    
    x=p*16*2+x*2+tilePos[index].x
    y=y*2+tilePos[index].y
    
    local m = {
        text = "HELLO WORLD!",
        x = 0x05,
        y = 0x0f,
    }
    m=nil -- disable
    
    if m and (y==m.y)then
        local t = smb.textMap(m.text)
        for i=1,#m.text do
            if x == m.x +i then
                a=t[i]
                memory.writebyte(0x03,0x50) -- attribute
            end
        end
    end
    
    -- add water
--    if a==0x24 then
--        if y==0x17 then a = 0x41 end
--        if y==0x18 then a = 0x26 end
--    end
    
    -- display page
    --if y==0 and x % 0x20 == 0 then return p end
    
    --if a==0x24 then a=0xc0 end
    
    --game.test=nil
--    if not game.test then
--        game.test = true
--        local chrPage = 1
--        local tile = 0xd0
        
--        for i=0,0x10-1 do
--            rom.writebyte(0x10+0x8000+chrPage*0x1000+tile*0x10+i,math.random(255))
--        end

    if false then
        -- modify background on the fly (must reload rom to fix)
        for i=0,0x10-1 do
            local n = rom.readbyte(0x10+0x8000+1*0x1000+0x47*0x10+i)
            
            if (i % 0x10) >=0x08 then
                rom.writebyte(0x10+0x8000+1*0x1000+0xd0*0x10+i,0xff)
            else
                rom.writebyte(0x10+0x8000+1*0x1000+0xd0*0x10+i,n)
            end
        end
        
        if a==0x24 then
            a = 0xd0
            --memory.writebyte(0x03,0x80) -- attribute
        end
    end
    
    --if  y==0x15 then a=0xc0 end
    --if (a>=0xb4 and a<=0xb7) and y==0x16 then a=0xc1 end
    --if (a>=0xb4 and a<=0xb7) and y==0x17 then a=0x24 end
    --if (a>=0xb4 and a<=0xb7) and y==0x18 then a=0x24 end
    
--    if x == 0x20+0x05 and y ==0x05 then a=0x11 end
--    if x == 0x20+0x06 and y ==0x05 then a=0x0e end
--    if x == 0x20+0x07 and y ==0x05 then a=0x15 end
--    if x == 0x20+0x08 and y ==0x05 then a=0x15 end
--    if x == 0x20+0x09 and y ==0x05 then a=0x18 end
    --a=0xce
    --a=p
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
    if config.stompJump then
        if memory.readbyte(0x1d) == 0x02 then
            -- if Player_State is falling, set to jumping
            memory.writebyte(0x1d, 0x01)
         end
        
        local n=0
        local xs = memory.readbyte(0x700) -- Player_XSpeedAbsolute
        if xs >= 0x09 then n=n+1 end
        if xs >= 0x10 then n=n+1 end
        if xs >= 0x19 then n=n+1 end
        if xs >= 0x1c then n=n+1 end
        
        memory.writebyte(0x70a,memory.readbyte(0xb42b + n)) --VerticalForceDown
        memory.writebyte(0x433,memory.readbyte(0xb439 + n)) --Player_Y_MoveForce
        memory.writebyte(0x9f,memory.readbyte(0xb432 + n)) --Player_Y_Speed
        memory.writebyte(0x709,memory.readbyte(0xb424 + n)-n*2-4) --VerticalForce
        
        local y = memory.readbyte(0xce) -- Player_Y_Position
        memory.writebyte(0x708, y) -- JumpOrigin_Y_Position
        
        -- refresh Player_Y_Speed
        return memory.readbyte(0x9f)
    end
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

function onSetPlayerGfxOffset(g)
    if config.LuigiJump and smb.currentPlayer() == 1 then
        if g==0x20 then
            -- Luigi shuffles feet during jump (big)
            g = (spidey.counter % 3) * 8
            return g
        elseif g==0x80 then
            -- Luigi shuffles feet during jump (small)
            g = (spidey.counter % 3) * 8 + 0x60
            return g
        end
    end
end

function onProcessPlayerState(s)
--    if config.LuigiJump and s==0x01 and smb.currentPlayer() == 1 then
--        local frame = spidey.counter % 3
--        memory.writebyte(0x70d, (frame+1) % 0x03)
--        return 0
--    end
end

function onGetFriction(friction, index)
    if config.LuigiFriction and smb.currentPlayer() == 1 then
        local LuigiFriction = {0xb4, 0x68, 0x50}
        return LuigiFriction[index]
    end
end

--function onSetPlayerAnimation(n)
--    spidey.message("%02x",n)
--    return 8
--end


-- if textNumber==0 it's top status bar
-- c is used for position (nametable address), length of text and characters
-- nametable address hi, nametable address lo, x-position, length of text, text characters, terminated by 0xff
-- 0x20, 0x43, 0x05, "MARIO", 0x20, 0x52, 0x0b, "WORLD  TIME", 0x20, 0x68, 0x05, "0  ", 0x2e (coin icon), "x",
function onPrintText(textNumber, c, index)
    if true then return end -- disable
    
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


function onCheckEnemyType(index, enemyType)
    -- Check for flagpole flag object
    if enemyType==0x30 then
        local x =memory.readbyte(0x6e+index)*0x100+ memory.readbyte(0x87+index)
        
        -- If the flagpole object is close to the left edge and player has
        -- control, lock the scroll.
        if game.scrollX > x -0x20 and smb.playerHasControl() then
            memory.writebyte(0x723, 0x01)
        end
    end
    
    return enemyType
end


--function onLoadEnemyData(e)
--    spidey.message("enemy %02x", e)
--    return e
--end


function onCheckScrollable(canScroll)
    --canScroll=true
    
    --if smb.getUnusedEnemyIndex()~=0 then canScroll = false end
    
    return canScroll
end

function onPlayerStandingOnMetaTile(tile)
    if config.bridgeConveyer then
        if tile==0x89 then
            local x,y = smb.getPlayerPosition()
            smb.setPlayerPosition(x-1)
        end
    end
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
    
    if game.doExplode then
        game.explode = (game.explode or .1) * 1.04
        for i = 0,0x40-1 do
            --if i>0  and i %2==0 then
            if i>1 then
                local a = 0x200+i*4-1
                local n = memory.readbyte(a)
                
                n = n + math.random(-game.explode,game.explode)
                n=math.max(n, 0)
                n=math.min(n, 255)
                memory.writebyte(a, n)

                a=a+1
                local n = memory.readbyte(a)
                n = n + math.random(-game.explode,game.explode)
                n=math.max(n, 0)
                n=math.min(n, 255)
                memory.writebyte(a, n)
            end
        end
    end
    
    
    if config.bridgeConveyer then
        local chrPage = 1
        for _,tileNum in ipairs({0x77,0x79}) do
            for i=0,0x10-1 do
                local n = rom.readbyte(0x10+0x8000+chrPage*0x1000+tileNum*0x10+i)
                n=n*2
                if n>0xff then n=n-0xff end
                rom.writebyte(0x10+0x8000+chrPage*0x1000+tileNum*0x10+i,n)
            end
        end
    end
    
    -- moving water/lava
    
    --if true then
    while game.lavaScroll ~= math.floor(game.scrollX/5) % 0x10 do
        local chrPage = 1
        local tileNum = 0x41
        for i=0,0x10-1 do
            local n = rom.readbyte(0x10+0x8000+chrPage*0x1000+tileNum*0x10+i)
            
            n=n*2
            if n>0xff then n=n-0xff end
            
            rom.writebyte(0x10+0x8000+chrPage*0x1000+tileNum*0x10+i,n)
        end
        game.lavaScroll = ((game.lavaScroll or 0)+1) % 0x10
    end
    
    -- rotate a lot of tiles, crazy!
    if false then
        local chrPage = 1
        if f % 2 ==0 then
            for tileNum = 0x40, 0xce do
                for i=0,0x10-1 do
                    --local tileNum = 0x41
                    local n = rom.readbyte(0x10+0x8000+chrPage*0x1000+tileNum*0x10+i)
                    
                    n=n*2
                    if n>0xff then n=n-0xff end
                    
                    rom.writebyte(0x10+0x8000+chrPage*0x1000+tileNum*0x10+i,n)
                end
            end
            
            chrPage=0
            for tileNum = 0x0, 0xfe do
                for i=0,0x10-1 do
                    local n = rom.readbyte(0x10+0x8000+chrPage*0x1000+tileNum*0x10+i)
                    
                    n=n*2
                    if n>0xff then n=n-0xff end
                    
                    rom.writebyte(0x10+0x8000+chrPage*0x1000+tileNum*0x10+i,n)
                end
            end

        end
    end
    
    
    
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

function onSetIntermediateSprite(x,y)
    if true then return end
    x=0xc8
    --x=0xb0
    --y=y+3
    --y=0x20
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

function onImposeGravity(objectIndex, downwardForce)
    -- Mario
    if objectIndex == 0 then
        --return downwardForce/3
    end
    
    if config.LuigiJump then
        if objectIndex == 0 and smb.currentPlayer() == 1 then
            return downwardForce/1.4
        end
    end
    
    -- Enemies and objects
    if objectIndex > 0 then
        --return downwardForce/3
    end
end

function onVblank()
    if smb.updatePalette then
        smb.updatePalette= false
        
        local player = memory.readbyte(0x753)
        
        memory.readbyte(0x2007)
        
        memory.readbyte(0x2002)
        memory.writebyte(0x2006, 0x3f)
        memory.writebyte(0x2006, 0x11)

        if player==0 then
            memory.writebyte(0x2007, 0x16)
            memory.writebyte(0x2007, 0x27)
            memory.writebyte(0x2007, 0x18)
        else
            memory.writebyte(0x2007, 0x30)
            memory.writebyte(0x2007, 0x27)
            memory.writebyte(0x2007, 0x19)
        end
        
        memory.readbyte(0x2007)
    end
end

function onSetFirebarSpeed(s)
    --spidey.message(s)
    --s=s*8
    --s=0
    s=4
    
--    game.firebarSpeedMultiplier = 2
--    game.firebarAccel = game.firebarAccel or 1
--    game.firebarAccel = math.min(255,math.sin(spidey.counter*.05)*5)
--    game.firebarSpeed = (game.firebarSpeed or 20) + game.firebarSpeedMultiplier *game.firebarAccel

--    if game.firebarSpeed >=  255 then
--        game.firebarSpeed = 255
--        game.firebarAccel = -1
--    end
--    if game.firebarSpeed <=  0 then
--        game.firebarSpeed = 0
--        game.firebarAccel = 1
--    end
    s = math.random(0,100)
    --s=200
    --s = game.firebarSpeed
    
    return s
end

-- 0 = clockwise
-- 1 = counter-clockwise
function onSetFirebarSpinDirection(a)
    return a
end

function onSetFirebarLength(len)
    --len=len-2
    return len
end

function X_onSetFirebarPositions()
    local index = memory.readbyte(0)
    --n=math.floor(spidey.counter/4) % 9
--    if index==n or index==n+1 then
--        local n2=memory.readbyte(3)
--        n2=n2*2
--        memory.writebyte(0,10)
--        memory.writebyte(3,n2)
--    end
    
    local n1=memory.readbyte(1)
    local n2=memory.readbyte(2)
    local n3=memory.readbyte(3)

    --memory.writebyte(1,n1*1.9)
    --memory.writebyte(2,n2*.2)
    
    
    if index % 2==0 then
        memory.writebyte(1,255-n1)
    end
end

function onSpinyStompCheck()
    if config.stompSpiny then return false end
end

function onDemoteKoopa(oldEnemyType, newEnemyType)
    -- Don't demote spiny when stomping.
    if oldEnemyType == 0x12 then return oldEnemyType end
    return
end

function onSetKoopaStateAfterDemote(enemyType, state)
    -- kill spiny after demote
    if enemyType == 0x12 then
        return 0x20
    end
    
    return state
end

function onResetTitle()
end

function onSkipGameOverScreen(abort)
    -- abort skipping game over screen so continue screen works
    abort = true
    return abort
end

function onTitleMenuChange(menuIndex)
    --spidey.message("%02x", menuIndex)
    if config.menuSound then smb.playSound("TimerTick") end
end

function onCheckSoundMute(soundEnabled)
    if config.demoSound then return true end
end

function onCheckDisableIntermediate()
    return true
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
    game.operMode = memory.readbyte(0x770)
    
    smb.getObjectData() -- get data for player and enemies
    smb.getHitBoxes()   -- get hitbox data for player and enemies
    
    player.control = (memory.readbyte(0x0e)==0x08)
    player.isOnScreen = smb.playerOnScreen()
    player.state = memory.readbyte(0x1d)
    player.inAir = (player.state == 0x01 or player.state == 0x02)
    local ScreenEdge_X_Pos = memory.readbyte(0x71c)
    local ScreenEdge_PageLoc = memory.readbyte(0x71a)
    local scrollX = ScreenEdge_PageLoc *0x100 + ScreenEdge_X_Pos
    game.scrollX = scrollX
    game.ScreenEdge_X_Pos = ScreenEdge_X_Pos
    local mouseTileX = math.floor((inp.xmouse+ScreenEdge_X_Pos % 16)/16)
    local mouseTileY = math.floor(inp.ymouse/16)
    
    
--    if game.action then gui.text(50,50,"action") end
--    if game.frozen then gui.text(50,50+8*1,"frozen") end
--    if game.paused then gui.text(50,50+8*2,"paused") end
    
    -- game.location id is a string like "1-2 0225".
    local world, level, area, areaPointer = smb.getLocation()
    game.location = {world=world, level=level, area=area, areaPointer=areaPointer, id = string.format("%x-%x %02x%02x",world+1, level+1, area, areaPointer)}
    
    --gui.text(50,50, game.location.id)
    --gui.text(50,50+8, string.format("%02x %02x",mouseTileX,mouseTileY))
    
--    if cheats.active then
--        if cheats.hp then memory.writebyte(0x0065, 0x10) end
--        if cheats.lives then memory.writebyte(0x0076, 0x09) end
--    end
    
    if spidey.debug.enabled then
    end
    
    if game.action and config.ShowLivesInHud and game.operMode ~= 0x03 then
        local n = (smb.currentPlayer()==0 and "M") or "L"
        drawfont(8*11-1,8*2-1,font[5],string.format("%s %02d",n, math.min(99,memory.readbyte(0x075a))))
        gui.drawline(97,18,97+4,22,"white")
        gui.drawline(97+4,18,97,22,"white")
    end
    
    if config.continueScreen then
        if game.operMode == 0x03 then
            local screenTimer = memory.readbyte(0x7a0)
            
            if screenTimer==0x01 then
                screenTimer=0x02
                memory.writebyte(0x7a0,screenTimer)
                game.continueModeMenuY = game.continueModeMenuY or 0
                game.continueMode = true
                
            end
            if joy[1].A_press or joy[1].start_press then
                screenTimer=0x00
                memory.writebyte(0x7a0,screenTimer)
                
                if game.continueModeMenuY == 0 then
                    game.operMode = 0x01
                    memory.writebyte(0x770, game.operMode)
                    memory.writebyte(0x772, 0x03) --set OperMode_Task to GameMenuRoutine
                    
                    memory.writebyte(0x75a, 0x02)-- lives
                end
                
            end
            if game.continueMode and (joy[1].select_press or joy[1].up_press or joy[1].down_press) then
                game.continueModeMenuY = ((game.continueModeMenuY or 0) + 1) % 2
                smb.playSound("TimerTick")
            end
        else
            game.continueMode = false
            game.continueModeMenuY = nil
        end
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
    
    if player.control and player.inAir and config.airTurn then
        if joy[1].left then
            memory.writebyte(0x45,2) -- Player_MovingDir
            memory.writebyte(0x33,2) -- PlayerFacingDir
            --local xs = smb.intToNESByte
            local xs = NESByteToInt(memory.readbyte(0x57))
            if xs>0 then
                xs=xs-1
                memory.writebyte(0x57, smb.intToNESByte(xs))
            end
        end
        if joy[1].right then
            memory.writebyte(0x45,1) -- Player_MovingDir
            memory.writebyte(0x33,1) -- PlayerFacingDir
            local xs = NESByteToInt(memory.readbyte(0x57))
            if xs<0 then
                xs=xs+1
                memory.writebyte(0x57, smb.intToNESByte(xs))
            end
        end
    end
    
    if joy[1].B_press and config.fly then
--        memory.writebyte(0x70a,0) --VerticalForceDown
--        memory.writebyte(0x433,0) --Player_Y_MoveForce
--        memory.writebyte(0x9f,0) --Player_Y_Speed
--        memory.writebyte(0x709,0) --VerticalForce
        
--        memory.writebyte(0x705,0) -- Player_X_MoveForce
--        memory.writebyte(0x57,0) -- Player_X_Speed
        
        player.fly = not player.fly
    end
    
    if player.fly then
        memory.writebyte(0x70a,0) --VerticalForceDown
        memory.writebyte(0x433,0) --Player_Y_MoveForce
        memory.writebyte(0x9f,0) --Player_Y_Speed
        memory.writebyte(0x709,0) --VerticalForce
        
        memory.writebyte(0x705,0) -- Player_X_MoveForce
        memory.writebyte(0x57,0) -- Player_X_Speed
        
        memory.writebyte(0x400,0)
        --memory.writebyte(0x700,0) -- Player_XSpeedAbsolute

        local s = 40
        if joy[1].up then
            memory.writebyte(0x9f,0xff-1) --Player_Y_Speed
        end
        if joy[1].down then
            memory.writebyte(0x9f,2) --Player_Y_Speed
        end
        if joy[1].left then
            memory.writebyte(0x57,0xff-s) -- Player_X_Speed
            memory.writebyte(0x45,2) -- Player_MovingDir
            memory.writebyte(0x33,2) -- PlayerFacingDir
        end
        if joy[1].right then
            memory.writebyte(0x57,s) -- Player_X_Speed
            memory.writebyte(0x45,1) -- Player_MovingDir
            memory.writebyte(0x33,1) -- PlayerFacingDir
        end
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
    
    if joy[1].select_press and config.switchPlayer and game.action and smb.playerHasControl() then
        smb.switchPlayer()
    end
    
    if joy[1].select_press and config.explode and game.action then
        game.doExplode = not game.doExplode
        if not game.doExplode then game.explode = nil end
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

--        memory.writebyte(0xfe, 0x08) -- store #Sfx_Blast in Square2SoundQueue
--        local o=obj.add()
--        o.image = "bigBill"
--        o.x = game.scrollX+255+math.random(200)
--        o.y = math.random(200)
--        o.xs = -1.3
--        o.ai = {"movement"}
        
--        memory.readbyte(0x2002)
--        memory.writebyte(0x2006, 0x3f)
--        memory.writebyte(0x2006, 0x11)
        
--        memory.writebyte(0x2007, 0x30)
--        memory.writebyte(0x2007, 0x27)
--        memory.writebyte(0x2007, 0x19)
        

    end
    
    
    
    if inp.leftbutton and (mouseTileY>1) and config.leftButton == "block" then
        
        local b = blocks[config.blockType]
        
        game.changeBlock = {
            p = ScreenEdge_PageLoc,
            x=mouseTileX,
            y=mouseTileY,
            tile = b.tile,
        }
        
        local o=obj.add()
        --o.image = "brickTop"
        o.image = b.image
        o.x = game.scrollX + mouseTileX*16
        o.x = game.ScreenEdge_X_Pos + inp.xmouse
        o.x = game.scrollX + inp.xmouse
        o.y = inp.ymouse
        
        o.x = math.floor(o.x / 16)*16
        o.y = math.floor(o.y / 16)*16
    end
    
    if not smb.frozen() then
        player.shootTime = math.max(0,(player.shootTime or 0) -1)
        
        if joy[1].B_press and player.shootTime == 0 and smb.playerHasControl() and player.isOnScreen and config.weapon=="thing" then
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
            
            local hb = smb.hitBoxes[i]
            
            if hb.active then
                gui.drawbox(hb.rect[1], hb.rect[2],hb.rect[3], hb.rect[4],"clear", hb.color)
                spidey.outlineText(hb.rect[1], hb.rect[2], string.format("%02x",i), hb.color,"white")
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
    
    if config.continueScreen then
        if game.continueMode then
            gui.drawbox(0,32,spidey.screenWidth-1,spidey.screenHeight-9,"black","black")
            drawfont(8*11-1,8*13-1,font[5],"CONTINUE")
            drawfont(8*(11+8)+1,8*13,font[6],"?")
            drawfont(8*14-1,8*15-1,font[5],"YES")
            drawfont(8*14-1,8*17-1,font[5],"NO")
            gfx.draw(8*12,8*(15+(game.continueModeMenuY or 0)*2)-1,gfx.cursor.image)
        end
    end
end

spidey.run()