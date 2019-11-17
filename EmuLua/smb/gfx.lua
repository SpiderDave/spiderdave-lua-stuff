local gfx = {isMain = true}
local graphics

gfx.fileList = {}

gfx.gdPath = "images/gd/"
gfx.pngPath = "images/png/"

gfx.init = function(g)
    graphics = g
end

gfx.load = function(f)
    local ext = graphics.getFileExt(f)
    if not ext then
        if graphics.use_gd then
            -- using gd library so we can load stuff like .png
            ext = ".png"
        else
            -- native fceux gd stuff only
            ext = ".gd"
        end
        
        f=f..ext
    end
    gfx.fileList[#gfx.fileList+1]=f
    
    local path = ""
    if ext == ".gd" then
        path = gfx.gdPath
    elseif ext == ".png" then
        path = gfx.pngPath
    end
    local t={}
    t.image = graphics:loadImage(path..f)
    return t
end

gfx.draw = function(x,y,img)
    if type(img)=="string" then
        img = gfx[img]
    end

    if type(img) == "table" then
        graphics:draw(x+(img.xo or 0),y+(img.yo or 0),img.image)
    else
        graphics:draw(x,y,img)
    end
end


return gfx