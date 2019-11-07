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

--registerExec(0xdf4d,7,1,"onDestroyObject")

--registerExec(0x85fd,1 ,1,"onCheckForFireStatus")
registerExec(0xb627,1 ,1,"onCheckIfFiery")

-- needs work
registerExec(0xf41b+2,1 ,1,"onSquare1SfxHandler")
registerExec(0xd92c+3,1 ,1,"onPlayerInjury")
registerExec(0xc319,1 ,1,"onSetEnemySpeed")
registerExec(0x860a+3,1 ,1,"onSetPlayerPalette")
registerExec(0x9448,1 ,1,"onLoadBackgroundMetatile")
registerExec(0x94b3,1 ,1,"onLoadForegroundMetatile")
registerExec(0x9113,1 ,1,"onMusic")
registerExec(0xd81d,1 ,1,"onStarMusic")
registerExec(0xd9f3,1 ,1,"onStomp")
registerExec(0xb6b1,1 ,1,"onSetFireballSpeedX")
registerExec(0xb6b5,1 ,1,"onSetFireballSpeedY")

registerExec(0xb6c5,1 ,1,"onSetFireballDownwardForce")

registerExec(0xb752,1 ,1,"onGameTimer")
registerExec(0xc3af,1 ,1,"onSetLakituTimer")
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

function _onStarMusic(address,len,t)
    if type(onMusic)=="function" then
        local a = onMusic(t.a)
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
        local nLives = memory.readbyte(0x75a)
        local y = onLivesDisplay(0, t.y, nLives)
        if y then memory.setregister("y", y) end
    end
end

function _onLivesDisplay(address,len,t)
    if type(onLivesDisplay)=="function" then
        local nLives = memory.readbyte(0x75a)
        local a = onLivesDisplay(1, t.a, nLives)
        if a then memory.setregister("a", a) end
    end
end
