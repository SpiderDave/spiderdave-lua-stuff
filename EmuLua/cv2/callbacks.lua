local callable=function(f)
    if type(f)~="function" then return true end
end

local getBank = function(address)
    local nBanks = 8
    local bankSize = 0x4000
    local a1 = address-address % bankSize
    local compare1 = ""
    for i=0, 0x10 do
        compare1=compare1..string.char(memory.readbyte(a1+i))
    end
    for bank=1,nBanks do
        local compare2=""
        for i=0, 0x10 do
            compare2=compare2..string.char(rom.readbyte(0x10+(bank*0x4000)+i))
        end
        if compare1==compare2 then
            return bank
        end
    end
end

local msgh = function(m)
    emu.message(m)
end

local registerExec = function(address, bank, len, fName)
    local f = function(address,len,func)
        --emu.message(_bank or "??")
        if bank and (bank~=getBank(address)) then return end
        if not bank then
            emu.message(string.format("function %s bank %d",fName, getBank(address)))
        end
        --emu.message(string.format("_bank=%s bank=%s getBank=%s",_bank or "-", bank or "-",getBank(address) or "-"))
        local a,x,y,s,p,pc=memory.getregisters()
        
        local f2=_G["_"..fName]
        
        if type(f2)=="function" then
            --emu.message(string.format("_bank=%s bank=%s getBank=%s",_bank or "-", bank or "-",getBank(address) or "-"))
            local t={}
            t.address=address
            t.len=len
            t.a=a
            t.x=x
            t.y=y
            t.s=s
            t.p=p
            t.pc=pc
            t.bank=bank
            
            --local e=string.format('Error in callback "%s"', fName)
            if not xpcall(function()
                local t2 = f2(address, len, t)
            end, msgh) then
                emu.message(string.format('Error in callback "%s"', fName))
            end
        end
        
        
    end
    memory.registerexec(address, len or 1, f)
end

-- Here we make the basic callbacks, with a few bells and whistles.
-- If the bank is set to nil, it will display the function name and
-- bank in a message.
registerExec(0x8757+2,3,1,"onWalkSpeedRight")
registerExec(0x8771+2,3,1,"onWalkSpeedLeft")
registerExec(0x877c+1,3,1,"onWalkStop")
registerExec(0x891c+2,3,1,"onJumpSpeedRight")
registerExec(0x8911+2,3,1,"onJumpSpeedLeft")
registerExec(0xd33e,7,1,"onEnterSubScreen")
registerExec(0x80ec,1,1,"onCreateEnemy")
registerExec(0xde7b,7,1,"onCreateEnemyProjectile")
registerExec(0xc5a1,7,1,"onStartGame")
registerExec(0xc521,7,1,"onRestartGame")
registerExec(0xcc77,7,1,"onPrintLives")
registerExec(0xd4f7,7,1,"onExpGain")
registerExec(0xdc31,7,1,"onSetWhipFrameDelay")
registerExec(0x88ef+2,3,1,"onSetJumpSpeedYPlatform")
registerExec(0x88f4+2,3,1,"onSetJumpSpeedY")
registerExec(0xe855+2,7,1,"onPlaceStageTile")
registerExec(0x896c+2,1,1,"onEnemyStun")
registerExec(0x875c,1,1,"onHeartPickup")
registerExec(0xd7ea,7,1,"onThrowWeapon")

registerExec(0xf24c,7,1,"onSetWeaponLeft")
registerExec(0xf295,7,1,"onSetWeaponRight")

registerExec(0x9096,1,1,"onGetRedCrystal")



-- Here we make better callbacks out of the callbacks.  It's callbacks all the way down!

-- onWalkSpeed(speed)
-- onWalkSpeedLeft(speed)
-- onWalkSpeedRight(speed)
-- onWalkStop()
-- onJumpSpeedLeft(speed)
-- onJumpSpeedRight(speed)
-- onJumpSpeed(speed)

function _onWalkSpeedRight(address,len,t)
    if type(onWalkSpeedRight)~="function" and type(onWalkSpeed)~="function" then return end
    
    local speed=1
    if type(onWalkSpeed)=="function" then
        speed = onWalkSpeed(speed) or speed
    end
    if type(onWalkSpeedRight)=="function" then
        speed = onWalkSpeedRight(speed) or speed
    end
    
    y,a = spidey.makeNesFloat(speed)
    memory.setregister("a",a)
    memory.setregister("y",y)
end

function _onWalkSpeedLeft(address,len,t)
    if type(onWalkSpeedLeft)~="function" and type(onWalkSpeed)~="function" then return end
    
    local speed=-1
    if type(onWalkSpeed)=="function" then
        speed = onWalkSpeed(speed) or speed
    end
    if type(onWalkSpeedLeft)=="function" then
        speed = onWalkSpeedLeft(speed) or speed
    end
    
    y,a = spidey.makeNesFloat(speed)
    memory.setregister("a",a)
    memory.setregister("y",y)
