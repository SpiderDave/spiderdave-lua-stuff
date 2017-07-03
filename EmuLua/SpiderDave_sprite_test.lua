local spidey
if not pcall(function()
    spidey=require("Spidey.SpideyStuff")
end) then
    emu.message('Error: Could not load "Spidey.SpideyStuff."')
    do return end
end

--ignoreErrors = true

if not pcall(function()
    require "gd"
end) then
    if ignoreErrors then
        --pass
    else
        spidey.error = function()
            gui.drawrect(0,8,spidey.screenWidth-1,spidey.screenHeight-1, "#00000080")
            gui.text(0+8*2, 8+8*10, "Error: gd not loaded.\n\nWindows: Put the lua-GD .dll files in the FCEUX \nfolder, and restart FCEUX.","white","clear")
        end
    end
end

local game = {}
local hexGrid

if gd then
    hexGrid = gd.createFromPng("Spidey/hexgrid.png"):gdStr()
end

spidey.trackOAM(true)

function spidey.draw()
    if spidey.oam then
        for _,sprite in pairs(spidey.oam.sprite) do
            if sprite then
                sprite.hide = false
                local x,y = sprite.x, sprite.y+1
                if x>=0xf9 then sprite.hide = true end
                if y>=0xef+1 then sprite.hide = true end
                if sprite.hide then
                else
                    if hexGrid then
                        local sy = math.floor(sprite.tile / 16)
                        local sx = (sprite.tile - (sy*16))
                        sx = sx * 8
                        sy = sy * 8
                        gui.drawimage(x,y, hexGrid, sx,sy, 8,8)
                        gui.drawimage(x,y+8, hexGrid, sx+8,sy, 8,8)
                    else
                        gui.drawrect(x,y, x+7,y+7, "clear", "red")
                        gui.text(x,y, string.format("%02x",sprite.tile),"white","clear")
                    end
                end
            end
        end
    end
end

spidey.run()