local smb = {}

function smb.init(t)
    if type(t)=="table" then
        for k,v in pairs(t) do
            smb[k] = v
        end
    end
end

smb.constants = {}

-- Sfx constants, divided by sound queues
-- Square1, Square2, Noise
smb.constants.sfx = {
    {
        SmallJump         = 0x80,
        Flagpole          = 0x40,
        Fireball          = 0x20,
        PipeDown_Injury   = 0x10,
        EnemySmack        = 0x08,
        EnemyStomp        = 0x04,
        Bump              = 0x02,
        BigJump           = 0x01,
    },
    {
        BowserFall        = 0x80,
        ExtraLife         = 0x40,
        PowerUpGrab       = 0x20,
        TimerTick         = 0x10,
        Blast             = 0x08,
        GrowVine          = 0x04,
        GrowPowerUp       = 0x02,
        CoinGrab          = 0x01,
    },
    {
        BowserFlame       = 0x02,
        BrickShatter      = 0x01,
    }
}

smb.constants.music = {
    Ground=0x01,
    Water=0x02,
    Underground=0x04,
    Castle=0x08,
    Cloud=0x10,
    PipeIntro=0x20,
    Star=0x40,
    Silence=0x80,
}

smb.constants.eventMusic = {
    Death = 0x01,
    GameOver = 0x02,
    Victory = 0x04,
    EndOfCastle = 0x08,
    AltGameOver = 0x10,
    EndOfLevel = 0x20,
    TimeRunningOut = 0x40,
    Silence=0x80,
}

smb.constants.gameRoutines = {
    Entrance_GameTimerSetup=0,
    Vine_AutoClimb=1,
    SideExitPipeEntry=2,
    VerticalPipeEntry=3,
    FlagpoleSlide=4,
    PlayerEndLevel=5,
    PlayerLoseLife=6,
    PlayerEntrance=7,
    PlayerCtrlRoutine=8,
    PlayerChangeSize=9,
    PlayerInjuryBlink=0x0a,
    PlayerDeath=0x0b,
    PlayerFireFlower=0x0c,
}

smb.constants.metaTiles = {
    [0]={
        [0]="blank",
        "black metatile",
        "bush left",
        "bush middle",
        "bush right",
        "mountain left",
        "mountain left bottom/middle center",
        "mountain middle top",
        "mountain right",
        "mountain right bottom",
        "mountain middle bottom",
        "bridge guardrail",
        "chain",
        "tall tree top, top half",
        "short tree top",
        "tall tree top, bottom half",
        "warp pipe end left, points up",
        "warp pipe end right, points up",
        "decoration pipe end left, points up",
        "decoration pipe end right, points up",
        "pipe shaft left",
        "pipe shaft right",
        "tree ledge left edge",
        "tree ledge middle",
        "tree ledge right edge",
        "mushroom left edge",
        "mushroom middle",
        "mushroom right edge",
        "sideways pipe end top",
        "sideways pipe shaft top",
        "sideways pipe joint top",
        "sideways pipe end bottom",
        "sideways pipe shaft bottom",
        "sideways pipe joint bottom",
        "seaplant",
        "blank, used on bricks or blocks that are hit",
        "flagpole ball",
        "flagpole shaft",
        "blank, used in conjunction with vines",
    },
    {
        [0]="vertical rope",
        "horizontal rope",
        "left pulley",
        "right pulley",
        "blank used for balance rope",
        "castle top",
        "castle window left",
        "castle brick wall",
        "castle window right",
        "castle top w/ brick",
        "entrance top",
        "entrance bottom",
        "green ledge stump",
        "fence",
        "tree trunk",
        "mushroom stump top",
        "mushroom stump bottom",
        "breakable brick w/ line ",
        "breakable brick ",
        "breakable brick (not used)",
        "cracked rock terrain",
        "brick with line (power-up)",
        "brick with line (vine)",
        "brick with line (star)",
        "brick with line (coins)",
        "brick with line (1-up)",
        "brick (power-up)",
        "brick (vine)",
        "brick (star)",
        "brick (coins)",
        "brick (1-up)",
        "hidden block (1 coin)",
        "hidden block (1-up)",
        "solid block (3-d block)",
        "solid block (white wall)",
        "bridge",
        "bullet bill cannon barrel",
        "bullet bill cannon top",
        "bullet bill cannon bottom",
        "blank used for jumpspring",
        "half brick used for jumpspring",
        "solid block (water level, green rock)",
        "half brick (???)",
        "water pipe top",
        "water pipe bottom",
        "flag ball (residual object)",
    },
    {
        [0]="cloud left",
        "cloud middle",
        "cloud right",
        "cloud bottom left",
        "cloud bottom middle",
        "cloud bottom right",
        "water/lava top",
        "water/lava",
        "cloud level terrain",
        "bowser's bridge",
    },
    {
        [0]="question block (coin)",
        "question block (power-up)",
        "coin",
        "underwater coin",
        "empty block",
        "axe",
    }
}

