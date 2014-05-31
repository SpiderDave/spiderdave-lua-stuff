-- 
-- Author: SpiderDave
--
-- Primarily for FCEUX, but I want to make it more generic, 
-- starting with limited support for VBA.
--

local class
class=function(name)
    local newclass={}
    _G[name]=newclass
    newclass.__members={}
    function newclass.define(class,members)
        for k,v in pairs(members) do
            class.__members[k]=v
        end
    end
    function newclass.extends(class,base)
        class.super=base
        for k,v in pairs(base.__members) do
            class.__members[k]=v
        end
        return setmetatable(class,{__index=base,__call=class.define})
    end
    function newclass.new(class,...)
        local object={}
        for k,v in pairs(class.__members) do
            object[k]=v
        end
        setmetatable(object,{__index=class})
        if object.init then
            object:init(...)
        end
        return object
    end
    return setmetatable(newclass,{__call=newclass.define})
end

local spidey={
    version="2013.1.15",
    emu={},
    nes={},
    Menu={},
    menus={},
    windows={},
    game={},
    classes={},
    debug={
        showinput=nil
    },
    memoryViewer={visible=false, type="ram"},
    paletteViewer={visible=false},
    cheatEngine={
        enabled=true,
        active=true,
        cheats={},
        range=0x10000,
        data={
            last=nil,valid={},numValid=0
        }
    },
    imgEdit={
        transparent=not true,
        transparentColor="#000000",
        nobk=false,
        capture=false
    },
    showSelect=not true
}

if (FCEU) then
    spidey.emu.name="FCEU"
    spidey.emu.fceu=true
    spidey.emu.button_names={'up','down','left','right','A','B','select','start'}
    require("auxlib")
    spidey.screenWidth=256
    spidey.screenHeight=240
    spidey.cheatEngine.range=0x10000
elseif (vba) then
    spidey.emu.name='VBA'
    spidey.emu.vba=true
    -- Note: L and R are available for GBA only
    spidey.emu.button_names={'up','down','left','right','A','B','select','start','L','R'}
    gui.message=gui.message or emu.message
    rom=rom or {}
    
    -- crude detection of gba over gbx, might fail on some games.
    if (memory.readbyte(0x08000000+0x0b2)==0x96) then
        spidey.emu.gba=true
    else
        spidey.emu.gbx=true
    end
    
    if spidey.emu.gba then
        spidey.screenWidth=240
        spidey.screenHeight=160

        spidey.game.title=""
        for i=0,11 do
            spidey.game.title=spidey.game.title .. string.char(memory.readbyte(0x08000000+0x0a0+i))
        end
        spidey.game.code=""
        for i=0,3 do
            spidey.game.code=spidey.game.code.. string.char(memory.readbyte(0x08000000+0x0ac+i))
        end
        spidey.game.vendor=""
        for i=0,1 do
            spidey.game.vendor=spidey.game.vendor.. string.char(memory.readbyte(0x08000000+0x0b0+i))
        end
    else
        spidey.screenWidth=160
        spidey.screenHeight=144
    end
elseif (snes9x) then
    -- Snes9x uses memory.read to read from ROM
    rom=memory
    -- .get and .set seem to be more standard; we should avoid read/write but
    -- this is a convenience for now.
    --input.read=input.get
    --input.write=input.set
    --joypad.read=joypad.get
    --joypad.write=joypad.set
    spidey.emu.button_names={'up','down','left','right','A','B','Y','X','L','R','select','start'}
    
    --[[ this is handled elsewhere now
    spidey.game.title=''
    for i = 0, 14 do
        spidey.game.title=spidey.game.title .. string.char(memory.readbyte(0xffc0+i))
    end
    ]]--

    spidey.screenWidth=256  -- these are wrong, fix later
    spidey.screenHeight=240
elseif mame then
    spidey.game.title=emu.gamename()
    spidey.emu.button_names={'up','down','left','right','1','2','3','4','select','start'}
    spidey.screenWidth=emu.screenwidth()
    spidey.screenHeight=emu.screenheight()
elseif fba then
elseif emu and nes and forms then
    -- not a very good test but fine for now
    spidey.emu.name='Bizhawk'
    spidey.emu.button_names={'up','down','left','right','A','B','select','start'}
    --spidey.screenHeight=client.screenheight
    --spidey.screenWidth=client.screenwidth
    spidey.screenWidth=256
    spidey.screenHeight=240
    gui.drawbox=gui.drawBox
    emu.message=gui.addmessage
    spidey.emu.type=emu.getsystemid()
else
    spidey.emu.name='unknown'
    spidey.emu.button_names={'up','down','left','right','A','B','select','start'}
end

--gui.text(16,16, spidey.game.title or "")

enableddisabled={[true]="enabled",[false]="disabled"}
truefalse={[true]='true',[false]='false'}
yesno={[true]="yes",[false]="no"}

prettyValue=function(v)
    if v==true then
        return "enabled"
    elseif v==false then
        return "disabled"
    elseif v==nil then
        return "disabled"
    else
        return "unknown"
    end
end


spidey.emu.getTitle=function()
    if snes9x then
        spidey.game.lastTitle=spidey.game.title
        spidey.game.title=''
        for i = 0, 14 do
            spidey.game.title=spidey.game.title .. string.char(memory.readbyte(0xffc0+i))
        end
    end
    return spidey.game.title
end


--
-- New memory functions
--
if spidey.emu.name=="Bizhawk" and spidey.emu.type=="NES" then
    function readbyte_sp(a)
        if a>0x6000 and a<0x7fff then
            memory.usememorydomain("WRAM")
            a=a-0x6000
        else
            memory.usememorydomain("RAM")
        end
        ret = memory.read_u8(a)
        memory.usememorydomain("RAM")
        return ret
    end
    function writebyte_sp(a,v)
        if a>0x6000 and a<0x7fff then
            memory.usememorydomain("WRAM")
            a=a-0x6000
        else
            memory.usememorydomain("RAM")
        end
        memory.write_u8(a,v)
        memory.usememorydomain("RAM")
    end
    memory.readbyte=readbyte_sp
    memory.writebyte=writebyte_sp
end


if rom then
    function rom.readword(a) return rom.readbyte(a) + 256 * rom.readbyte(a+1) end
end
if not memory.readword then
    function memory.readword(a) return memory.readbyte(a) + 256 * memory.readbyte(a+1) end
end

function memory.getregisters()
    return memory.getregister("a"),memory.getregister("x"),memory.getregister("y"),memory.getregister("s"),memory.getregister("p"),memory.getregister("pc")
end

