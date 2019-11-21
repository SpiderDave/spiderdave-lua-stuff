local util = require("Spidey.util")

--local xpcall = function(f)
--    f()
--    return true
--end

-- This is just a dummy function so we can sort of comment it out easier
memory._registerexec = function() end

local callable=function(f)
    if type(f)~="function" then return true end
end

--local getBank = function(address)
--    local nBanks = 8
--    local bankSize = 0x4000
--    local a1 = address-address % bankSize
--    local compare1 = ""
--    for i=0, 0x10 do
--        compare1=compare1..string.char(memory.readbyte(a1+i))
--    end
--    for bank=1,nBanks do
--        local compare2=""
--        for i=0, 0x10 do
--            compare2=compare2..string.char(rom.readbyte(0x10+(bank*0x4000)+i))
--        end
--        if compare1==compare2 then
--            return bank
--        end
--    end
--end

local getBank = function(address)
    return 1
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
            
            local status, err = xpcall(function() f2(address, len, t) end, msgh)
        end
    end
    memory.registerexec(address, len or 1, f)
end


function NESByteToInt(n)
    if n>=0x80 then
        return -(0x100-n)
    else
        return n
    end
end

function intToNESByte(n)
    if n<0 then
        return n+0x100
    else
        return n
    end
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

registerExec(0xb627,1 ,1,"onCheckIfFiery")
registerExec(0xf41b+2,1 ,1,"onSquare1SfxHandler") -- needs work
registerExec(0xd92c+3,1 ,1,"onPlayerInjury")
registerExec(0xc319,1 ,1,"onSetEnemySpeed")
registerExec(0x860a+3,1 ,1,"onSetPlayerPalette")

registerExec(0x9448,1 ,1,"onLoadBackgroundMetatile")
registerExec(0x94b3,1 ,1,"onLoadForegroundMetatile")
registerExec(0xf6c8,1 ,1,"onMusic")

registerExec(0xf6a4,1 ,1,"onEventMusic")

registerExec(0xb04c,1 ,1,"onGameRoutine")

registerExec(0xd9f3,1 ,1,"onStomp")
registerExec(0xb6b1,1 ,1,"onSetFireballSpeedX")
registerExec(0xb6b5,1 ,1,"onSetFireballSpeedY")

registerExec(0xb6c5,1 ,1,"onSetFireballDownwardForce")

registerExec(0xb752,1 ,1,"onGameTimer")
registerExec(0xc3af,1 ,1,"onSetLakituTimer")
registerExec(0xc4b9,1 ,1,"onSetCheepCheepTimer")
registerExec(0xdf68,1 ,1,"onHitWall")

registerExec(0x8823,1 ,1,"onPrintText")

registerExec(0xc888,1 ,1,"onCheckEnemyType")
registerExec(0xc149,1 ,1,"onLoadEnemyData")

registerExec(0x89e3,1 ,1,"onCheckFrameForColorRotation")

registerExec(0x85aa,1 ,1,"onSetIntermediateBackgroundColor")
registerExec(0x86c2,1 ,1,"onIntermediate")

registerExec(0xefb2,1 ,1,"onSetIntermediateSprite")

registerExec(0xaf9d+3,1 ,1,"onCheckScrollable")

registerExec(0x94f7,1 ,1,"onLoadBlockSolidity")


registerExec(0x884a,1 ,1,"onLivesDisplayCrown")
registerExec(0x884d,1 ,1,"onLivesDisplay")

--registerExec(0x90dc-2,1 ,1,"onTileTest")
--registerExec(0x94f7,1 ,1,"onTileTest")
--registerExec(0x94e0,1 ,1,"onTileTest")
--registerExec(0x88f8+1,1 ,1,"onTileTest")
registerExec(0x88fd,1 ,1,"onTileTest1")
registerExec(0x8903,1 ,1,"onTileTest2")

registerExec(0xbfd7,1 ,1,"onImposeGravity")

-- This is just after jsr UpdateScreen
-- needs work.  not usable
registerExec(0x8082,1 ,1,"onVblank")

--registerExec(0xc469,1 ,1,"onSetFirebarSpeed")
registerExec(0xcd4e,1 ,1,"onSetFirebarSpeed")
registerExec(0xd414,1 ,1,"onSetFirebarSpinDirection")

registerExec(0xcd96,1 ,1,"onSetFirebarLength")

registerExec(0xced4,1 ,1,"onSetFirebarPositions")


--registerExec(0xd8a9,1 ,1,"onSpinyStompCheck")
registerExec(0xd96d,1 ,1,"onSpinyStompCheck")