function smb.NESByteToInt(n)
    if n>=0x80 then
        return -(0x100-n)
    else
        return n
    end
end

function smb.intToNESByte(n)
    if n<0 then
        return n+0x100
    else
        return n
    end
end

function smb.currentPlayer()
    return memory.readbyte(0x0753)
end

function smb.setPlayerSize()
    -- check player status
    if memory.readbyte(0x0756)==0x00 then
        memory.writebyte(0x754,1) -- set PlayerSize to 0x01 (small)
    else
        memory.writebyte(0x754,0) -- set PlayerSize to 0x00 (big)
    end
end

smb.playerHasControl = function()
    -- game routine must be "PlayerCtrlRoutine"
    if memory.readbyte(0x0e)~=0x08 then return end
    
    -- must be unpaused
    if smb.paused() then return end
    
    -- OperMode must be "GameMode"
    if memory.readbyte(0x770)~=0x01 then return end
    
    -- Must not be in a hole.
    if smb.playerInHole() then return end
    
    return true
end

smb.playerOnScreen = function()
    -- Player_OffscreenBits will return a value just in case you want
    -- to find out if the player is partially offscreen.  
    local Player_OffscreenBits = memory.readbyte(0x3d0)
    local isOnScreen = true
    if Player_OffscreenBits == 0xf0 then isOnScreen = false end
    
    return isOnScreen, Player_OffscreenBits
end

smb.playerInHole = function()
    -- check Player_Y_HighPos to see if the player is in a hole (death or cloud level exit)
    if memory.readbyte(0xb5) >= 0x02 then return true end
end

-- returns true if the game is not during a loading or intermediate screen
smb.action = function()
    --return (memory.readbyte(0x07c6)==0x00)
    return (memory.readbyte(0x0e)~=0x00)
end

function smb.frozen()
    if smb.paused() then return true end
    
    -- game routine must be "PlayerCtrlRoutine"
    if memory.readbyte(0x0e)~=0x08 then return true end

    -- OperMode must be "TitleScreenMode", "GameMode", or "VictoryMode".
    if memory.readbyte(0x770)>=0x03 then return true end

    return
end

function smb.paused()
     local GamePauseStatus = memory.readbyte(0x0776)
     if GamePauseStatus == 0x01 then return true end
     if GamePauseStatus == 0x81 then return true end
end

function smb.unpause()
    memory.writebyte(0x0776,0) -- GamePauseStatus
    memory.writebyte(0x07c6,0) -- PauseModeFlag
end

function smb.setPlayerSpeed(xs,ys)
    if xs then memory.writebyte(0x57, smb.intToNESByte(xs)) end
    if ys then memory.writebyte(0x9f, smb.intToNESByte(ys)) end
end

function smb.getPlayerSpeed()
    local xs = smb.NESByteToInt(memory.readbyte(0x57))
    local ys = smb.NESByteToInt(memory.readbyte(0x9f))
    return xs,ys
end

function smb.setPlayerMoveForce(x,y)
    if x then memory.writebyte(0x705, smb.intToNESByte(x)) end
    if y then memory.writebyte(0x433, smb.intToNESByte(y)) end
end

function smb.getPlayerMoveForce()
    local x = smb.NESByteToInt(memory.readbyte(0x705))
    local y = smb.NESByteToInt(memory.readbyte(0x433))
    return x,y
end

