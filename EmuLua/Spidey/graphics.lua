--Wrap either cairo (recommended) or gd

local getFileExt = function(url)
    local str = url
  local temp = ""
  local result = "." -- ! Remove the dot here to ONLY get the extension, eg. jpg without a dot. The dot is added because Download() expects a file type with a dot.

  for i = str:len(), 1, -1 do
    if str:sub(i,i) ~= "." then
      temp = temp..str:sub(i,i)
    else
      break
    end
  end

  -- Reverse order of full file name
  for j = temp:len(), 1, -1 do
    result = result..temp:sub(j,j)
  end
  if result=="."..url then result = false end
  return result
end

local gd
local cairo
local CAIRO

local graphics = {
    default = "gd",
    modes = {"cairo", "gd"},
    requirePath = "",
}

function graphics:init(m)
    m=m or self.mode or self.default
    self["mode"] = m --if I write this as self.mode then it breaks syntax highlighting of Notepad3.
    if m=="gd" then
        if self.use_gd then
            self.use_cairo = false
            return
        else
            if gd then self.use_gd = true return end
            if not pcall(function()
                gd = require(self.requirePath.."gd")
                self.use_gd = true
                self.use_cairo = false
            end) then
                gd = false
            end
        end
    elseif m=="cairo" then
        if self.use_cairo then
            self.use_gd = false
            return
        else
            if cairo then self.use_cairo = true return end
            if not pcall(function()
                cairo = require(self.requirePath.."lcairo")
                CAIRO = cairo
                self.use_cairo = true
                self.use_gd = false
            end) then
                cairo = false
                CAIRO = cairo
            end
        end
    end
    if cairo or gd then
        return true
    else
        --err("could not load gd or cairo")
    end
end

function graphics:getPixel(image, x,y)
    self:init()
    if self.use_cairo then
        local data = cairo.image_surface_get_data(image.cs)
        local f = cairo.image_surface_get_format(image.cs)
        local w = cairo.image_surface_get_width(image.cs)
        local h = cairo.image_surface_get_height(image.cs)
        local stride = cairo.image_surface_get_stride(image.cs)
        --local c = bin2hex(data:sub(y*stride+x*4+1,y*stride+x*4+4))
        local b = data:sub(y*stride+x*4+1,y*stride+x*4+1):byte()
        local g = data:sub(y*stride+x*4+2,y*stride+x*4+2):byte()
        local r = data:sub(y*stride+x*4+3,y*stride+x*4+3):byte()
        local a = data:sub(y*stride+x*4+4,y*stride+x*4+4):byte()
        return r,g,b,a
    elseif self.use_gd then
        local c = image:getPixel(x,y)
        local r,g,b=image:red(c),image:green(c),image:blue(c)
        return r,g,b,0xff
    end
end

function graphics:setPixel(image, x,y,r,g,b)
    local cs, cr
    self:init()
    if self.use_cairo then
        cr=image.cr
        cairo.rectangle(cr, x, y, 1, 1)
        cairo.set_source_rgb(cr, r/256,g/256,b/256)
        cairo.fill(cr)
    elseif self.use_gd then
        local c = image:colorResolve(r,g,b)
        image:setPixel(x,y, c)
    end
end

function graphics:createImage(w,h)
    local cs, cr
    self:init()
    local image
    if self.use_cairo then
        --cs = cairo.image_surface_create(CAIRO.FORMAT_RGB24, w, h)
        cs = cairo.image_surface_create(CAIRO.FORMAT_ARGB32, w, h)
        if not cs then
            return false
        end
        cr = cairo.create(cs)
        
        cairo.rectangle(cr, 0,0, w,h)
        cairo.set_source_rgb(cr, 0, 0, 0)
        cairo.fill(cr)
        
        image = {cs=cs,cr=cr}
    elseif self.use_gd then
        image=gd.createTrueColor(w,h)
    end
    return image
end


function graphics:loadPng(fileName, w,h)
    local cs, cr
    self:init()
    
    local image
    if self.use_cairo then
        
       -- make sure the file exists.  the program 
       -- crashes even with pcall below on an empty file.
       local f=io.open(fileName,"r")
       if f~=nil then io.close(f) else return end
        
        if pcall(function()
            cs = cairo.image_surface_create_from_png(fileName)
            cr = cairo.create(cs)
            image = {cs=cs,cr=cr}
        end) then
            return image
        else
            return
        end
        
    elseif self.use_gd then
        image = gd.createFromPng(fileName)
        image:saveAlpha(true)
        --image:alphaBlending(false)
    end
    return image
end

function graphics:loadGd(filename)
    local image
    if self.use_gd then
        image = gd.createFromGd(filename) 
    else
        image = getfilecontents(filename)
    end
    return image
end

function graphics:loadImage(filename)
    local ext= getFileExt(filename)
    if ext == ".gd" then return graphics:loadGd(filename) end
    if ext == ".png" then return graphics:loadPng(filename) end
    return false
end


function graphics:savePng(image, fileName)
    self:init()
    
    if self.use_cairo then
        cairo.surface_write_to_png(image.cs, fileName)
    elseif self.use_gd then
        image:png(fileName)
    end
end

function graphics:copy(dest, source, sourceX,sourceY, w, h, destX, destY)
    self:init()
    if self.use_cairo then
