--local xpcall = function(f)
--    f()
--    return true
--end

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
        local a,x,y,s,p,pc=spidey.getregisters()
        
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
                --emu.message(string.format('Executing callback "%s"', fName))
                
                --spidey.appendToFile("cv2/log.txt", string.format('Executing callback "%s"\n', fName))
                
                local t2 = f2(address, len, t)
                
            end, msgh) then
                emu.message(string.format('Error in callback "%s"', fName))
            end
        end
        
        
    end
    memory.registerexec(address, len or 1, f)
end


savestate.registerload(function()
    if type(onLoadState)=="function" then onLoadState() end
end)

savestate.registersave(function()
    if type(onSaveState)=="function" then onSaveState() end
end)

-- Here we make the basic callbacks, with a few bells and whistles.
-- If the bank is set to nil, it will display the function name and
-- bank in a message.
registerExec(0x8757+2,3,1,"onWalkSpeedRight")
registerExec(0x8771+2,3,1,"onWalkSpeedLeft")
registerExec(0x877c+1,3,1,"onWalkStop")
registerExec(0x891c+2,3,1,"onSetJumpSpeedRight")
registerExec(0x8911+2,3,1,"onSetJumpSpeedLeft")
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
registerExec(0xf24c+2,7,1,"onSetWeaponLeft")
registerExec(0xf295+2,7,1,"onSetWeaponRight")
registerExec(0x9096,1,1,"onGetRedCrystal")
registerExec(0x87c3,1,1,"onGetCross")
registerExec(0xaa3e,1,1,"onGetDiamond")
registerExec(0xd921+2,7,1,"onUseLaurel")
registerExec(0xa17e+2,4,1,"onCheckDaysForEnding")
registerExec(0xda69,7,1,"onSubWeaponBreak")
registerExec(0xd858,7,1,"onSubWeaponCost")
registerExec(0x817f,1,1,"onEnemyCreated")
registerExec(0xc2d0+2,7,1,"onContinueScreen")
registerExec(0x87a4+3,1,1,"onMessage")
registerExec(0x884f,1,1,"onSetPlayerFacingWhenHit")
registerExec(0xd37e,7,1,"onSetPlayerXVelocityWhenHit")
registerExec(0xd385,7,1,"onSetPlayerYVelocityWhenHit")
registerExec(0xd390+2,7,1,"onSetPlayerStateWhenHit")
registerExec(0xd388+2,7,1,"onSetPlayerFrameWhenHit")
registerExec(0xc552+2,7,1,"onSetStartingLives")
registerExec(0x883a,1,1,"onEnemyDamage")
registerExec(0xeea4+2,7,1,"onMessage2")
registerExec(0xeeb6-2,7,1,"onMessageWriteAddress")
registerExec(0x891e-1,1,1,"onWhipDamage")
registerExec(0xd86b,7,1,"onHeartCost")
registerExec(0xd888,7,1,"onDeductHeartCost1")
registerExec(0xd88c,7,1,"onDeductHeartCost2")
registerExec(0xc04b,7,1,"onVBlank")
registerExec(0x8941,3,1,"onWhipOrSubWeapon")
registerExec(0xae16,1,1,"onGetSilverKnife")
registerExec(0x934f,1,1,"onGetFreeLaurels")
registerExec(0xc84b+3,7,1,"onPrintTitleText")
registerExec(0x8948,1,1,"onEnemyDeath")
registerExec(0xd554+3,7,1,"onExpForLevel1")
registerExec(0xd55e+3,7,1,"onExpForLevel2")
registerExec(0x881c+3,1,1,"onSetPlayerLevelDataPointer")
registerExec(0x8821+3,1,1,"onSetPlayerLevelDataPointer")
registerExec(0x8c72+3,1,1,"onWhipCheckForFlameWhip")
registerExec(0x8331+2, 4,1,"onSetTitleScreenDisplayDuration")
registerExec(0x8360, 1,1,"onRelicCheckEye")
registerExec(0xd625, 7,1,"onRelicCheckNail")
registerExec(0xd3c4, 7,1,"onRelicCheckRib")
registerExec(0xadbe, nil,1,"onRelicCheckBlueCrystal")
registerExec(0xa78d+2, 1,1,"onRelicCheckBlueCrystal2")
registerExec(0xa799, 1,1,"onRelicCheckBlueCrystal3")
registerExec(0xa938, nil,1,"onRelicCheckRedCrystal")
registerExec(0x8600, 1,1,"onRelicCheckWhiteCrystal")
registerExec(0x9071+2, 1,1,"onRelicCheckWhiteCrystal2")
registerExec(0x86f2, 1,1,"onRelicCheckHeart")
registerExec(0xa8fe+2, 1,1,"onRelicCheckAll")
registerExec(0xf5e2, 7,1,"onWindowPrintChar")
registerExec(0x87c9,1,1,"onGetGoldenKnife")
registerExec(0x87cf,1,1,"onGetSacredFlame")