function memory.readbyteppu(a)
    memory.writebyte(0x2001,0x00) -- Turn off rendering
    memory.readbyte(0x2002) -- PPUSTATUS (reset address latch)
    memory.writebyte(0x2006,math.floor(a/0x100)) -- PPUADDR high byte
    memory.writebyte(0x2006,a % 0x100) -- PPUADDR low byte
    if a < 0x3f00 then 
        dummy=memory.readbyte(0x2007) -- PPUDATA (discard contents of internal buffer if not reading palette area)
    end
    ret=memory.readbyte(0x2007) -- PPUDATA
    memory.writebyte(0x2001,0x1e) -- Turn on rendering
    return ret
end

function memory.readbytesppu(a,l)
    memory.writebyte(0x2001,0x00) -- Turn off rendering
    local ret
    local i
    ret=""
    for i=0,l-1 do
        memory.readbyte(0x2002) -- PPUSTATUS (reset address latch)
        memory.writebyte(0x2006,math.floor((a+i)/0x100)) -- PPUADDR high byte
        memory.writebyte(0x2006,(a+i) % 0x100) -- PPUADDR low byte
        if (a+i) < 0x3f00 then 
            dummy=memory.readbyte(0x2007) -- PPUDATA (discard contents of internal buffer if not reading palette area)
        end
        --ret=ret..memory.readbyte(0x2007) -- PPUDATA
        ret=ret..string.char(memory.readbyte(0x2007)) -- PPUDATA
    end
    memory.writebyte(0x2001,0x1e) -- Turn on rendering
    return ret
end


function memory.writebyteppu(a,v)
    memory.writebyte(0x2001,0x00) -- Turn off rendering
    memory.readbyte(0x2002) -- PPUSTATUS (reset address latch)
    memory.writebyte(0x2006,math.floor(a/0x100)) -- PPUADDR high byte
    memory.writebyte(0x2006,a % 0x100) -- PPUADDR low byte
    memory.writebyte(0x2007,v) -- PPUDATA
    memory.writebyte(0x2001,0x1e) -- Turn on rendering
end

function memory.writebytesppu(a,str)
    memory.writebyte(0x2001,0x00) -- Turn off rendering
    
    local i
    for i = 0, #str-1 do
        memory.readbyte(0x2002) -- PPUSTATUS (reset address latch)
        memory.writebyte(0x2006,math.floor((a+i)/0x100)) -- PPUADDR high byte
        memory.writebyte(0x2006,(a+i) % 0x100) -- PPUADDR low byte
        --memory.writebyte(0x2007,0x40) -- PPUDATA
        memory.writebyte(0x2007,string.byte(str,i+1)) -- PPUDATA
    end
    
    memory.writebyte(0x2001,0x1e) -- Turn on rendering
end


-- note: the usual memory.readbyterange is inconsistant.  table or string.
function memory.readbytes(address,n)
    local i
    ret=""
    for i = 0, n-1 do
        ret=ret..string.char(memory.readbyte(address+i))
    end
    return ret
end

-- Write a string of bytes to memory
function memory.writebytes(address,str)
    local i
    local c
    for i = 0, #str-1 do
        memory.writebyte(address+i,string.byte(str,i+1))
    end
end

-- sets a custom breakpoint thing
function spidey.setBreakpoint(address, fn)
    local f=function()
        local a,x,y,s,p,pc=memory.getregisters()
        if fn then
            fn(address,{a,x,y,s,p,pc})
        end
        --gui.text(0+4+50, 20+08, string.format("a=%X x=%X y=%X s=%X p=%X pc=%X",a,x,y,s,p,pc))
        --emu.pause()
    end
    memory.registerexec(address,1,f)
end

-- sets an exec breakpoint from a memory write, then
-- unregisters itself.  neat, eh?
function spidey.setBreakpointFromWrite(address, fn)
    local f=function()
        a,x,y,s,p,pc=memory.getregisters()
        spidey.setBreakpoint(pc,fn)
        memory.register(address,1,nil)
    end
    memory.register(address,1,f)
end

--fonts={}
--fonts[letters]="ABCDEFGHIJKLMNOPQRSTUVWXYZ.,?!abcdefghijklmnopqrstuvwxyz-*@#0123456789“”:&''\"             "
--font_letters="ABCDEFGHIJKLMNOPQRSTUVWXYZ.,?!abcdefghijklmnopqrstuvwxyz-*@#0123456789“”:&''\"             "

joypad_data={[1]=joypad.get(1), [2]=joypad.get(2)}
function joypad_read()
    joypad_data['old']={joypad_data[1],joypad_data[2]}
    
    for i=1,2 do
        joypad_data[i]=joypad.get(i)
        if mame then
            --joypad_data[i]=joypad.get()
            joypad_data[i]={}
            joytemp=joypad.get()
            for k, v in pairs(joytemp) do
                --if v==false then joypad_data[i][k]=nil end
                if v==true then
                    if string.sub(k,1,3)=="P"..tostring(i).." " then
                        -- Strings like "P1 Up" will become "up", etc
                        new_key=string.sub(k,4)
                        if #new_key==1 then
                            new_key=string.upper(new_key)
                        else
                            new_key=string.lower(new_key)
                        end
                        if new_key=="button 1" then new_key="1" end
                        if new_key=="button 2" then new_key="2" end
                        if new_key=="button 3" then new_key="3" end
                        if new_key=="button 4" then new_key="4" end
                        
                        joypad_data[i][new_key]=true
                    else
                        -- buttons that don't start with Px
                        new_key=k
                        if #new_key==1 then
                            new_key=string.upper(new_key)
                        else
                            new_key=string.lower(new_key)
                        end
                        
                        if new_key==tostring(i).." player start" then
                            new_key="start"
                        elseif new_key==tostring(i).." players start" then
                            new_key="start"
                        end
                        
                        joypad_data[i][new_key]=true
                    end
                end
            end
        end
        
        if spidey.emu.name=='Bizhawk' then
            joypad_data[i]["up"]=joypad_data[i]["Up"]
            joypad_data[i]["down"]=joypad_data[i]["Down"]
            joypad_data[i]["left"]=joypad_data[i]["Left"]
            joypad_data[i]["right"]=joypad_data[i]["Right"]
            joypad_data[i]["select"]=joypad_data[i]["Select"]
            joypad_data[i]["start"]=joypad_data[i]["Start"]
        end
        
        
        for ii=1,#spidey.emu.button_names do
            b=spidey.emu.button_names[ii]
            joypad_data[i][b..'_press']=(joypad_data[i][b] and not joypad_data.old[i][b])
            joypad_data[i][b..'_press_time']=joypad_data[i][b] and math.min((joypad_data.old[i][b..'_press_time'] or 0) +1,1000) or 0
            joypad_data[i]['idle']= (joypad_data[i].up~=true and joypad_data[i].down~=true and joypad_data[i].left~=true and joypad_data[i].right~=true and joypad_data[i].A~=true and joypad_data[i].B~=true and joypad_data[i].select~=true and joypad_data[i].start~=true)
            joypad_data[i]['idle_time']=joypad_data[i]['idle'] and math.min((joypad_data.old[i]['idle_time'] or 0) +1,1000) or 0
            if spidey.debug.showInput then
                --gui.text(8, 8+8*2+8*ii, string.format("%s",truefalse[joypad_data[1].idle]) ,"white","clear")
                gui.text(8, 8+8*2+8*ii, string.format("%s %s",ii, b) ,"white","clear")
                gui.text(8+50, 8+8*2+8*ii, string.format("%s",joypad_data[i][string.format('%s_press', b)] and 1 or 0) ,"white","clear")
                gui.text(8+100, 8+8*2+8*ii, string.format("%s",joypad_data[i][b..'_press_time']) ,"white","clear")
            end
        end
    end
    
    return joypad_data