--        cairo.rectangle(dest.cr, destX,destY, w,h)
--        cairo.set_source_rgb(dest.cr, 0, 0, 0)
--        cairo.fill(dest.cr)

--        cairo.set_source_surface(dest.cr, source.cs, destX,destY)
--        cairo.rectangle(source.cr, sourceX,sourceY,w,h)
--        cairo.fill(dest.cr)


--        cairo.set_source_surface(dest.cr, source.cs, sourceX,sourceY)
--        cairo.rectangle(source.cr, sourceX,sourceY,w,h)
--        cairo.fill(dest.cr)
        
        local r,g,b,a
        a=0xff;
        
        for y=0,h-1 do
            for x=0,w-1 do
                r,g,b = graphics:getPixel(source,sourceX+x,sourceY+y)
                graphics:setPixel(dest,destX+x,destY+y,r,g,b)
            end
        end
        
    elseif self.use_gd then
        gd.copy(dest, source, destX,destY,sourceX,sourceY, w, h)
    end
end

function graphics:getSize(image)
    self:init()
    local w,h
    if self.use_cairo then
        w = cairo.image_surface_get_width(image.cs)
        h = cairo.image_surface_get_height(image.cs)
    elseif self.use_gd then
        w,h = image:sizeXY()
    end
    return w,h
end


function graphics:makeGdString(image)
    if not image then return end
    
    local data = cairo.image_surface_get_data(image.cs)
    local f = cairo.image_surface_get_format(image.cs)
    local stride = cairo.image_surface_get_stride(image.cs)

    local x = 0
    local y = 0
    local w,h = graphics:getSize(image)
    
    do
        local black = hex2bin("000000")
        local clear = hex2bin("80")
        local solid = hex2bin("00")
        local d2=''
        for y = 0, h-1 do
            for x = 0, w-1 do
                local c = data:sub(y*stride+x*4+1,y*stride+x*4+3):reverse()
                if c==black then
                    a=clear
                else
                    a=solid
                end
                d2=d2..a..c
            end
        end
        return hex2bin('FFFE'..string.format("%04x%04x", w,h)..'01'..'FFFFFFFF')..d2
    end


    if not opt then opt={} end
    if opt.transparent==nil then opt.transparent=true end
    if opt.transparentcolor==nil then opt.transparentcolor='#000000' end
    if opt.nobk==nil then opt.nobk=false end
    
    local gdstr=''
    local _mx=x
    local _my=y
    
    for y = 0, h-1 do
        for x = 0, w-1 do
            local t=0
            --local r,g,b = graphics:getPixel(image,_mx+x,_my+y+0)
            
            local b = data:sub(y*stride+x*4+1,y*stride+x*4+1):byte()
            local g = data:sub(y*stride+x*4+2,y*stride+x*4+2):byte()
            local r = data:sub(y*stride+x*4+3,y*stride+x*4+3):byte()
            --local a = data:sub(y*stride+x*4+4,y*stride+x*4+4):byte()
            
            --e40058
            --if opt.transparent==true and r+g+b==0 then t=0x80 end
            --if opt.transparent==true and r==0xe4 and g==0x00 and b==0x58 then r=0;g=0;b=0;t=0x80 end
            opt.transparentcolor=string.format('#%02X%02X%02X',0Xe4,0x00,0x58)
            
            opt.transparent = true
            opt.transparentcolor=string.format('#%02X%02X%02X',0x00,0x00,0x00)
            
            if opt.transparent==true and string.format('#%02X%02X%02X',r,g,b)==opt.transparentcolor then r=0;g=0;b=0;t=0x80 end
            gdstr=gdstr..string.format('%02x%02x%02x%02x',t,r,g,b)
        end
    end
    gdstr=hex2bin('FFFE'..string.format("%04x%04x", w,h)..'01'..'FFFFFFFF'..gdstr)
    return gdstr
end

function graphics:text(image, txt)
    self:init()
    
    if self.use_cairo then
        local w, h = graphics:getSize(image)
        local cr = image.cr
        cairo.set_antialias(cr, CAIRO.ANTIALIAS_NONE)
        
        cairo.select_font_face(cr, "Sans", CAIRO.FONT_SLANT_NORMAL, CAIRO.FONT_WEIGHT_BOLD)
        cairo.set_font_size(cr, 60)
        
        --cairo.set_source_rgb(cr, 1,1,1)
        cairo.set_source_rgb(cr, 1,1,1)
        cairo.move_to(cr, 0, 60)
        
        cairo.text_path(cr, txt)
        cairo.fill_preserve(cr)
        cairo.set_line_width(cr, 2.56)
        cairo.fill (cr)
        
    elseif self.use_gd then
    end
end

function graphics:draw(x,y,img)
    if type(self)=="number" then
        emu.message('error: use "graphics:draw" not "graphics.draw".')
        return false
    end
    
    if type(img)=="userdata" then
        img=img:gdStr()
    elseif type(img)=="string" then
        -- gdstr, pass
    else
        --emu.message("error")
        gui.drawtext(x,y,"X","red","clear")
        --emu.message(type(img))
        return false
    end
    gui.gdoverlay(x,y,img)
end


-- expose these for direct usage
graphics.cairo = cairo
graphics.gd = gd

graphics.getFileExt = getFileExt

return graphics