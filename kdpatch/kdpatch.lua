version='kdpatch v1.2 by SpiderDave'

function BARF(errortext)
  print(errortext)
  os.exit()
end

function startsWith(haystack, needle)
  return string.sub(haystack, 1, string.len(needle)) == needle
end

function getfilecontents(path)
    local file = io.open(path,"rb")
    if file==nil then return nil end
    io.input(file)
    ret=io.read('*a')
    io.close(file)
    return ret
end

function setfilecontents(file, data)
    local f,err = io.open(file,"w")
    if err then print(err) end
    if not f then return nil end
    f:write(data)
    f:close()
    return true
end

function writeToFile(file,address, data)
    if not data then return nil end
    local f = io.open(file,"r+b")
    if not f then return nil end
    f:seek("set",address)
    f:write(data)
    f:close()
    return true
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

function makepointer(addr,returnbinary)
    local a,p,pbin
    returnbinary=returnbinary or nil
    a=string.format("%08X",addr)
    p=string.sub(a,7,8)..string.sub(a,5,6)..'4'..string.sub(a,4,4)..string.sub(a,1,2)
    pbin=hex2bin(p)
    p=tonumber(p,16)
    if returnbinary then return pbin else return p end
end

function jistxt(str)
    out=''
    for i=1,#str do
        local c=string.byte(str:sub(i,i))
        if c==string.byte('|') then
            out=out..'00'
        elseif c==string.byte(' ') then
            out=out..'8140'
        elseif c==string.byte('!') then
            out=out..'8149'
        elseif c==string.byte('?') then
            out=out..'8148'
        elseif c==string.byte('%') then
            out=out..'8193'
        elseif c==string.byte('/') then
            out=out..'815e'
        elseif c==string.byte(':') then
            out=out..'8146'
        elseif c==string.byte('&') then
            out=out..'8195'
        elseif c>=string.byte('0') and c<=string.byte('9') then
            out=out..string.format("82%02x", c+0x1f)
        elseif c>=0x41 and c<=0x5a then
            out=out..string.format("82%02x", c+0x1f)
        elseif c>=0x61 and c<=0x7a then
            out=out..string.format("82%02x", c+0x20)
        else
            out=out..string.format("%02x", c)
        end
    end
    return hex2bin(out)
end

patchfile = arg[1]
file=arg[2]
if not arg[1] or not arg[2] or arg[3] then
    BARF(version.."\n\nUsage: kdpatch <patch file> <file to patch>\n  Example: kdpatch patch.txt KD.exe")
end

file_dumptext = nil
filedata=getfilecontents(file)
jistext={}
repointer=nil
repointer_base=nil