end

--
-- A drop-in replacement for input.read() with more options.
--
-- leftbutton_press returns true the moment left button is pressed
-- leftbutton_release returns true the moment left button is released
-- leftbutton_click returns true when the left button is pressed and released without movement
-- selection.x selection.y selection.width selection.height
--
-- Note: the keyboard part of this is kind of lacking right now
--
input_data={['current']=input.get()}
function input_read()
    input_data['old']=input_data.current
    input_data.current=input.get()
    if input_data.current.X then
        -- bizhawk uses X Y not xmouse ymouse
        input_data.current.xmouse=input_data.current.X
        input_data.current.Ymouse=input_data.current.Y
    end
    
    input_data.current.pageup_press=input_data.current.pageup and not input_data.old.pageup
    input_data.current.pagedown_press=input_data.current.pagedown and not input_data.old.pagedown
    
    input_data.current.selection={}
    
    --depreciated; use leftbutton_press
    input_data.current.leftclick_real=(input_data.current.leftclick and not input_data.old.leftclick)
    
    input_data.current.leftbutton=input_data.current.leftclick
    input_data.current.middlebutton=input_data.current.middleclick
    input_data.current.rightbutton=input_data.current.rightclick
    
    input_data.current.leftbutton_press=(input_data.current.leftclick and not input_data.old.leftclick)
    input_data.current.leftbutton_release=(not input_data.current.leftclick and input_data.old.leftclick)
    
    input_data.current.middlebutton_press=(input_data.current.middleclick and not input_data.old.middleclick)
    input_data.current.middlebutton_release=(not input_data.current.middleclick and input_data.old.middleclick)
    
    input_data.current.rightbutton_press=(input_data.current.rightclick and not input_data.old.rightclick)
    input_data.current.rightbutton_release=(not input_data.current.rightclick and input_data.old.rightclick)
    
    if input_data.current.leftbutton_press then
        input_data.current.xmouse_down=input_data.current.xmouse
        input_data.current.ymouse_down=input_data.current.ymouse
    else
        input_data.current.xmouse_down=input_data.old.xmouse_down
        input_data.current.ymouse_down=input_data.old.ymouse_down
    end
    
    -- snap 8
    if input_data.current.xmouse_down and input_data.current.ymouse_down then
        input_data.current.xmouse_down=input_data.current.xmouse_down-input_data.current.xmouse_down % 8
        input_data.current.ymouse_down=input_data.current.ymouse_down-input_data.current.ymouse_down % 8
    end
    
    if input_data.current.xmouse==input_data.old.xmouse and input_data.current.ymouse==input_data.old.ymouse then
        input_data.current.mouseidle=math.min((input_data.old.mouseidle or 0) +1,1000)
    else
        input_data.current.mouseidle=0
    end
    
    if input_data.current.leftbutton_release then
        if input_data.current.xmouse==input_data.current.xmouse_down and input_data.current.ymouse==input_data.current.ymouse_down then
            -- Click is pressing and releasing without movement
            input_data.current.leftbutton_click=true
        end
        input_data.current.xmouse_up=input_data.current.xmouse
        input_data.current.ymouse_up=input_data.current.ymouse
        
        -- snap 8
        if input_data.current.xmouse_up and input_data.current.ymouse_up then
            input_data.current.xmouse_up=(input_data.current.xmouse_up+4)-(input_data.current.xmouse_up+4) % 8
            input_data.current.ymouse_up=(input_data.current.ymouse_up+4)-(input_data.current.ymouse_up+4) % 8
        end
        
        if input_data.current.xmouse_up>input_data.current.xmouse_down then
            input_data.current.selection.x=input_data.current.xmouse_down
            input_data.current.selection.width=input_data.current.xmouse_up-input_data.current.xmouse_down
        else
            input_data.current.selection.x=input_data.current.xmouse_up
            input_data.current.selection.width=input_data.current.xmouse_down-input_data.current.xmouse_up
        end
        if input_data.current.ymouse_up>input_data.current.ymouse_down then
            input_data.current.selection.y=input_data.current.ymouse_down
            input_data.current.selection.height=input_data.current.ymouse_up-input_data.current.ymouse_down
        else
            input_data.current.selection.y=input_data.current.ymouse_up
            input_data.current.selection.height=input_data.current.ymouse_down-input_data.current.ymouse_up
        end
    else
        input_data.current.xmouse_up=input_data.old.xmouse_up
        input_data.current.ymouse_up=input_data.old.ymouse_up
    end

    if spidey.showSelect and input_data.current.leftclick then
        x2=input_data.current.xmouse
        y2=input_data.current.ymouse
        -- snap 8
        x2=(x2+4)-(x2+4) % 8
        y2=(y2+4)-(y2+4) % 8
        gui.text(input_data.current.xmouse_down,input_data.current.ymouse_down-8,string.format('(%s,%s) %sx%s',input_data.current.xmouse_down, input_data.current.ymouse_down,math.abs(x2-input_data.current.xmouse_down),math.abs(y2-input_data.current.ymouse_down)), "white", "black")
        gui.drawbox(input_data.current.xmouse_down, input_data.current.ymouse_down, x2, y2, 'clear',"white")
    end

    return input_data.current
end

function input_showselect(show)
    if show==true then
        input_data.showselect=true
        spidey.showSelect=true
    else
        input_data.showselect=nil
        spidey.showSelect=not true
    end
end

-- load a font from .gd files.  DEPRECIATED
function loadfont(path)
    -- takes path to font files, ending in \
    font={}
    str="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    --str=font.letters
    for i = 1, #str do
        local c = str:sub(i,i)
        local file = io.open(path..c..'.gd',"rb")
        io.input(file)
        font[c]=io.read('*a')
        io.close(file)
    end
    return font
end

function getfilecontents(path)
    local file = io.open(path,"rb")
    if file==nil then return nil end
    io.input(file)
    ret=io.read('*a')
    io.close(file)
    return ret