-- Here we make better callbacks out of the callbacks.  It's callbacks all the way down!

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

function _onSetJumpSpeedRight(address,len,t)
    if type(onSetJumpSpeedRight)~="function" and type(onSetJumpSpeedX)~="function" then return end
    
    local speed=1
    if type(onSetJumpSpeedX)=="function" then
        speed = onSetJumpSpeedX(speed) or speed
    end
    if type(onSetJumpSpeedRight)=="function" then
        speed = onSetJumpSpeedRight(speed) or speed
    end
    
    y,a = spidey.makeNesFloat(speed)
    memory.setregister("a",a)
    memory.setregister("y",y)
end

function _onSetJumpSpeedLeft(address,len,t)
    if type(onSetJumpSpeedLeft)~="function" and type(onSetJumpSpeedX)~="function" then return end
    
    local speed=-1
    if type(onSetJumpSpeedX)=="function" then
        speed = onSetJumpSpeedX(speed) or speed
    end
    if type(onSetJumpSpeedLeft)=="function" then
        speed = onSetJumpSpeedLeft(speed) or speed
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
        if a then
            memory.setregister("a", a)
            if a==0 then
                memory.writebyte(0x04c8+t.x-6, 0) -- hp
            end
        end
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
        
        local weaponType, abort = onThrowWeapon(weaponType, false)
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
        local y = onSetWeapon(t.y, "left")
        if y then memory.setregister("y", y) end
    end
end

function _onSetWeaponRight(address,len,t)
    if type(onSetWeapon)=="function" then
        local y = onSetWeapon(t.y, "right")
        if y then memory.setregister("y", y) end
    end
end

function _onGetRedCrystal(address,len,t)
    if type(onGetRedCrystal)=="function" then onGetRedCrystal() end
end

function _onGetCross(address,len,t)
    if type(onGetCross)=="function" then onGetCross() end
end

function _onGetDiamond(address,len,t)
    if type(onGetDiamond)=="function" then onGetDiamond() end
end

function _onUseLaurel(address,len,t)
    if type(onUseLaurel)=="function" then
        local n = memory.readbyte(0x4c)
        local n2 = onUseLaurel(n)
        if n2 then memory.writebyte(0x4c, n2) end
    end
end

function _onCheckDaysForEnding(address,len,t)
    if type(onEnding)=="function" then
        local n
        if t.a<8 then
            n=3
        elseif t.a<20 then
            n=2
        else
            n=1
        end
        
        local endingNum = onEnding(n)
        if endingNum then
            if endingNum == 1 then
                a = 21
            elseif endingNum == 2 then
                a = 9
            elseif endingNum == 3 then
                a = 0
            end
            memory.setregister("a", a)
        end
    end
end