function smb.getScroll()
    local ScreenEdge_X_Pos = memory.readbyte(0x71c)
    local ScreenEdge_PageLoc = memory.readbyte(0x71a)
    local scrollX = ScreenEdge_PageLoc *0x100 + ScreenEdge_X_Pos
    return scrollX
end

function smb.playerIsStanding()
    -- check for standing frame big and small
    local f = memory.readbyte(0x6d5)
    if f==0xc8 or f==0xb8 then return true end
    return false
end

function smb.getPlayerPosition()
--    local ScreenEdge_X_Pos = memory.readbyte(0x71c)
--    local ScreenEdge_PageLoc = memory.readbyte(0x71a)
--    local scrollX = ScreenEdge_PageLoc *0x100 + ScreenEdge_X_Pos

    local playerX = memory.readbyte(0x86)
    local playerY = memory.readbyte(0xce)
    local Player_PageLoc = memory.readbyte(0x6d)
    local Player_X_Scroll = memory.readbyte(0x6ff)
    
    local Player_Y_HighPos = memory.readbyte(0xb5)
    
    --local px = Player_PageLoc*0x100+playerX-scrollX
    local px = Player_PageLoc*0x100+playerX
    local py = playerY + Player_Y_HighPos*0x100 - 0x100
    --gui.text(px,py, "*", "red","clear" )
    --spidey.message("%02x %02x",px,py)
    
    
    return px,py
end

function smb.setPlayerPosition(px,py)
    if px then
        memory.writebyte(0x6d, math.floor(px / 0x100)) -- Player_PageLoc
        memory.writebyte(0x86, px % 0x100) -- playerX
    end
    if py then
        memory.writebyte(0xb5, math.floor(py / 0x100)) -- Player_Y_HighPos
        memory.writebyte(0xce, py % 0x100) -- playerY
    end
    
end

function smb.getUnusedEnemyIndex()
    for i=0,4 do
        local e = memory.readbyte(0x0f+i) -- Enemy_Flag
        if e==0 then
            smb.deleteEnemy(i)
            return i
        end
    end
    return
end

function smb.deleteEnemy(i)
    memory.writebyte(0x0f+i, 0x00) -- Enemy_Flag
    memory.writebyte(0x16+i, 0x00) -- Enemy_ID
    memory.writebyte(0x1e+i, 0x00) -- Enemy_State
    memory.writebyte(0x0110+i, 0x00) -- FloateyNum_Control
    memory.writebyte(0x0796+i, 0x00) -- EnemyIntervalTimer
    memory.writebyte(0x0125+i, 0x00) -- ShellChainCounter
    memory.writebyte(0x3c5+i, 0x00) -- Enemy_SprAttrib
    memory.writebyte(0x078a+i, 0x00) -- EnemyFrameTimer
end

function smb.setEnemyPositionAndSpeed(i, x, y, ax, ay)
    local x1 = math.fmod(x, 0x100)
    local x2 = math.floor(x / 0x100)
    local y1 = math.fmod(y, 0x100)
    local y2 = math.floor(y / 0x100)
    local ax = math.max(-128, math.min(ax, 0x7F))
    local ay = math.max(-128, math.min(ay, 0x7F))

    memory.writebyte(0x006e + i, x2)
    memory.writebyte(0x0087 + i, x1)
    memory.writebyte(0x00b6 + i, y2)
    memory.writebyte(0x00cf + i, y1)
    memory.writebyte(0x0058 + i, ax)
    memory.writebyte(0x00a0 + i, ay)
    
    memory.writebyte(0x0401 + i, 0xfc) -- Enemy_X_MoveForce
    memory.writebyte(0x0434 + i, 0) -- Enemy_Y_MoveForce
end

function smb.setEnemySpeed(i, xs, ys)
    memory.writebyte(0x0057 + i, xs)
    memory.writebyte(0x009f + i, ys)
    
    memory.writebyte(0x0400 + i, 0xfc) -- Enemy_X_MoveForce
    memory.writebyte(0x0433 + i, 0) -- Enemy_Y_MoveForce
end