end

function writetofile(path,stuff)
    if not stuff then return nil end
    local file = io.open(path,"wb")
    io.output(file)
    io.write(stuff)
    io.close(file)
    return true
end

-- draw font loaded with loadfont function
function drawfont(x,y,font,str)
    if not gui.gdoverlay then
        gui.text(x,y,str,"black","white")
        return
    end
    
    local originx=x
    local originy=y
    if (not font) then return false end
    for i = 1, #str do
        local c = str:sub(i,i)
        if (c=='\n') then
            x=originx
            y=y+8
        elseif (font[c]) then
            gui.gdoverlay(x,y, font[c])
            x=x+8
        end
    end
end

function spidey.outlineText(x,y,str,c1,c2)
    gui.text(x-1,y,str,c2,"clear")
    gui.text(x+1,y,str,c2,"clear")
    gui.text(x,y-1,str,c2,"clear")
    gui.text(x,y+1,str,c2,"clear")

    gui.text(x-1,y-1,str,c2,"clear")
    gui.text(x+1,y-1,str,c2,"clear")
    gui.text(x-1,y-1,str,c2,"clear")
    gui.text(x+1,y+1,str,c2,"clear")

    ret = gui.text(x,y,str,c1,"clear")
    return ret
end

function spidey.recolorImage(img, oldColor, newColor)
    if gui.parsecolor then
        r,g,b,a=gui.parsecolor(oldColor)
        oldColor=string.format("%02x%02x%02x%02x",a,r,g,b)
        r,g,b,a=gui.parsecolor(newColor)
        newColor=string.format("%02x%02x%02x%02x",a,r,g,b)
    end
    
    newStr=string.sub(img,1,11)
    for j=1,(#img-11)/4 do
        if string.sub(img, 11+j*4-3,11+j*4-3+3)==hex2bin(oldColor) then
            newStr=newStr..hex2bin(newColor)
        else
            newStr=newStr..string.sub(img, 11+j*4-3,11+j*4-3+3)
        end
    end
    return newStr
end

function bin2hex(str)
    local output=''
    for i = 1, #str do
        local c = string.byte(str:sub(i,i))
        output=output..string.format("%02x", c)
    end
    return output
end

function hex2bin(str)
    local output=''
    for i = 1, (#str/2) do
        local c = str:sub(i*2-1,i*2)
        output=output..string.char(tonumber(c, 16))
    end
    return output
end


function spidey.memoryViewer.show()
    spidey.memoryViewer.visible=true
end

--[[--------------------------------------------------
function to display memory on screen; good for debugging n stuff
--------------------------------------------------]]--
function spidey.memoryViewer.draw()
    if not spidey.memoryViewer.visible==true then return end
    local address,x,y
    spidey.memoryViewer.address=spidey.memoryViewer.address or 0
    
    if spidey.inp.pageup_press then
        spidey.memoryViewer.address=spidey.memoryViewer.address-0x50
        if spidey.memoryViewer.address<0 then spidey.memoryViewer.address=0 end
    end
    if spidey.inp.pagedown_press then
        spidey.memoryViewer.address=spidey.memoryViewer.address+0x50
    end
    
    address=spidey.memoryViewer.address
    
    x=spidey.memoryViewer.x or 8
    y=spidey.memoryViewer.y or 8
    x=4
    address=spidey.memoryViewer.address or 0
    
    --gui.drawbox(x-1, y-1, spidey.screenWidth-(x-1), y+8*16, "black", "black")
    for i=1,16 do
        --gui.text(x,y+8*i-7,string.format('%04x %02X  ',address, rom.readbyte(address+0x10)) ,"white","clear")
        gui.text(x,y+8*i-7,string.format('%04x',address),"white","clear")
        for j=0,15 do
            if spidey.memoryViewer.type=="rom" then
                gui.text(x+28+14*j,y+8*i-7,string.format('%02X', rom.readbyte(address+0x10+j)),"white","clear")
            else
                gui.text(x+28+14*j,y+8*i-7,string.format('%02X', memory.readbyte(address+j)),"white","clear")
            end
            address=address+1
        end
    end
    --[[
    for j=1,5 do
        for i=0,16-1 do
            if spidey.memoryViewer.type=="rom" then
                gui.text(x+8*(6*j-5), y+8*(1+i), string.format('%X %02X  ',address, rom.readbyte(address+0x10)) ,"white","black")
            else
                gui.text(x+8*(6*j-5), y+8*(1+i), string.format('%X %02X  ',address, memory.readbyte(address)) ,"white","black")
            end
            address=address+1
        end
    end
    ]]--
end

function spidey.paletteViewer.show()
    spidey.paletteViewer.visible=true
end

function spidey.paletteViewer.draw()
    if not spidey.paletteViewer.visible==true then return end
    local x,y,r,g,b
    gui.drawbox(8*1-1,8*2-1,8*31+1,8*28+1, "#00000070","#000000D0")
    x=8
    y=16
    for i=0,0x3f do
        c=string.format("P%02X",i+24*0)
        gui.drawbox(x,y,x+8*10,y+8, c, c)
        spidey.outlineText(x+8,y,c,"white","black")
        r,g,b=gui.getpixel(x,y)
        spidey.outlineText(x+8*4,y,string.format("#%02X%02X%02X",r,g,b),"white","black")
        y=y+8
        if y>spidey.screenHeight-8*3 then
            x=x+8*10
            y=16
        end
    end
end

class "Window" {
    x=0,
    y=8,
    width=64,
    height=64,
    backgroundColor="#00000070",
    borderColor="#000000C0",
    titleColor="#ffffffd0",
    titleBackgroundColor="#808080c0",
    titleDividerColor="#000000C0",
    title="title",
    innerX=0,
    innerY=0,
    visible=false
}
function Window:init(name)
    self.name=name or self.title
    self.title=name or self.title
    spidey.windows[#spidey.windows+1]=self
end
function Window:show()
    self.visible=true
end
function Window:hide()
    self.visible=not true
end
function Window:_draw()
    if self.visible~=true then return end
    gui.drawbox(self.x,self.y, self.x+self.width, self.y+self.height, self.backgroundColor,self.borderColor)
    gui.drawbox(self.x,self.y, self.x+self.width, self.y+8+2, self.titleBackgroundColor,"clear")
    gui.drawline(self.x+1,self.y+8+2, self.x+self.width-1, self.y+8+2, self.titleDividerColor)
    gui.text(self.x+2,self.y+2,self.title,self.titleColor7,"clear")
    self.innerX=self.x+1
    self.innerY=self.y+8+3
    if self.draw then self.draw() end
end

local captureWindow
captureWindow=Window:new("capture")

function captureWindow:draw()
    if spidey.imgEdit.clip then
        gui.gdoverlay(captureWindow.innerX,captureWindow.innerY, spidey.imgEdit.clip)
    end
    --if button(captureWindow.innerX,captureWindow.innerY+50,"save") then
    --end
end

local memoryViewerWindow
memoryViewerWindow=Window:new("memoryViewerWindow")
memoryViewerWindow.backgroundColor="#000000D0"

function memoryViewerWindow:draw()
    if spidey.memoryViewer.type=="rom" then
        memoryViewerWindow.backgroundColor="#400000D0"
        memoryViewerWindow.title="Memory: ROM"
    else
        memoryViewerWindow.backgroundColor="#000000D0"
        memoryViewerWindow.title="Memory: RAM"
    end
    spidey.memoryViewer.x=memoryViewerWindow.innerX
    spidey.memoryViewer.y=memoryViewerWindow.innerY+4
    memoryViewerWindow.width=spidey.screenWidth
    memoryViewerWindow.height=memoryViewerWindow.innerY+8*16
    spidey.memoryViewer.draw()
end

function spidey.imgEdit.update()
    if spidey.imgEdit.capture then
        spidey.showSelect=true
        --if spidey.inp.leftbutton_release and not spidey.inp.leftbutton_click then
        if spidey.inp.leftbutton_release then
            local clip
            clip=gdfromscreen(spidey.inp.selection.x,spidey.inp.selection.y,spidey.inp.selection.width,spidey.inp.selection.height, {transparent=spidey.imgEdit.transparent,transparentcolor=spidey.imgEdit.transparentColor or "#000000",spidey.imgEdit.noBk or false})
            if clip then
                spidey.imgEdit.clip=clip
                spidey.imgEdit.clipWidth=spidey.inp.selection.width
                spidey.imgEdit.clipHeight=spidey.inp.selection.height
                captureWindow:show()
                writetofile('.\\Spidey\\output.gd', spidey.imgEdit.clip)
                emu.message("saved.")
            end
        end
    else
        captureWindow:hide()
    end
end

-- Save font as lua code
function savefont_x(filename, font_table)
    --font={}
    local fontnum
    out='font={}\n'
    out=out.."font['letters']=\"ABCDEFGHIJKLMNOPQRSTUVWXYZ.,?!abcdefghijklmnopqrstuvwxyz-*@#0123456789“”:&''\\".. '"$;           "\n'
    for fontnum= 1,99 do
        if not (font_table[fontnum]) then break end
        out=out..string.format("font[%s]={\n",fontnum)
        if not (font_table[fontnum]['"']) then font_table[fontnum]['"']=font_table[fontnum]['“'] end
        for i = 1, #font_table.letters do
            local c = font_table.letters:sub(i,i)
            --io.input(file)
            if (font_table[fontnum][c]) then
                if (c=="'") then
                    out=out..string.format("['\\%s']=hex2bin('%s'),\n",c, bin2hex(font_table[fontnum][c])  )
                else
                    out=out..string.format("['%s']=hex2bin('%s'),\n",c, bin2hex(font_table[fontnum][c])  )
                end
            end
            --font[c]=io.read('*a')
        end
        out=out:sub(1,#out-2).."\n" --remove last comma
        out=out..'}\n'
    end
    print(out)

    local file = io.open(filename,"w")
    io.output(file)
    io.write(out)
    io.close(file)
end


function showcolor(x,y)
    --emu.getscreenpixel(x,y,true)
    gui.text(8*25, 8*1, string.format('%02X %02X %02X ',emu.getscreenpixel(x,y,true)) ,"white","black")
end

-- Create a gd string from a section of the screen
_palette={}
function gdfromscreen(x,y,w,h,opt)
    if w<1 or h<1 then return nil end
    if not opt then opt={} end
    if opt.transparent==nil then opt.transparent=true end
    if opt.transparentcolor==nil then opt.transparentcolor='#000000' end
    if opt.nobk==nil then opt.nobk=false end
    
    local gdstr=''
    local _mx=x
    local _my=y
    --if opt.nobk then emu.setrenderplanes(true, false); emu.frameadvance() end
    
    -- We're going to mess with the vram and advance it a little so we'll just undo when done.
    save1=savestate.object()
    savestate.save(save1)
    if opt.nobk then
        for _i=0,0x10-1 do
            memory.writebyteppu(0x3f00+_i,0x15)
        end
        emu.frameadvance()
    end
    
    for y = 0, h-1 do
        for x = 0, w-1 do
            local t=0
            local r, g, b=emu.getscreenpixel(_mx+x,_my+y+0,true)
            --if opt.transparent==true and r+g+b==0 then t=0x80 end
            --if opt.transparent==true and r==0xe4 and g==0x00 and b==0x58 then r=0;g=0;b=0;t=0x80 end
            if opt.transparent==true and string.format('#%02X%02X%02X',r,g,b)==opt.transparentcolor then r=0;g=0;b=0;t=0x80 end
            gdstr=gdstr..string.format('%02x%02x%02x%02x',t,r,g,b)
        end
    end
    --if opt.nobk then emu.setrenderplanes(true, true) end
    savestate.load(save1)
    save1=nil
    gdstr=hex2bin('FFFE00'..string.format("%02x", w)..'00'..string.format("%02x", h)..'01'..'FFFFFFFF'..gdstr)
    return gdstr
end


yesno={[true]="yes",[false]="no"}

waitforrelease=false
--Create a button with text and an optional toggle value (shows "on" or "off")
--Call it in a loop, returns true when clicked.
function button(x,y,txt,toggle)
    if input_data.current.mouseidle>80 then return false end
    ret=false
    xw=96
    yw=8
    c="white"
    c2="black"
    if(input_data.current.xmouse>x and input_data.current.xmouse<x+xw and input_data.current.ymouse>y and input_data.current.ymouse<y+yw) then
        c="white"
        c2="blue"
        --if (waitforrelease) then
        --    c="white"
        --    c2="cyan"
        --end
        if input_data.current.leftbutton_press then
        --if (inp.leftclick and waitforrelease==false) then
            c="blue"
            c2="white"
            ret=true
            --waitforrelease=true
        --else
            --if not (inp.leftclick) then waitforrelease=false end
        end
    end
    gui.drawbox(x, y, x+xw, y+yw, c2, c2)
    onoff={[true]="on",[false]="off"}
    --txt=string.format("%s %s", txt, onoff[toggle])
    gui.text(x, y, txt,c,"clear")
    if not (toggle==nil) then
        gui.text(x+xw-16, y, onoff[toggle] ,c,"clear")
    end
    return ret
end


--------------------------------------------------------------------------------
--
-- Create gd image out of an 8x8, 4-color tile in a pattern table
-- Note: I stole this from Neill Corlett's Metroid script and modified it to use a pattern table 
--
function gdTile(ofs,c0,c1,c2,c3,hflip,double)
    local gd = "\255\254\0\008\0\008\001\255\255\255\255"
    if double then gd = "\255\254\0\016\0\016\001\255\255\255\255" end
    --memory.writebyte(0x2001,0x00) -- Turn off rendering
    local v0,v1
    for y=0,7 do
        --local v0 = rom.readbyte(ofs + y    )
        --local v1 = rom.readbyte(ofs + y + 8)
        --local v0 = memory.readbyteppu(ofs + y    )
        --local v1 = memory.readbyteppu(ofs + y + 8)
        memory.writebyte(0x2006,math.floor((ofs+y)/0x100)) -- PPUADDR high byte
        memory.writebyte(0x2006,(ofs + y) % 0x100) -- PPUADDR low byte
        dummy = memory.readbyte(0x2007) -- PPUDATA (discard internal buffer contents)
        v0 = memory.readbyte(0x2007) -- PPUDATA
        memory.writebyte(0x2006,math.floor((ofs+y+8)/0x100)) -- PPUADDR high byte
        memory.writebyte(0x2006,(ofs + y+8) % 0x100) -- PPUADDR low byte
        dummy = memory.readbyte(0x2007) -- PPUDATA (discard internal buffer contents)
        v1 = memory.readbyte(0x2007) -- PPUDATA
        
        local line = ""
        if hflip then
            for x=0,7 do
                local px
                if AND(v1,1) ~= 0 then
                    if AND(v0,1) ~= 0 then
                        v0 = v0 - 128
                        px = c3
                    else
                        px = c2
                    end
                else
                    if AND(v0,1) ~= 0 then
                        px = c1
                    else
                        px = c0
                    end
                end
                line = line .. px
                if double then line = line .. px end
                v1 = math.floor(v1/2)
                v0 = math.floor(v0/2)
            end
        else
            for x=0,7 do
                if v1 >= 128 then
                    v1 = v1 - 128
                    if v0 >= 128 then
                        v0 = v0 - 128
                        px = c3
                    else
                        px = c2
                    end
                else
                    if v0 >= 128 then
                        v0 = v0 - 128
                        px = c1
                    else
                        px = c0
                    end
                end
                line = line .. px
                if double then line = line .. px end
                v1 = v1 * 2
                v0 = v0 * 2
            end
        end
        gd = gd .. line
        if double then gd = gd .. line end
    end
    --memory.writebyte(0x2001,0x1e) -- Turn on rendering
    return gd
end

spidey.nes.palette={[0]=
'#7C7C7C',
'#0000FC',
'#0000BC',
'#4428BC',
'#940084',
'#A80020',
'#A81000',
'#881400',
'#503000',
'#007800',
'#006800',
'#005800',
'#004058',
'#000000',
'#000000',
'#000000',
'#BCBCBC',
'#0078F8',
'#0058F8',
'#6844FC',
'#D800CC',
'#E40058',
'#F83800',
'#E45C10',
'#AC7C00',
'#00B800',
'#00A800',
'#00A844',
'#008888',
'#000000',
'#000000',
'#000000',
'#F8F8F8',
'#3CBCFC',
'#6888FC',
'#9878F8',
'#F878F8',
'#F85898',
'#F87858',
'#FCA044',
'#F8B800',
'#B8F818',
'#58D854',
'#58F898',
'#00E8D8',
'#787878',
'#000000',
'#000000',
'#FCFCFC',
'#A4E4FC',
'#B8B8F8',
'#D8B8F8',
'#F8B8F8',
'#F8A4C0',
'#F0D0B0',
'#FCE0A8',
'#F8D878',
'#D8F878',
'#B8F8B8',
'#B8F8D8',
'#00FCFC',
'#F8D8F8',
'#000000',
'#000000'
}

function spidey.nes.getPaletteData()
    local _palettedata={}
    _palettedata.color_indexed={}
    _palettedata.colorRGB={}
    local _i
    for _i=0,25-1 do
        _palettedata.color_indexed[_i]=memory.readbyteppu(0x3f00+_i)
        _palettedata.colorRGB[_i]=spidey.nes.palette[_palettedata.color_indexed[_i]] or "#000000"
    end
    return _palettedata
end

function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    else
      print(formatting .. v)
    end
  end
end

-- this is just some testing crap for fceux atm.  uses auxlib
function testwindow()
    if not iup then return end
    
    dlg=iup.filedlg{}
    
    --dlg.file="./Spidey/output.gd"
    dlg.file=arg[0]
    --writetofile('.\\Spidey\\output.gd', spidey.imgEdit.clip)
    
    
    dlg:popup()
    
    --[[
    btn1 = iup.button{title = "Save",alignment="ARIGHT"}
    text1 = iup.text{value="hello",expand = "HORIZONTAL"}
    --box = iup.hbox {btn1,btn2; gap=4}
    frame= iup.frame{
        iup.vbox{
            iup.hbox{
                text1,
                btn1;gap=4
            }
        }
    }
    
    btn1.action=function()
        print("Save to "..text1.value)
    end
    
    dlg = iup.dialog{frame; title="Save Capture As...",size="QUARTERxQUARTER"}
    dlg:show()
    ]]--
    
    if true then return end

    --require( "iuplua" )
    --require( "iupluacontrols" )

    --[[
    res, s = iup.GetParam("Title", nil,
        "Enter Lua code to execute: %s\n","")
    ]]--
    
    --[[
    res, prof = iup.GetParam("Title", nil,
        "Give your profession: %l|Teacher|Explorer|Engineer|\n",0)
    ]]--
    
    --[[
    res, age = iup.GetParam("Title", nil,
        "Give your age: %i\n",0)

    if res ~= 0 then    -- the user cooperated!
        iup.Message("Really?",age)
    end
    ]]--
    
    btn1 = iup.button{title = "Click me!"}
    btn2 = iup.button{title = "Click me!"}
    text1 = iup.multiline{expand = "YES"}
    --box = iup.hbox {btn1,btn2; gap=4}
    frame= iup.frame{
        title="IupLabel",
        iup.vbox{
            iup.hbox{
                btn1,
                btn2;gap=4
            },
            text1
        }
    }
    
    dlg = iup.dialog{frame; title="Simple Dialog",size="QUARTERxQUARTER"}

    dlg:show()
    
    btn1.action=function() print(text1.value) end
    --assert(loadstring(s))()
    --iup.Message("Hello!",name)
end

function spidey.cheatEngine.reset()
    spidey.cheatEngine.data={}
    --spidey.cheatEngine.data.last=memory.readbytes(0,spidey.cheatEngine.range)
    spidey.cheatEngine.data.last=nil
    spidey.cheatEngine.data.valid={}
    spidey.cheatEngine.data.numValid=0
    local i
    for i=0,spidey.cheatEngine.range-1 do
        spidey.cheatEngine.data.valid[i]=true
        if FCEU then
            -- ignore zero page, stack, and ram mirrors
            if i<0x0200 or (i>=0x0800 and i<=0x1fff) then spidey.cheatEngine.data.valid[i]=false end
        end
        if spidey.cheatEngine.data.valid[i]==true then
            spidey.cheatEngine.data.numValid=spidey.cheatEngine.data.numValid+1
        end
    end
    --emu.message(string.format("%i possibilities",spidey.cheatEngine.data.numValid))
end

function spidey.cheatEngine.equalTo(value)
    spidey.cheatEngine.data.current=memory.readbytes(0,spidey.cheatEngine.range)
    local i
    spidey.cheatEngine.data.numValid=0
    for i=0,spidey.cheatEngine.range-1 do
        if spidey.cheatEngine.data.valid[i]==true then
            if string.byte(spidey.cheatEngine.data.current,i+1)==value then
                spidey.cheatEngine.data.numValid=spidey.cheatEngine.data.numValid+1
            else
                spidey.cheatEngine.data.valid[i]=false
            end
        end
    end
    emu.message(string.format("%i possibilities",spidey.cheatEngine.data.numValid))
end

function spidey.cheatEngine.add(address, value, active)
    spidey.cheatEngine.cheats[#spidey.cheatEngine.cheats+1]={address=address,value=value,active=active}
end


-- show addresses added as cheats, freeze them if active
function spidey.cheatEngine.show()
    local i
    local cheat
    if #spidey.cheatEngine.cheats==0 then return end
    gui.drawbox(8-4,8+8-4,8*8+4, 8+8*#spidey.cheatEngine.cheats+8+4, spidey.menu.background_color,spidey.menu.background_color)
    for i=1,#spidey.cheatEngine.cheats do
        cheat=spidey.cheatEngine.cheats[i]
        if cheat.active==true then
            memory.writebyte(cheat.address,cheat.value)
        end
        --gui.text(8, 8+8*2+8*i, string.format("%012X %02X",spidey.cheatEngine.cheats[i].address, spidey.cheatEngine.cheats[i].value) ,"white","clear")
        drawfont(8,8+8*i,spidey.menu.font, string.format("%04X %02X",spidey.cheatEngine.cheats[i].address, spidey.cheatEngine.cheats[i].value))
    end
end

-- show possible addresses
--[[
function spidey.cheatEngine.show()
    if not spidey.cheatEngine.data then return end
    if not spidey.cheatEngine.data.current then return end
    
    --spidey.cheatEngine.data.current=memory.readbytes(0,spidey.cheatEngine.range)
    local i
    local y
    
    --gui.drawbox(8,8,8*16, 8*#spidey.cheatEngine.cheats+8, spidey.menu.background_color,spidey.menu.background_color)
    
    y=0
    for i=0,spidey.cheatEngine.range-1 do
        if spidey.cheatEngine.data.valid[i]==true then
            --drawfont(8,8+8*y,spidey.menu.font, string.format("%04X %02X",i, string.byte(spidey.cheatEngine.data.current,i+1)))
            drawfont(8,8+8*y,spidey.menu.font, string.format("%04X %02X",i, memory.readbyte(i)))
            y=y+1
            if y>10 then break end
        end
    end
end
]]--

spidey.cheatEngine.menu={}
spidey.cheatEngine.menu.main={
    [0]={text="Back",action=function()
        spidey.cheatEngine.menuOpen=not spidey.cheatEngine.menuOpen
        spidey.menu.index=0
    end},
    {text="Reset",action=function()
        spidey.cheatEngine.reset()
    end},
    {text="equal to 0",action=function()
        spidey.cheatEngine.equalTo(0)
    end},
    {text="equal to 1",action=function()
        spidey.cheatEngine.equalTo(1)
    end}
}
spidey.cheatEngine.menu.current=spidey.cheatEngine.menu.main

spidey.cheatEngine.menu.main[#spidey.cheatEngine.menu.main+1]={
    text="Results",
    action=function()
        if spidey.cheatEngine.data.numValid==0 then
            emu.message("Error: no results.")
            return
        end
        if not spidey.cheatEngine.data.current then
            spidey.cheatEngine.data.current=memory.readbytes(0,spidey.cheatEngine.range)
        end
        spidey.cheatEngine.menu.possible={}
        y=0
        for i=0,spidey.cheatEngine.range-1 do
            if spidey.cheatEngine.data.valid[i]==true then
                --drawfont(8,8+8*y,spidey.menu.font, string.format("%04X %02X",i, string.byte(spidey.cheatEngine.data.current,i+1)))
                spidey.cheatEngine.menu.possible[y+1]={
                    --text=string.format("%04X %02X",i, memory.readbyte(i)
                    text=string.format("%04X %02X",i, string.byte(spidey.cheatEngine.data.current,i+1)),
                    action=function()
                        v=string.byte(spidey.cheatEngine.data.current,i+1)
                        spidey.cheatEngine.add(i,v,true)
                        --emu.message(string.format("test %04X %02X",i,v))
                    end
                }
                y=y+1
                if y>10 then break end
            end
        end
        spidey.cheatEngine.menu.possible[0]={
            text="back",action=function ()
                spidey.cheatEngine.menu.current=spidey.cheatEngine.menu.main
            end
        }
        spidey.menu.index=0
        spidey.cheatEngine.menu.current=spidey.cheatEngine.menu.possible
    end
}

class "Address" {
    address=0,
    value=0,
    min=0,
    max=255,
    freeze=nil
}
function Address:init(address)
    self.address=address or 0
end
function Address:get(address)
    if address then self.address=address end
    if self.freeze then return self.value end
    self.value=memory.readbyte(self.address)
    return self.value
end
function Address:set(value)
    if value then self.value=value end
    if self.value>self.max then self.value=self.max end
    if self.value<self.min then self.value=self.min end
    memory.writebyte(self.address, self.value)
    return
end
function Address:dec(value)
    self.value=self.value-(value or 1)
end
function Address:inc(value)
    self.value=self.value+(value or 1)
end

class "Menu" {
    x=72,
    y=88,
    center=true,
    background=true,
    index=1,
    items={},
    background_color='#00000080'
}

function Menu:init()
    self.items={}
    spidey.menus[#spidey.menus+1]=self
end

function Menu:show()
    self.visible=true
end
function Menu:hide()
    self.visible=not true
end
function Menu:addItem(t)
    table.insert(self.items, t)
end

function Menu:getIndexFromId(id)
    for i=1,#menu.items do
        if menu.items[i].id==id then
            return i
        end
    end
end

function Menu:addStandard()
    local i
    local t
    
    t={
        {text=function() return string.format('Cheats: %s',prettyValue(cheats.active)) end,
        action=function() cheats.active=not cheats.active end},
        
        {text=function() return string.format('Capture: %s',prettyValue(spidey.imgEdit.capture)) end,
        action=function()
            spidey.imgEdit.capture=not spidey.imgEdit.capture
            spidey.showSelect=spidey.imgEdit.capture
        end},
        
        {text=function() return string.format('Debug: %s',prettyValue(debug.show)) end,
        action=function() debug.show=not debug.show end},
        
        {text=function() return string.format('Mem View: %s',prettyValue(spidey.memoryViewer.visible)) end,
        action=function() spidey.memoryViewer.visible=not spidey.memoryViewer.visible end},
        
        {text=function() return string.format('Mem View type: %s',spidey.memoryViewer.type) end,
        action=function()
            if spidey.memoryViewer.type=="ram" then
                spidey.memoryViewer.type="rom"
            else
                spidey.memoryViewer.type="ram"
            end
        end},
        
        {text=function() return string.format('Palette View: %s',prettyValue(spidey.paletteViewer.visible)) end,
        action=function() spidey.paletteViewer.visible=not spidey.paletteViewer.visible end},
        
        {disabled=true, text=function() return string.format('menu color test %02X',mnu.r or 0) end,
        action=function()
            self.r=math.random(0,#spidey.nes.palette)
            self.background_color=spidey.nes.palette[self.r]
        end}
    }
    
    --[[
    {text="Cheat Engine",
    action=function()
        spidey.cheatEngine.menuOpen=not spidey.cheatEngine.menuOpen
        --spidey.menu.index=0
    end}
    ]]--

    for i = 1,#t do
        if not t[i].disabled then
            table.insert(self.items, t[i])
        end
    end
    
end

function Menu:update()
    if self.visible~=true then return end
    local joypad_data=spidey.joy
    
    if self.items[self.index] and self.items[self.index].disabled then
        self.index=1
    end
    
    -- Handle input (could be better)
    if (joypad_data[1]['up_press'] or (joypad_data[1]['up_press_time'] > 20 and joypad_data[1]['up_press_time'] % 5 ==0)) then
        if self.moveaction then
            self.moveaction()
        end
        self.index=self.index-1
        if self.items[self.index] and self.items[self.index].disabled then
            self.index=self.index-1
        end
        if (self.index<1) then self.index=1 end
    end
    if (joypad_data[1]['down_press'] or (joypad_data[1]['down_press_time'] > 20 and joypad_data[1]['down_press_time'] % 5 ==0)) then
        if self.moveaction then
            self.moveaction()
        end
        self.index=self.index+1
        if self.items[self.index] and self.items[self.index].disabled then
            self.index=self.index+1
        end
        if (self.index>#self.items) then self.index=#self.items end
    end
    if joypad_data[1]['A_press'] or joypad_data[1]['1_press'] then
        self.items[self.index].action()
    end

    -- Draw the menu
    if self.background==true then gui.drawbox(0, 0, spidey.screenWidth-1,spidey.screenHeight-1, self.background_color, self.background_color) end
    
    self.textWidth=0
    
    for i=1,#self.items do
        if type(self.items[i].text)=="function" then
            self.items[i].textf=self.items[i].text
        end
        if self.items[i].textf then
            self.items[i].text=self.items[i].textf()
        end
    end
    
    for i=1,#self.items do
        if #self.items[i].text>self.textWidth then self.textWidth=#self.items[i].text end
    end
    if self.background=="small" then
        gui.drawbox(self.x-16, self.y, self.x+self.textWidth*8+16, self.y+#self.items*8+2*8, self.background_color, self.background_color)
    end
    
    if self.center then
        self.x=math.floor(spidey.screenWidth*.5- (self.textWidth*8)*.5)
    end
    
    self.text=''
    local _i=0
    local y=self.y+8
    local cursorIndex=self.index
    for _i=1,#self.items do
        if (not self.items[_i].condition) or (self.items[_i].condition and self.items[_i].condition()) then
            drawfont(self.x,y,self.font, self.items[_i].text)
            y=y+8
            self.items[_i].disabled=false
        else
            if _i<cursorIndex then cursorIndex=cursorIndex-1 end
            self.items[_i].disabled=true
            --drawfont(self.x,self.y+8*_i,self.font, "X "..self.items[_i].text)
        end
        
    end
    
    -- Display custom cursor image if set, otherwise use a blinking '-'
    if self.cursor_image then
        --gui.gdoverlay(self.x-12,self.y+8*self.index,self.cursor_image)
    else
        if (emu.framecount() % 24>12) then
            --drawfont(self.x-12,self.y+8*self.index,self.font, "-") --cursor
            drawfont(self.x-12,self.y+8*cursorIndex,self.font, "-") --cursor
        end
    end
end

--[[
if spidey.emu.gbx then
    spidey.menu.x=12
    spidey.menu.y=8
elseif spidey.emu.gba then
    spidey.menu.x=12+8*5
    spidey.menu.y=8+8*4
elseif FCEU then
    -- fceux is buggy with text opacity atm.
    -- black looks more nes-ish anyway
    spidey.menu.background_color="black"
end
]]--

spidey.classes.class=class --this isn't actually a class, but the class function itself.
spidey.classes.Address=Address
spidey.classes.Window=Window
spidey.classes.Menu=Menu

spidey.run=function()
    if math and os then
        math.randomseed(os.time())
        math.random() math.random()
    end
    
    --spidey.emu.getTitle()
    
    spidey.inp = input_read()
    spidey.joy = joypad_read()
    
    if spidey.load then spidey.load() end
    while true do
        spidey.emu.getTitle()
        if spidey.game.title~=spidey.game.lastTitle then
            if spidey.titleChange then spidey.titleChange(spidey.game.title) end
        end
        
        spidey.inp = input_read()
        spidey.joy = joypad_read()
        
        gui.text(0,0, "") -- force clear of previous text
        memoryViewerWindow.visible=spidey.memoryViewer.visible
        spidey.paletteViewer.draw()
        spidey.imgEdit.update() -- process image edit stuff, like capturing
        spidey.cheatEngine.show()
        if spidey.update then spidey.update(spidey.inp,spidey.joy) end
        -- draw any windows
        if #spidey.windows>0 then
            for i=1,#spidey.windows do spidey.windows[i]:_draw() end
        end
        -- process any menus
        if #spidey.menus>0 then
            for i=1,#spidey.menus do spidey.menus[i]:update() end
        end
        emu.frameadvance()
    end
    if spidey.unload then spidey.unload() end
end

spidey.imgEdit.captureWindow=captureWindow
spidey.imgEdit.memoryViewerWindow=memoryViewerWindow

--spidey.cheatEngine.reset()

return spidey