function _onSubWeaponBreak(address,len,t)
    if type(onSubWeaponBreak)=="function" then
        local currentWeapon=memory.readbyte(0x03b7+t.x-3)
        local a = onSubWeaponBreak(currentWeapon, t.x-3)
        if a then memory.setregister("a", a) end
    end
end

function _onSubWeaponcost(address,len,t)
    if type(onSubWeaponcost)=="function" then
        local a = onSubWeaponcost(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onEnemyCreated(address,len,t)
    if type(onEnemyCreated)=="function" then
        local enemyType = memory.readbyte(0x03ba+t.x-6)
        local enemyX=memory.readbyte(0x0348+6+t.x-6)
        local enemyY=memory.readbyte(0x0324+6+t.x-6)

        onEnemyCreated(t.x-6, enemyType, enemyX, enemyY)
        --if a then memory.setregister("a", a) end
    end
end

function _onContinueScreen(address,len,t)
    if type(onContinueScreen)=="function" then onContinueScreen() end
end

-- note, cancel only works for automatic messages
function _onMessage(address,len,t)
    if type(onMessage)=="function" then
        local messageNum, cancel = onMessage(t.a, false)
        if messageNum then
            memory.setregister("a",messageNum)
        end
        if cancel then
            memory.writebyte(0x3f,0)
        end
    end
end

function _onMessage2(address,len,t)
    if type(onMessage2)=="function" then
        -- use the message counter thing to only run this once
        if memory.readbyte(0x7c)~=0 then return end

        if type(onMessage2) == "function" then onMessage2(t.a) end
    end
end

function _onMessageWriteAddress(address,len,t)
    if type(onMessageWriteAddress)=="function" then
        local address = memory.readbyte(0x01)*0x100+memory.readbyte(0x00)+t.y
        
        
        if type(onMessageWriteAddress) == "function" then
            local address2 = onMessageWriteAddress(address)
            if address2 and (address~= address2) then
                memory.writebyte(0x01, math.floor(address2 / 0x100))
                memory.writebyte(0x00, address2 % 0x100)
            end
        end
    end
end


function _onSetPlayerFacingWhenHit(address,len,t)
    if type(onSetPlayerFacingWhenHit)=="function" then
        local facing =memory.readbyte(0x0420)
        
        local y = onSetPlayerFacingWhenHit(t.y, facing)
        if y then memory.setregister("y", y) end
    end
end


function _onSetPlayerXVelocityWhenHit(address,len,t)
    if type(onSetPlayerVelocityWhenHit)=="function" then
        local v1, v2 = onSetPlayerVelocityWhenHit("x", t.y, t.a)
        if v1 and v2 then
            memory.setregister("y", v1)
            memory.setregister("a", v2)
        elseif v1 then
            local v = tonumber(string.sub(string.format("%02x",v1), -2),16)
            memory.setregister("y", v)
            memory.setregister("a", 0)
        end
    end
end

function _onSetPlayerYVelocityWhenHit(address,len,t)
    if type(onSetPlayerVelocityWhenHit)=="function" then
        -- the order of arguments here is different.
        local v1, v2 = onSetPlayerVelocityWhenHit("y", t.a, t.y)
        if v1 and v2 then
            memory.setregister("y", v1)
            memory.setregister("a", v2)
        elseif v1 then
            local v = tonumber(string.sub(string.format("%02x",v1), -2),16)
            memory.setregister("y", 0)
            memory.setregister("a", v)
        end
    end
end

function _onSetPlayerStateWhenHit(address,len,t)
    if type(onSetPlayerStateWhenHit)=="function" then
        local oldState = memory.readbyte(0x3d8)
        local a = onSetPlayerStateWhenHit(t.a, oldState)
        if a then memory.setregister("a", a) end
    end
end

-- note, frame values dont' match.  the first one is more like an animation set
function _onSetPlayerFrameWhenHit(address,len,t)
    if type(onSetPlayerFrameWhenHit)=="function" then
        local frame = memory.readbyte(0x300)
        local a = onSetPlayerFrameWhenHit(t.a, frame)
        if a then memory.setregister("a", a) end
        --if a then memory.writebyte(0x300, a)         end
    end
end

function _onSetStartingLives(address,len,t)
    if type(onSetStartingLives)=="function" then
        local a = onSetStartingLives(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onEnemyDamage(address,len,t)
    if type(onEnemyDamage)=="function" then
        local enemyType=memory.readbyte(0x03ba+t.x-6)
        local a = onEnemyDamage(t.x-6, enemyType, t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onWhipDamage(address,len,t)
    if type(onWhipDamage)=="function" then
        local damage, target = onWhipDamage(memory.readbyte(0x0013), t.x-6)
        if damage then memory.writebyte(0x13,damage) end
    end
end

function _onHeartCost(address,len,t)
    if type(onHeartCost)=="function" then
        local cost = onHeartCost(tonumber(string.format("%02x%02x",memory.readbyte(0x05),memory.readbyte(0x09))))
        
        if cost then
            memory.writebyte(0x05, tonumber(string.sub(string.format("%04d",cost),1,2),16))
            memory.writebyte(0x09, tonumber(string.sub(string.format("%04d",cost),-2),16))
        end
    end
end


function _onDeductHeartCost1(address,len,t)
    if type(onDeductHeartCost1)=="function" then
        local oldHeartValue = tonumber(string.format("%02x",memory.readbyte(0x48)))
        local newHeartValue = tonumber(string.format("%02x",t.a))
        local h = onDeductHeartCost1(oldHeartValue, newHeartValue)
        if h then
            memory.setregister("a", tonumber(string.format("%02d",h),16))
        end
    end
end

function _onDeductHeartCost2(address,len,t)
    if type(onDeductHeartCost2)=="function" then
        local oldHeartValue = tonumber(string.format("%02x",memory.readbyte(0x49)))
        local newHeartValue = tonumber(string.format("%02x",t.a))
        local h = onDeductHeartCost2(oldHeartValue, newHeartValue)
        if h then
            memory.setregister("a", tonumber(string.format("%02d",h),16))
        end
    end
end

function _onVBlank(address,len,t)
    if type(onVBlank)=="function" then onVBlank() end
end

function _onWhipOrSubWeapon(address,len,t)
    if type(onWhipOrSubWeapon)=="function" then
        local oldIsSub = (t.p ~= bit.bor(t.p,0x02))
        local isSub = onWhipOrSubWeapon(oldIsSub)
        if isSub~=nil then
            if isSub then
                memory.setregister("p", bit.bor(t.p,0x02)-2)
            else
                memory.setregister("p", bit.bor(t.p,0x02))
            end
        end
    end
end

function _onGetSilverKnife(address,len,t)
    if type(onGetSilverKnife)=="function" then onGetSilverKnife() end
end

function _onGetFreeLaurels(address,len,t)
    if type(onGetFreeLaurels)=="function" then onGetFreeLaurels() end
end

function _onPrintTitleText(address,len,t)
    if type(onPrintTitleText)=="function" then
        local address = memory.readbyte(0x01)*0x100+memory.readbyte(0x00)
        local a = onPrintTitleText(t.a, address, t.y)
        if a then memory.setregister("a", a) end
    end
end

function _onEnemyDeath(address,len,t)
    if type(onEnemyDeath)=="function" then
        local enemyType = memory.readbyte(0x03b4+t.x)
        onEnemyDeath(enemyType)
    end
end

function _onExpForLevel1(address,len,t)
    if type(onExpForLevel1)=="function" then
        local a = onExpForLevel1(t.a)
        if a then memory.setregister("a", a) end
    end
end
function _onExpForLevel2(address,len,t)
    if type(onExpForLevel2)=="function" then
        local x = onExpForLevel2(t.x)
        if x then memory.setregister("x", x) end
    end
end

function _onSetPlayerLevelDataPointer(address,len,t)
    if type(onSetPlayerLevelDataPointer)=="function" then
        if address == 0x881c+3 then
            local a = onSetPlayerLevelDataPointer(t.a, nil)
            if a then memory.setregister("a", a) end
        else
            local a = onSetPlayerLevelDataPointer(nil, t.a)
            if a then memory.setregister("a", a) end
        end
    end
end

function _onWhipCheckForFlameWhip(address,len,t)
    if type(onWhipCheckForFlameWhip)=="function" then
        local a = onWhipCheckForFlameWhip(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onRelicCheckEye(address,len,t)
    if type(onRelicCheckEye)=="function" then
        local y = onRelicCheckEye(t.y)
        if y then memory.setregister("y", y) end
    end
end

function _onRelicCheckNail(address,len,t)
    if type(onRelicCheckNail)=="function" then
        local a = onRelicCheckNail(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onRelicCheckRib(address,len,t)
    if type(onRelicCheckRib)=="function" then
        local a = onRelicCheckRib(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onRelicCheckBlueCrystal(address,len,t)
    if type(onRelicCheckBlueCrystal)=="function" then
        local a = onRelicCheckBlueCrystal(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onRelicCheckBlueCrystal2(address,len,t)
    if type(onRelicCheckBlueCrystal2)=="function" then
        local a = onRelicCheckBlueCrystal2(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onRelicCheckBlueCrystal3(address,len,t)
    if type(onRelicCheckBlueCrystal3)=="function" then
        -- todo: pass current truth value and test
        local ret = onRelicCheckBlueCrystal3()
        
        -- need to check for nil specifically here
        if ret ~= nil then
            if ret==true then
                t.p = bit.bor(t.p, 0x02)
            else
                t.p = bit.bor(t.p, 0x02)-2
            end
            memory.setregister("p", t.p)
        end
    end
end

-- default duration is 0xb4
function _onSetTitleScreenDisplayDuration(address,len,t)
    if type(onSetTitleScreenDisplayDuration)=="function" then
        local a = onSetTitleScreenDisplayDuration(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onRelicCheckRedCrystal(address,len,t)
    if type(onRelicCheckRedCrystal)=="function" then
        local a = onRelicCheckRedCrystal(t.a)
        if a then memory.setregister("a", a) end
    end
end

-- Relic check for white crystal (to see invisible block)
function _onRelicCheckWhiteCrystal(address,len,t)
    if type(onRelicCheckWhiteCrystal)=="function" then
        local a = onRelicCheckWhiteCrystal(t.a)
        if a then memory.setregister("a", a) end
    end
end

-- Relic check for white crystal to get blue in aljiba
function _onRelicCheckWhiteCrystal2(address,len,t)
    if type(onRelicCheckWhiteCrystal2)=="function" then
        -- todo: pass current truth value and test
        local ret = onRelicCheckWhiteCrystal2()
        
        -- need to check for nil specifically here
        if ret ~= nil then
            if ret==true then
                t.p = bit.bor(t.p, 0x02)
            else
                t.p = bit.bor(t.p, 0x02)-2
            end
            memory.setregister("p", t.p)
        end
    end
end

function _onRelicCheckHeart(address,len,t)
    if type(onRelicCheckHeart)=="function" then
        local a = onRelicCheckHeart(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onRelicCheckAll(address,len,t)
    if type(onRelicCheckAll)=="function" then
        local a = onRelicCheckAll(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onWindowPrintChar(address,len,t)
    if type(onWindowPrintChar)=="function" then
        local a = onWindowPrintChar(t.a)
        if a then memory.setregister("a", a) end
    end
end


function _onGetGoldenKnife(address,len,t)
    if type(onGetGoldenKnife)=="function" then onGetGoldenKnife() end
end

function _onGetSacredFlame(address,len,t)
    if type(onGetSacredFlame)=="function" then onGetSacredFlame() end
end
