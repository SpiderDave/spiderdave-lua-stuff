-- 
-- Author: SpiderDave
--
-- Primarily for FCEUX, but I want to make it more generic, 
-- starting with limited support for VBA.
--

local class
--function class(name)
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
    version="2012.12.25",
    emu={},
    Menu={},
    game={},
    nes={},  -- nes-specific stuff.  Note that it's seperate because we still want it available on other platforms (how about a script to map snes games to nes palettes for example?).
    classes={},
    debug={
        showinput=nil
    },
    memoryViewer={visible=false},
    cheatEngine={
        enabled=true,
        active=true,
        cheats={},
        range=0x10000,
        data={
            last=nil,valid={},numValid=0
        }
    }
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
            spidey.game.title=spidey.game.title .. string.char(memory.readbyte(0x08000000+0x0ac+i))
        end
        spidey.game.vendor=""
        for i=0,1 do
            spidey.game.title=spidey.game.title .. string.char(memory.readbyte(0x08000000+0x0b0+i))
        end
    else
        spidey.screenWidth=160
        spidey.screenHeight=144
    end

elseif (snes9x) then
    -- Note: I don't know how to identify snes9x yet, so we'll have
    -- to set snes9x=true before importing this
    --
    -- Snes9x uses memory.read to read from ROM
    rom=memory
    -- .get and .set seem to be more standard; we should avoid read/write but
    -- this is a convenience for now.
    --input.read=input.get
    --input.write=input.set
    --joypad.read=joypad.get
    --joypad.write=joypad.set
    spidey.emu.button_names={'up','down','left','right','A','B','Y','X','L','R','select','start'}
    
    spidey.game.title=''
    for i = 0, 14 do
        spidey.game.title=spidey.game.title .. string.char(memory.readbyte(0xffc0+i))
    end

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
--
input_data={['current']=input.get()}
function input_read()
    input_data['old']=input_data.current
    input_data.current=input.get()
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

    if input_data.showselect and input_data.current.leftclick then
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
    else
        input_data.showselect=nil
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
    local _address,x,y
    
    x=spidey.memoryViewer.x or 8
    y=spidey.memoryViewer.y or 8
    
    _address=spidey.memoryViewer.address or 0
    
    gui.drawbox(x-1, y+8-1, x+8*6*5+1, y+8*17, "black", "black")
    for j=0,5-1 do
        for i=0,16-1 do
            --_address=address+j*(16*0x20)+0x20*i
            _address=_address+1
            gui.text(x+8*(6*j), y+8*(1+i), string.format('%X %02X  ',_address, memory.readbyte(_address)) ,"white","black")
        end
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


function spidey.nes.getPaletteData()
    local _palettedata={}
    _palettedata.color_indexed={}
    local _i
    for _i=0,25-1 do
        _palettedata.color_indexed[_i]=memory.readbyteppu(0x3f00+_i)
    end
    return _palettedata
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

spidey.menu={
x=72,
y=88,
center=true,
background=true,
index=0,
items={},
background_color='#00000080',

doinput=function()
    if (joypad_data[1]['up_press'] or (joypad_data[1]['up_press_time'] > 20 and joypad_data[1]['up_press_time'] % 5 ==0)) then
        if spidey.menu.moveaction then
            spidey.menu.moveaction()
        end
        spidey.menu.index=spidey.menu.index-1
        if (spidey.menu.index<0) then spidey.menu.index=0 end
    end
    if (joypad_data[1]['down_press'] or (joypad_data[1]['down_press_time'] > 20 and joypad_data[1]['down_press_time'] % 5 ==0)) then
        if spidey.menu.moveaction then
            spidey.menu.moveaction()
        end
        spidey.menu.index=spidey.menu.index+1
        if (spidey.menu.index>#spidey.menu.items) then spidey.menu.index=#spidey.menu.items end
    end
    if joypad_data[1]['A_press'] or joypad_data[1]['1_press'] then
        spidey.menu.items[spidey.menu.index].action()
    end
end,

show=function()
    if spidey.menu.background==true then gui.drawbox(0, 0, spidey.screenWidth-1,spidey.screenHeight-1, spidey.menu.background_color, spidey.menu.background_color) end
    
    spidey.menu.textWidth=0
    for i=0,#spidey.menu.items do
        if #spidey.menu.items[i].text>spidey.menu.textWidth then spidey.menu.textWidth=#spidey.menu.items[i].text end
    end
    --[[
    if spidey.menu.background=="small" then
        local _i=0
        local w=0
        for _i=0,#spidey.menu.items do
            if #spidey.menu.items[_i].text>w then w=#spidey.menu.items[_i].text end
        end
        gui.drawbox(spidey.menu.x-16, spidey.menu.y-8, spidey.menu.x+w*8+16, spidey.menu.y+#spidey.menu.items*8+2*8, spidey.menu.background_color, spidey.menu.background_color)
    end
    ]]--
    if spidey.menu.background=="small" then
        gui.drawbox(spidey.menu.x-16, spidey.menu.y-8, spidey.menu.x+spidey.menu.textWidth*8+16, spidey.menu.y+#spidey.menu.items*8+2*8, spidey.menu.background_color, spidey.menu.background_color)
    end
    
    if spidey.menu.center then
        spidey.menu.x=math.floor(spidey.screenWidth*.5- (spidey.menu.textWidth*8)*.5)
    end
    
    spidey.menu.text=''
    local _i=0
    for _i=0,#spidey.menu.items do
        drawfont(spidey.menu.x,spidey.menu.y+8*_i,spidey.menu.font, spidey.menu.items[_i].text)
    end
    
    -- Display custom cursor image if set, otherwise use a blinking '-'
    if spidey.menu.cursor_image then
        gui.gdoverlay(spidey.menu.x-12,spidey.menu.y+8*spidey.menu.index,spidey.menu.cursor_image)
    else
        if (emu.framecount() % 24>12) then
            drawfont(spidey.menu.x-12,spidey.menu.y+8*spidey.menu.index,spidey.menu.font, "-") --cursor
        end
    end
end
}
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

spidey.classes.class=class --this isn't actually a class, but the class function itself.
spidey.classes.Address=Address

spidey.frameadvance=function()
    emu.frameadvance()
    spidey.memoryViewer.draw()
    spidey.cheatEngine.show()
end



-- Depreciated stuff, for backwards compatability.
showmem=function() gui.text(16,16, "Error: update script for new memory viewer format.") end
showMem=showmem
emu_data=spidey.emu
game_title=spidey.game.title
nespalette=spidey.nes.palette
getpalettedata = spidey.nes.getPaletteData
menu=spidey.menu


--spidey.cheatEngine.reset()

return spidey