function smb.createEnemy(eType, x, y, xs, ys)
    eType = eType or 0x06 -- goomba
    local i
    if eType == 0x2e then -- power up
        i=05
        memory.writebyte(0x39, 0x00) -- PowerUpType
    else
        i = smb.getUnusedEnemyIndex()
    end
    if not i then return end
    
    smb.activateEnemy(i)
    
    memory.writebyte(0x16+i, eType) -- Enemy_ID
    --memory.writebyte(0x3c5+i, 0x05) -- Enemy_SprAttrib
    --memory.writebyte(0x49a+i, 0x03) -- Enemy_BoundBoxCtrl
    memory.writebyte(0x49a+i, 0x09) -- Enemy_BoundBoxCtrl
    
    if eType==0x12 then
        memory.writebyte(0x1e+i, 0x05) -- Enemy_State for spiny
    end
    
    local scroll = memory.readbyte(0x071a) * 0x100 + memory.readbyte(0x071c)
    x=x or math.random(250)
    y=y or 0x10
    xs=xs or 8
    ys=ys or 1
    
    smb.setEnemyPositionAndSpeed(i, scroll+x, 0x100 + y, xs,ys)
    
    smb.setFacing(i)
    return true
end

function smb.activateEnemy(i)
    memory.writebyte(0x0f+i, 0x01) -- Enemy_Flag
end

function smb.setFacing(i, facing)
    if not facing then
        -- auto
        local ax = smb.NESByteToInt(memory.readbyte(0x0058 + i))
        if ax > 0 then
            facing = 1
        elseif ax < 0 then
            facing = 2
        elseif ax==0 then
            facing = memory.readbyte(0x0046 + i)
        end
    end
    memory.writebyte(0x0046 + i, facing)
    return facing
end


function smb.getFacing(i, returnMultiplier)
    local facing = memory.readbyte(0x33 + i)
    if returnMultiplier then
        if facing == 2 then return -1 else return 1 end
    else
        return facing
    end
end


function smb.getLocation()
    local world = memory.readbyte(0x75f)
    local level = memory.readbyte(0x75c)
    local area = memory.readbyte(0x760)
    local areaPointer = memory.readbyte(0x750)
    return world, level, area, areaPointer
end

-- uses 0 based world and level
function smb.setLocation(world, level, area, areaPointer)
    if world then memory.writebyte(0x75f, world) end
    if level then memory.writebyte(0x75c, level) end
    
    memory.writebyte(0x760, area or 0)
    
    if world and level and area and (not areaPointer) then
        areaPointer = memory.readbyte(0x9cbc + memory.readbyte(0x9cb4+world)+area)
    end
    
    if areaPointer then memory.writebyte(0x750, areaPointer) end
end

-- uses 1 based world and level
function smb.warp(world, level, area, areaPointer)
    smb.unpause()
    
    memory.writebyte(0x770,1) -- OperMode
    memory.writebyte(0x772,0) -- OperMode_Task
    memory.writebyte(0x769,1) -- DisableIntermediate
    
    local l = smb.getAreaAddrOffsets()
    
    smb.setLocation(world-1, level-1, l[world-1][level-1])
    
    -- disable some (most likely) residual code that prevents 
    -- disabling intermediate lives display on castle levels.
    rom.writebyte(0x10+0x6bb,0xea)
    rom.writebyte(0x10+0x6bc,0xea)
end

function smb.getAreaAddrOffsets()
    local l = {}
    for world = 0, 7 do
        local level = 0
        for area = 0, 4 do -- here we assume there are 4 or 5 areas per world (some have pipe intro areas)
            l[world] = l[world] or {}
            areaPointer = memory.readbyte(0x9cbc + memory.readbyte(0x9cb4+world)+area)
            l[world][level] = area
            level=level+1
            if areaPointer == 0x29 then
                level=level-1
            end
        end
    end
    return l
end