local patchfile = io.open("patch.txt","r")
while true do
local line = patchfile:read("*l")
    if line == nil then break end
    if startsWith(line, 'repointer') then
        repointer=true
        local data=string.sub(line,11)
        local address = data:sub(1,(data:find(' ')))
        address = tonumber(address, 16)
        repointer_base=address
    elseif startsWith(line, 'jistext ') then
        local data=string.sub(line,9)
        local address = data:sub(1,(data:find(' ')))
        address = tonumber(address, 16)
        txt=data:sub((data:find(' ')+1))
        if repointer then
            print(string.format("Waiting to repointer s-jis text: 0x%08x: %s",address,txt))
        else
            print(string.format("Setting s-jis text: 0x%08x: %s",address,txt))
            if not writeToFile(file, address,jistxt(txt)) then BARF("Error: Could not write to file.") end
        end
        
        ter=hex2bin('0000')
        pos,pos2=string.find(filedata, ter,address+1,true)
        oldtext=string.sub(filedata, address+1,pos2-2)
        oldtext=string.gsub(oldtext, "%z", '<br>\n')
        asciitext=string.gsub(txt,'||', '')
        asciitext=string.gsub(asciitext,'|', '<br>\n')
        
        table.insert(jistext,{
            address=address,
            txt=jistxt(txt),
            asciitext=asciitext,
            oldtext=oldtext
        })
    elseif startsWith(line, 'text ') then
        local data=string.sub(line,6)
        local address = data:sub(1,(data:find(' ')))
        address = tonumber(address, 16)
        txt=data:sub((data:find(' ')+1))
        print(string.format("Setting ascii text: 0x%08x: %s",address,txt))
        txt=string.gsub(txt, "|", string.char(0))
        if not writeToFile(file, address,txt) then BARF("Error: Could not write to file.") end
    elseif startsWith(line, 'hex ') then
        local data=string.sub(line,5)
        local address = data:sub(1,(data:find(' ')))
        address = tonumber(address, 16)
        txt=data:sub((data:find(' ')+1))
        print(string.format("Setting hex bytes: 0x%08x: %s",address,txt))
        if not writeToFile(file, address,hex2bin(txt)) then BARF("Error: Could not write to file.") end
    elseif startsWith(line, 'dumpfonttable ') then
        local data=string.sub(line,15)
        local address = data:sub(1,(data:find(' ')))
        address = tonumber(address, 16)
        txt=data:sub((data:find(' ')+1))
        
        
        chardata ='<html><head><meta http-equiv="Content-Type" content="text/html; charset=shift-jis"></head><body><div style="font-size:16pt"><pre>'
        for i=0,255 do
            if bin2hex(string.sub(filedata, address+i*3+1,address+i*3+1+1))=='0000' then break end;
            --chardata=chardata..bin2hex(string.sub(filedata, address+i*3+1,address+i*3+1+1))
            chardata=chardata..string.format('%02X = %s ',i,bin2hex(string.sub(filedata, address+i*3+1,address+i*3+1+1)))
            chardata=chardata..string.sub(filedata, address+i*3+1,address+i*3+1+1)
            chardata=chardata.."\n"
        end
        chardata =chardata..'</pre></div></body></html>'
        --print(txt)
        if not setfilecontents(txt,chardata) then BARF("Error: Could not write to file.") end
        print(string.format("Font table dumped to file %s",txt))
        
        --print(string.format("Setting hex bytes: 0x%08x: %s",address,txt))
        --if not writeToFile(file, address,hex2bin(txt)) then BARF("Error: Could not write to file.") end
    elseif startsWith(line, 'dumpjistext ') then
        local data=string.sub(line,13)
        file_dumptext = data:sub(1,(data:find(' ')))
    end
end
patchfile:close()
print('\n')

repointer_pos=repointer_base

for i = 1, #jistext do
    p=makepointer(jistext[i].address)
    pbin=makepointer(jistext[i].address,true)
    
    --print(string.format("%08X <- %08X",jistext[i].address,p))
    pos=1
    while pos do
        pos,pos2=string.find(filedata, pbin,pos,true)
        if pos then
            print(string.format("Pointer to %08X found at %08X",jistext[i].address,pos-1))
            --print(string.format('%08X',pos-1))
            
            if repointer then
                newpointer=makepointer(repointer_pos)
                newpointerbin=makepointer(repointer_pos,true)
                if not writeToFile(file, repointer_pos, jistext[i].txt ) then BARF("Error: Could not write to file.") end
                if not writeToFile(file, pos-1,newpointerbin) then BARF("Error: Could not write to file.") end
                print(string.format("Moving pointer and applying data to %08X",repointer_pos))
                repointer_pos=repointer_pos+#jistext[i].txt
            end
            pos=pos2
        end
    end
    
end

if file_dumptext then
    chardata ='<html><head><meta http-equiv="Content-Type" content="text/html; charset=shift-jis"></head><body><div style="font-size:16pt">'
    for i = 1, #jistext do
        chardata=chardata..jistext[i].oldtext.."<br>\n"
        chardata=chardata..jistext[i].asciitext
        chardata=chardata.."<br><br>\n"
    end
    chardata =chardata..'</div></body></html>'
    if not setfilecontents(file_dumptext,chardata) then BARF("Error: Could not write to file.") end
    print(string.format("text dumped to file %s",file_dumptext))
end


print('done.')


