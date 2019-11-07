local smb = {}

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

smb.action = function()
    return (memory.readbyte(0x07c6)==0x00)
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


function smb.getLocation()
    local world = memory.readbyte(0x75f)
    local level = memory.readbyte(0x75c)
    local area = memory.readbyte(0x760)
    local areaPointer = memory.readbyte(0x750)
    return world, level, area
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


return smb