function smb.getHitBoxes()
    local hb = {}
    for i = 0, 17 do
        hb[i]={}
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
        
        hb[i].pageLoc = memory.readbyte(0x6d+i)
        hb.active = false
        
        if show then
            local y = memory.readbyte(0xb5+i)*0x100+memory.readbyte(0xce+i)
            
            local x1 = memory.readbyte(0x4ac+i*4)
            local y1 = memory.readbyte(0x4ac+i*4+1)
            local x2 = memory.readbyte(0x4ac+i*4+2)
            local y2 = memory.readbyte(0x4ac+i*4+3)
            
            
            if y-y1<0 then y1=0 end
            
            --if i==0 then spidey.message("%d %d",y-0x100,y1) end
            
            hb[i].active = true
            hb[i].rect = {x1,y1,x2,y2}
            hb[i].color = c
            
            if y-y2<0 then hb[i].active = false end
            
            -- not sure if this is exactly right
            if y>0x100+ 224 then hb[i].active = false end
        end
    end
    smb.hitBoxes = hb
    return hb
end

function smb.switchPlayer()
    local nPlayers = memory.readbyte(0x77a)+1
    if nPlayers == 1 then return end
    
    local playerStatus = memory.readbyte(0x756)
    
    --player = memory.readbyte(0x753)
    local player = memory.readbyte(0x753)
    player = 1 - player
    memory.writebyte(0x753, player)

    memory.readbyte(0x2002)
    memory.writebyte(0x2006, 0x3f)
    memory.writebyte(0x2006, 0x11)
    
    --smb.updatePalette = true
    
    playerNames = {
        [0]={0x16, 0x0a, 0x1b, 0x12, 0x18},
        {0x15,0x1e,0x12,0x10,0x12},
    }
    
    
    local pName, configItem, p
    
    -- Here we access util and config through smb.util and smb.config
    if smb.config then
        pName = ((player==0) and "Mario") or "Luigi"
        configItem = pName.. (((playerStatus == 0x02) and "PaletteFiery") or "Palette" )
        if smb.config[configItem] then
            p = smb.util.split(smb.config[configItem],",")
            p[1] = tonumber(p[1])
            p[2] = tonumber(p[2])
            p[3] = tonumber(p[3])
            memory.writebyte(0x2007, p[1])
            memory.writebyte(0x2007, p[2])
            memory.writebyte(0x2007, p[3])
        end
    end
    
--    if player==0 then
--        memory.writebyte(0x2007, 0x16)
--        memory.writebyte(0x2007, 0x27)
--        memory.writebyte(0x2007, 0x18)
--    else
--        memory.writebyte(0x2007, 0x30)
--        memory.writebyte(0x2007, 0x27)
--        memory.writebyte(0x2007, 0x19)
--    end
    
    memory.readbyte(0x2002)
    
    memory.writebyte(0x2006, 0x20)
    memory.writebyte(0x2006, 0x43)
    
    for _,v in ipairs(playerNames[player]) do
        memory.writebyte(0x2007, v)
    end
    
    for i=0,6 do
        local a = memory.readbyte(0x075a+i)
        local b = memory.readbyte(0x0761+i)
        memory.writebyte(0x075a+i, b)
        memory.writebyte(0x0761+i, a)
    end
    
    local nCoins = memory.readbyte(0x75e)
    memory.readbyte(0x2002)
    
    memory.writebyte(0x2006, 0x20)
    memory.writebyte(0x2006, 0x6d)
    
    memory.writebyte(0x2007, math.floor(nCoins/10))
    memory.writebyte(0x2007, nCoins % 10)
    
    
    memory.readbyte(0x2002)
    
    memory.writebyte(0x2006, 0x28)
    memory.writebyte(0x2006, 0x62)
    
    for i=0,5 do
        local n = memory.readbyte(0x7dd+i+player*6)
        if i==0 and n==0 then
            n=0x24
        end
        memory.writebyte(0x2007, n)
    end
    
    return player
end

function smb.getObjectData()
    local o = {}
    for i=0,17 do
        o[i] = {}
        o[i].y = memory.readbyte(0xb5+i)*0x100+memory.readbyte(0xce+i)
        o[i].x = memory.readbyte(0x6e+i)*0x100+memory.readbyte(0x86+i)
        o[i].id = memory.readbyte(0x15+i)
        o[i].movingDir = memory.readbyte(0x45+i)
    end
    o.player = o[0]
    smb.objects = o
    return o
end

function smb.playSound(n)
    local soundQueues = {0xff,0xfe,0xfd}
    for q,v in pairs(smb.constants.sfx) do
        for k,v in pairs(v) do
            if k==n then
                memory.writebyte(soundQueues[q], v)
                return true
            end
        end
    end
    return false
