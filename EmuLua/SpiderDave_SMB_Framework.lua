-- SMB Lua script by SpiderDave

-- Load the Spidey library with all the bells and whistles.
spidey=require "Spidey.SpideyStuff"

-- Default font used in Spidey menu.
local font=require "Spidey.default_font"

-- Utilities.
local util = require "Spidey.util"

-- Config file loading.  This will also hold the loaded values.
local config = util.config

-- The smb library.
local smb = require("smb.smb")

-- smb specific callback functions.
require("smb.callbacks")


game = {}
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


config.load("smb/config.default.txt")
config.load("smb/config.txt")


-- needs work
--function onSquare1SfxHandler(sfx)
--    emu.message(sfx)
--    if sfx==32 then sfx=0 end
--    return sfx
--end

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

function _onSetPlayerPalette(CurrentPlayer, PlayerStatus, index, c)
    if index==1 or index==3 then
        if CurrentPlayer==0 then
            return c-3
        else
            return c+5
        end
    end
end


function _onLoadBackgroundMetatile(n)
    --if n==3 then n=0 end
    --if n==2 then n=85 end
    --n=0x0a
    n=game.tile
--    n=n+1
    return n
end

function _onLoadForegroundMetatile(n)
--    if n==84 then
--        if math.random(0,1)==1 then
--            n=85
--        end
--    end
    
    if n==84 then
        n=0x61
    elseif n==0x61 then
        n=84
    end
    n=0x61
    
    return n
end

-- 01 Ground
-- 02 Water
-- 04 Underground
-- 08 Castle
-- 10 Cloud
-- 20 Pipe Intro
-- 40 Star
-- 80 Silence
function onMusic(music)
    if config.music == false then
        -- we use 0x80 here to play "silence".  If 0 is used, 
        -- most music would be gone, but the star music would
        -- play forever.
        music = 0x80
    end
    --spidey.message("%02x",music)
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
function _onPrintText(textNumber, c, index)
    local a,x,y,s,p,pc=spidey.getregisters()
    --if c==0xff then return c end
    
    if textNumber==0 then
        if index==0x00 then c = 0x20 end
        if index==0x01 then c = 0x6b end
        if index==0x02 then c=  0x01 end
        if index==0x03 then c=  0x2e end
        if index==0x04 then c=  0xff end
    else
        c=0xff
    end
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



emu.registerexit(function(x) emu.message("") end)
function spidey.update(inp,joy)
    lastinp=inp
    
    if smb.paused() then
        if not game.paused then
            game.world, game.level = smb.getLocation()
        end
    end
    
    game.paused=smb.paused()
    game.action=smb.action()
    
--    if cheats.active then
--        if cheats.hp then memory.writebyte(0x0065, 0x10) end
--        if cheats.lives then memory.writebyte(0x0076, 0x09) end
--    end
    
    if spidey.debug.enabled then
    end
    
    -- Float
    if joy[1].A and config.float then
        local xs, ys = smb.getPlayerSpeed()
        local xmf, ymf = smb.getPlayerMoveForce()
        if ys>-1 then
            ys=0
            ymf=0
            smb.setPlayerSpeed(xs, ys)
            smb.setPlayerMoveForce(xmf,ymf)
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
    
    if joy[1].select_press then
        --smb.createEnemy(0x07, 0x10, 0x10, 8, 1)
        --smb.createEnemy(0x08, 240,math.random(200), -1,0)
    end
    
    if joy[1].select_press then
        --smb.warp(2,2)
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
end

spidey.run()