--registerExec(0xe025,1 ,1,"onDemoteKoopa")
registerExec(0xe02d,1 ,1,"onDemoteKoopa") -- demote when killing with fireballs
registerExec(0xd9b9,1 ,1,"onDemoteKoopa2") -- demote when stomping

registerExec(0xd9bd,1 ,1,"onSetKoopaStateAfterDemote")

--registerExec(0xe01d,1 ,1,"onStunCheck1")

registerExec(0xe025,1 ,1,"onStunCheck1")


--registerExec(0xb561,1 ,1,"onSetPlayerMaximumSpeedLeft")
--registerExec(0xb566,1 ,1,"onSetPlayerMaximumSpeedRight")

-- Here we make better callbacks out of the callbacks.  It's callbacks all the way down!

function _onCheckIfFiery(address,len,t)
    if type(onCheckIfFiery)=="function" then
        local a = onCheckIfFiery(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onSquare1SfxHandler(address,len,t)
    if type(onSquare1SfxHandler)=="function" then
        if t.y~=0 then
            local y = onSquare1SfxHandler(t.y)
            if y then memory.setregister("y", y) end
        end
    end
end

function _onPlayerInjury(address,len,t)
    if type(onPlayerInjury)=="function" then
        local ret = onPlayerInjury()
        
        -- need to check for nil specifically here
        if ret ~= nil then
            if ret==true then
                t.p = bit.bor(t.p, 0x02)-2
            else
                t.p = bit.bor(t.p, 0x02)
            end
            memory.setregister("p", t.p)
        end
    end
end

function _onSetEnemySpeed(address,len,t)
    if type(onSetEnemySpeed)=="function" then
        local a = onSetEnemySpeed(memory.readbyte(0x16+t.x), NESByteToInt(t.a), spidey.sign(NESByteToInt(t.a)))
        if a then memory.setregister("a", intToNESByte(a)) end
    end
end

function _onSetPlayerPalette(address,len,t)
    if type(onSetPlayerPalette)=="function" then
        local CurrentPlayer = memory.readbyte(0x0753)
        local PlayerStatus = memory.readbyte(0x0756)
        local index=t.y
        if PlayerStatus==0x02 then
            index=index-8
        elseif CurrentPlayer==0x01 then
            index=index-4
        end
        
        
        local a = onSetPlayerPalette(CurrentPlayer, PlayerStatus, index, t.a)
        if a then memory.setregister("a", a) end
    end
end


function _onLoadBackgroundMetatile(address,len,t)
    if type(onLoadBackgroundMetatile)=="function" then
        local a = onLoadBackgroundMetatile(t.a)
        if a then memory.setregister("a", a) end
    end
end

-- So far just ground and a few other spots
function _onLoadForegroundMetatile(address,len,t)
    if type(onLoadForegroundMetatile)=="function" then
        local a = onLoadForegroundMetatile(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onMusic(address,len,t)
    if type(onMusic)=="function" then
        local a = onMusic(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onEventMusic(address,len,t)
    if type(onMusic)=="function" then
        local a = onMusic(t.a, true) -- event = true
        if a then memory.setregister("a", a) end
    end
end

function _onSilenceTitleMusic(address,len,t)
    if type(onSilenceTitleMusic)=="function" then
        local a = onSilenceTitleMusic(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onStomp(address,len,t)
    if type(onStomp)=="function" then
        local a = onStomp(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onSetFireballSpeedX(address,len,t)
    if type(onSetFireballSpeed)=="function" then
        local a = onSetFireballSpeed("x", NESByteToInt(t.a), spidey.sign(NESByteToInt(t.a)))
        if a then memory.setregister("a", intToNESByte(a)) end
    end
end

function _onSetFireballSpeedY(address,len,t)
    if type(onSetFireballSpeed)=="function" then
        local a = onSetFireballSpeed("y", NESByteToInt(t.a), spidey.sign(NESByteToInt(t.a)))
        if a then memory.setregister("a", intToNESByte(a)) end
    end
end

function _onGameTimer(address,len,t)
    if type(onGameTimer)=="function" then
        if t.a==1 then
            local ret = onGameTimer(t.a)
            if ret==0 then
                t.p = bit.bor(t.p, 0x02)
                memory.setregister("p", t.p)
            end
        end
    end
end

function _onSetLakituTimer(address,len,t)
    if type(onSetLakituTimer)=="function" then
        local a = onSetLakituTimer(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onSetCheepCheepTimer(address,len,t)
    if type(onSetCheepCheepTimer)=="function" then
        local a = onSetCheepCheepTimer(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onHitWall(address,len,t)
    if type(onHitWall)=="function" then
        local side = memory.readbyte(0)-1
        local facing = memory.readbyte(0x33)-1
        onHitWall(side, facing)
    end
end

-- needs work
function _onPrintText(address,len,t)
    if type(onPrintText)=="function" then
        
        -- get text number from stack
        -- 0x00 = top bar status line
        -- 0x01 = world lives display
        -- 0x02 = time up
        -- 0x03 = game over
        -- 0x04 = warp zone welcome
        local textNumber = memory.readbyte(0x100+t.s+1)
        
        local a = onPrintText(textNumber, t.a, t.y)
        if a then memory.setregister("a", a) end
    end
end

-- needs work
function _onCheckEnemyType(address,len,t)
    if type(onCheckEnemyType)=="function" then
        local y = onCheckEnemyType(t.y)
        if y then
            memory.setregister("y", y)
            --memory.writebyte(0x16+t.x, y)
        end
    end
end

-- doesn't work
function _onLoadEnemyData(address,len,t)
    if type(onLoadEnemyData)=="function" then
        local a = onLoadEnemyData(t.a)
        if a then
            memory.setregister("a", a)
        end
    end
end

function _onCheckFrameForColorRotation(address,len,t)
    if type(onCheckFrameForColorRotation)=="function" then
        local a = onCheckFrameForColorRotation(t.a)
        if a then
            memory.setregister("a", a)
        end
    end
end

function _onSetIntermediateBackgroundColor(address,len,t)
    if type(onSetIntermediateBackgroundColor)=="function" then
        local a = onSetIntermediateBackgroundColor(t.a)
        if a then
            memory.setregister("a", a)
        end
    end
end

function _onIntermediate(address,len,t)
    if type(onIntermediate)=="function" then
        onIntermediate()
    end
end

function _onSetIntermediateSprite(address,len,t)
    if type(onSetIntermediateSprite)=="function" then
        local x,y = onSetIntermediateSprite(t.x, t.y)
        if x then
            memory.setregister("x", x)
        end
        if y then
            memory.setregister("y", y)
        end
    end
end


function _onSetFireballDownwardForce(address,len,t)
    if type(onSetFireballDownwardForce)=="function" then
        local a = onSetFireballDownwardForce(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onCheckScrollable(address,len,t)
    if type(onCheckScrollable)=="function" then
        local ret = onCheckScrollable((t.a==0))
        --if a then memory.setregister("a", a) end

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

function _onLoadBlockSolidity(address,len,t)
    if type(onLoadBlockSolidity)=="function" then
        local a = onLoadBlockSolidity(t.a)
        if a then memory.setregister("a", a) end
    end
end

function _onLivesDisplayCrown(address,len,t)
    if type(onLivesDisplay)=="function" then
        local nLives = memory.readbyte(0x75a)+1
        local y = onLivesDisplay(0, t.y, nLives)
        if y then memory.setregister("y", y) end
    end
end

function _onLivesDisplay(address,len,t)
    if type(onLivesDisplay)=="function" then
        local nLives = memory.readbyte(0x75a)+1
        local a = onLivesDisplay(1, t.a, nLives)
        if a then memory.setregister("a", a) end
    end
end

function _onTileTest1(address,len,t)
    if type(onTileTest)=="function" then
        local index = t.y % 4
        local a = onTileTest(t.a, index)
        if a then memory.setregister("a", a) end
    end
end

function _onTileTest2(address,len,t)
    if type(onTileTest)=="function" then
        local index = t.y % 4
        local a = onTileTest(t.a, index)
        if a then memory.setregister("a", a) end
    end
end


function _onSetPlayerMaximumSpeedLeft(address,len,t)
    if type(onSetPlayerMaximumSpeed)=="function" then
        local a = onSetPlayerMaximumSpeed("left", t.a)
        if a then memory.setregister("a", a) end
        --local a = onSetPlayerMaximumSpeed("left", NESByteToInt(t.a), spidey.sign(NESByteToInt(t.a)))
        --if a then memory.setregister("a", intToNESByte(a)) end
    end
end

function _onSetPlayerMaximumSpeedRight(address,len,t)
    if type(onSetPlayerMaximumSpeed)=="function" then
        local a = onSetPlayerMaximumSpeed("right", t.a)
        if a then memory.setregister("a", a) end
--        local a = onSetPlayerMaximumSpeed("right", NESByteToInt(t.a), spidey.sign(NESByteToInt(t.a)))
--        if a then memory.setregister("a", intToNESByte(a)) end
    end
end

function _onGameRoutine(address,len,t)
    if type(onGameRoutine)=="function" then
        local a = onGameRoutine(t.a)
        if a then 
            memory.setregister("a", a)
            --memory.writebyte(0x0e,a)
        end
    end
    
    local routines = {
        [0]="Entrance_GameTimerSetup",
        [1]="Vine_AutoClimb",
        [2]="SideExitPipeEntry",
        [3]="VerticalPipeEntry",
        [4]="FlagpoleSlide",
        [5]="PlayerEndLevel",
        [6]="PlayerLoseLife",
        [7]="PlayerEntrance",
        [8]="PlayerCtrlRoutine",
        [9]="PlayerChangeSize",
        [0x0a]="PlayerInjuryBlink",
        [0x0b]="PlayerDeath",
        [0x0c]="PlayerFireFlower",
    }
    
    local fName = "on" .. routines[t.a]
    if type(_G[fName])=="function" then
        local a = _G[fName](t.a)
        if a then memory.setregister("a", a) end
    end
end

local coerceToByte = function(n)
    return math.min(255, math.max(0, math.floor(n)))
end

--0BFD7                           ;$00 - used for downward force
--0BFD7                           ;$01 - used for upward force
--0BFD7                           ;$07 - used as adder for vertical position
function _onImposeGravity(address,len,t)
    if type(onImposeGravity)=="function" then
        local downwardForce = onImposeGravity(t.x, memory.readbyte(0))
        if downwardForce then memory.writebyte(0x00, coerceToByte(downwardForce)) end
    end
end


function _onVblank(address,len,t)
    if type(onVblank)=="function" then
        onVblank()
    end
end

function _onSetFirebarSpeed(address,len,t)
    if type(onSetFirebarSpeed)=="function" then
        local a = onSetFirebarSpeed(t.a)
        if a then memory.setregister("a", coerceToByte(a)) end
    end
end

function _onSetFirebarSpinDirection(address,len,t)
    if type(onSetFirebarSpinDirection)=="function" then
        --local spinDir = (t.a==0) and 0 or 1
        
        spinDir = onSetFirebarSpinDirection((t.a==0) and 0 or 1)
        
        if spinDir ~= nil then
            if spinDir==0 then
                t.p = bit.bor(t.p, 0x02)
            elseif spinDir==1 then
                t.p = bit.bor(t.p, 0x02)-2
            end
            memory.setregister("p", t.p)
        end
    end
end

function _onSetFirebarLength(address,len,t)
    if type(onSetFirebarLength)=="function" then
        local y = onSetFirebarLength(t.y)
        if y then memory.setregister("y", coerceToByte(y)) end
    end
end

function _onSetFirebarPositions(address,len,t)
    if type(onSetFirebarPositions)=="function" then
        local y = onSetFirebarPositions(t.y)
        if y then memory.setregister("y", coerceToByte(y)) end
    end
end


function _onSpinyStompCheck(address,len,t)
    if type(onSpinyStompCheck)=="function" then
        
        if t.a==0x12 then
            local ret = onSpinyStompCheck(true)

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
end

function _onDemoteKoopa(address,len,t)
    if type(onDemoteKoopa)=="function" then
        --local a = onDemoteKoopa(memory.readbyte(0x16 + t.x), t.a)
        if a then
            a = coerceToByte(a)
            memory.setregister("a", a)
            memory.writebyte(0x16 + t.x, a)
        end
    end
end

function _onDemoteKoopa2(address,len,t)
    if type(onDemoteKoopa)=="function" then
        local a = onDemoteKoopa(memory.readbyte(0x16 + t.x), t.a)
        if a then
            a = coerceToByte(a)
            memory.setregister("a", a)
            memory.writebyte(0x16 + t.x, a)
        end
    end
end


function _onStunCheck1(address,len,t)
    if type(onStunCheck1)=="function" then
        --if t.a==0x12 then
            local ret = onStunCheck1(t.y)

            if ret ~= nil then
                if ret==true then
                    t.p = bit.bor(t.p, 0x02)
                else
                    t.p = bit.bor(t.p, 0x02)-2
                end
                memory.setregister("p", t.p)
            end
        --end

    end
end



function _onSetKoopaStateAfterDemote(address,len,t)
    if type(onSetKoopaStateAfterDemote)=="function" then
        local y = onSetKoopaStateAfterDemote(t.a, t.y)
        if y then
            y = coerceToByte(y)
            memory.setregister("y", y)
            memory.writebyte(0x1e + t.x, y)
        end
    end
end