end


function smb.textMap(s)
    local ret = {}
    for i = 1, #s do
        --local c = str:sub(i,i)
        local c = s:byte(i)
        if c >= 0x41 and c <=0x5a then
            -- A-Z
            n = c-0x41+0x0a
        elseif c >= 0x30 and c <=0x39 then
            -- 0-9
            n = c-0x41
        elseif string.char(c) == "-" then
            n = 0x28
        elseif string.char(c) == "x" then
            n = 0x29
        elseif string.char(c) == "!" then
            n = 0x2b
        elseif string.char(c) == "." then
            n = 0xaf
        else
            -- space
            n = 0x24
        end
        ret[i] = n
    end
    return ret
end

function smb.getMetaTileName(t)
    local tileP = 0
    if t >=0x80 then
        t= t-0x80
        tileP = tileP + 2
    end
    if t >=0x40 then
        t= t-0x40
        tileP = tileP + 1
    end
    return smb.constants.metaTiles[tileP][t] or "unknown", tileP, t
end


function smb.makeMessage(txt)
    local out=""
    for i = 1, (#txt) do
        local b = string.byte(txt:sub(i,i))
        
        c=0
        if b >=0x41 and b<=0x5a then
            c=b-0x41+0x0a
        elseif b >=0x0 and b<=0x9 then
            c=b+0x60
        elseif b ==0x2d then
            c=0x28
        elseif b ==0x2e then
            c=0xaf
        elseif b ==0x20 then
            c=0x24
        elseif b == 0X21 then
            c=0x2B
        elseif b >=0x30 and b<=0x39 then
            c=b-0x30
        end
        
        out=out..string.char(c)
    end
    
    return out
end

function smb.getNumberOfPlayers()
    return memory.readbyte(0x77a)+1
end

function smb.setNumberOfPlayers(n)
    if n==1 or n== 2 then
        memory.writebyte(0x77a,n-1)
    end
end

function smb.setInjuryTimer(n)
    memory.writebyte(0x79e, n or 0x08)
end

function smb.getButtons(n)
    local buttonNames = {
        [0]="right",
        "left",
        "down",
        "up",
        "start",
        "select",
    }
    local b = {}
    for i=0,5 do
        if n == bit.bor(n, 2^i) then
            b[buttonNames[i]]=true
        else
            b[buttonNames[i]]=false
        end
    end
    return b
end

function smb.demoRunning()
    return (memory.readbyte(0x7a2)==0)
end

function smb.drawRivetedBox(x,y,w,h, o)
    local o = o or {}
    
    local mainColor = o.mainColor or "P17"
    local lightColor = o.lightColor or "P36"
    local darkColor = o.darkColor or "P0F"
    
    gui.drawbox(x-1,y-1, x+w,y+h,"clear",lightColor)
    gui.drawbox(x,y, x+w+1,y+h+1,"clear",darkColor)
    
    -- main window
    gui.drawbox(x,y, x+w,y+h,mainColor,mainColor)
    
    -- upper left rivet
    gui.drawbox(x+2+1,y+2+1, x+2+1+1,y+2+1+1,darkColor,darkColor)
    gui.drawbox(x+2,y+2, x+2+1,y+2+1,lightColor,lightColor)
    -- lower left rivet
    gui.drawbox(x+2+1,y+h-4+2, x+2+1+1,y+h-4+2+1,darkColor,darkColor)
    gui.drawbox(x+2,y+h-5+2, x+2+1,y+h-5+2+1,lightColor,lightColor)
    -- upper right rivet
    gui.drawbox(x+w-3+1,y+2+1, x+w-3+1+1,y+2+1+1,darkColor,darkColor)
    gui.drawbox(x+w-3,y+2, x+w-3+1,y+2+1,lightColor,lightColor)
    -- lower right rivet
    gui.drawbox(x+w-3+1,y+h-4+2, x+w-3+1+1,y+h-4+2+1,darkColor,darkColor)
    gui.drawbox(x+w-3,y+h-5+2, x+w-3+1,y+h-5+2+1,lightColor,lightColor)
end

return smb