end

function _onJumpSpeedRight(address,len,t)
    if type(onJumpSpeedRight)~="function" and type(onJumpSpeed)~="function" then return end
    
    local speed=1
    if type(onJumpSpeed)=="function" then
        speed = onJumpSpeed(speed) or speed
    end
    if type(onJumpSpeedRight)=="function" then
        speed = onJumpSpeedRight(speed) or speed
    end
    
    y,a = spidey.makeNesFloat(speed)
    memory.setregister("a",a)
    memory.setregister("y",y)
end

function _onJumpSpeedLeft(address,len,t)
    if type(onJumpSpeedLeft)~="function" and type(onJumpSpeed)~="function" then return end
    
    local speed=-1
    if type(onJumpSpeed)=="function" then
        speed = onJumpSpeed(speed) or speed
    end
    if type(onJumpSpeedLeft)=="function" then
        speed = onJumpSpeedLeft(speed) or speed
    end
    
    y,a = spidey.makeNesFloat(speed)
    memory.setregister("a",a)
    memory.setregister("y",y)
end


function _onWalkStop(address,len,t)
    if type(onWalkStop)=="function" then onWalkStop() end
end

function _onEnterSubScreen(address,len,t)
    if type(onEnterSubScreen)=="function" then onEnterSubScreen() end
end


function _onCreateEnemy(address,len,t)
    if type(onCreateEnemy)=="function" then
        local a = onCreateEnemy(t.x-6, t.a)
        memory.setregister("a", a)
    end
end

function _onCreateEnemyProjectile(address,len,t)
    if type(onCreateEnemyProjectile)=="function" then
        local xPos=memory.readbyte(0x0348+6+t.y-6)
        local yPos=memory.readbyte(0x0324+6+t.y-6)

        local a = onCreateEnemyProjectile(t.x-6, t.a, xPos, yPos)
        if a then memory.setregister("a", a) end
    end
end

function _onStartGame(address,len,t)
    if type(onStartGame)=="function" then onStartGame() end
end

function _onRestartGame(address,len,t)
    if type(onRestartGame)=="function" then
        local a = onRestartGame()
        if a then memory.setregister("a", a) end
    end
end

function _onPrintLives(address,len,t)
    if type(onPrintLives)=="function" then
        local a = onPrintLives(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onExpGain(address,len,t)
    if type(ononExpGain)=="function" then
        local y = ononExpGain(t.y)
        if y then memory.setregister("y", y) end
    end
end

function _onSetWhipFrameDelay(address,len,t)
    if type(onSetWhipFrameDelay)=="function" then
        local whipState = memory.readbyte(0x0445)
        local a = onSetWhipFrameDelay(t.a, whipState)
        if a then memory.setregister("a", a) end
    end
end

function _onSetJumpSpeedYPlatform(address,len,t)
    if type(onSetJumpSpeedY)=="function" then
        local a = onSetJumpSpeedY(t.a, true)
        if a then memory.setregister("a", a) end
    end
end

function _onSetJumpSpeedY(address,len,t)
    if type(onSetJumpSpeedY)=="function" then
        local a = onSetJumpSpeedY(t.a, false)
        if a then memory.setregister("a", a) end
    end
end

-- note: will undo it if you sub screen or message over the block
function _onPlaceStageTile(address,len,t)
    if type(onPlaceStageTile)=="function" then
        local a = onPlaceStageTile(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onEnemyStun(address,len,t)
    if type(onEnemyStun)=="function" then
        local a = onEnemyStun(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onHeartPickup(address,len,t)
    if type(onHeartPickup)=="function" then
        local a = onHeartPickup(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onThrowWeapon(address,len,t)
    if type(onThrowWeapon)=="function" then
        local weaponType=memory.readbyte(0x03ba+t.y-6)
        
        local weaponType, abort = onThrowWeapon(weaponType, t.a)
        if abort then
            memory.setregister("a",0)
            memory.writebyte(0x40e,0)
        end
        
        if weaponType then
            memory.writebyte(0x03ba+t.y-6, weaponType)
        end
    end
end

function _onSetWeaponLeft(address,len,t)
    if type(onSetWeapon)=="function" then
        local y = onSetWeapon(t.y)
        if y then memory.setregister("y", y) end
    end
end

function _onSetWeaponRight(address,len,t)
    if type(onSetWeapon)=="function" then
        local y = onSetWeapon(t.y)
        if y then memory.setregister("y", y) end
    end
end

function _onGetRedCrystal(address,len,t)
    if type(onGetRedCrystal)=="function" then onGetRedCrystal() end
end
