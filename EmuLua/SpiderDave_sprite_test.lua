local spidey
if not pcall(function()
    spidey=require("Spidey.SpideyStuff")
end) then
    emu.message('Error: Could not load "Spidey.SpideyStuff."')
    do return end
end

--ignoreErrors = true

local useGD=false
local useExtraWindow=true

if useGD then
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
end

local game = {}
local hexGrid

if gd then
    hexGrid = gd.createFromPng("Spidey/hexgrid.png"):gdStr()
    spidey.writeToFile('./Spidey/hexgrid.gd', hexGrid)
else
    hexGrid = spidey.getFileContents("./Spidey/hexgrid.gd")
end

spidey.trackOAM(true)


local label_spriteSize
local label_oamAddress
local label_spriteCount
local label_spritePatternTable
local text_output


if useExtraWindow then
    label_spriteSize = iup.label{size="1000x"}
    label_oamAddress = iup.label{size="1000x"}
    label_spriteCount = iup.label{size="1000x"}
    label_spritePatternTable = iup.label{size="1000x"}
    text_output = iup.multiline{expand = "YES"}

    require("auxlib")

    function testiup()
        -- "handles" and "dialogs" are defined in auxlib
        
        dialogs = dialogs + 1
        
        label1 = iup.label{title = "test"}
        
        handles[dialogs] = iup.dialog{
            title = "Info", size = "QUARTERxQUARTER",
            iup.vbox{
                label_spriteSize,
                label_oamAddress,
                label_spriteCount,
                label_spritePatternTable,
                text_output,
            }
        }
        handles[dialogs]:show()
    end

    testiup()
end

spidey.selection.visible = true

function spidey.update(inp,joy)
    --gui.text(0,8,string.format("%02x %02x %02x",inp.xmouse,inp.ymouse, game.tileNum or 0))
    if game.tileNum then
        gui.text(0,8,string.format("%02x", game.tileNum or 0),"white","black")
    end
--    if inp.leftbutton_click then
--        for i = 0,63 do
--            local x,y = spidey.oam.sprite[i].x, spidey.oam.sprite[i].y+1
--            if x+8>= inp.xmouse and x+8<=inp.xmouse+7 and y+8>=inp.ymouse and y+8<=inp.ymouse+7 then
--                game.tileNum = spidey.oam.sprite[i].tile
--                break
--            end
--        end
--    end
    
    if inp.leftbutton_release then
        spidey.selection.tiles = {}
        if spidey.oam then
            local minX = 10000
            local minY = 10000
            for spriteNum=0,#spidey.oam.sprite do
                local sprite = spidey.oam.sprite[spriteNum]
                if sprite then
                    if sprite.hide then
                        -- pass
                    else
                        local x,y = sprite.x, sprite.y+1
                        for i=0,spidey.oam.spriteSize do
                            if (x>=spidey.selection.x) and (y+8*i>=spidey.selection.y) and (x+8<=spidey.selection.x+spidey.selection.width) and (y+8*i+8<=spidey.selection.y+spidey.selection.height) then
                                spidey.selection.tiles[#spidey.selection.tiles+1] = {
                                    id = sprite.tile+i,
                                    x = x,
                                    y = y+8*i,
                                }
                                if x<minX then minX = x end
                                if y<minY then minY = y end
                            end
                        end
                        spidey.selection.spriteTop = minY
                        spidey.selection.spriteLeft = minX
                    end
                end
            end
        end
    end
    
--    if joy[1].A_press then
--        local sprite
--        for i = 0,63 do
--            if spidey.oam.sprite[i].tile == game.tileNum and (not spidey.oam.sprite[i].hide) then
--                sprite = spidey.oam.sprite[i]
--                break
--            end
--        end
--        if sprite and (not sprite.hide) then
--            local x,y = sprite.x,sprite.y+1
            
--            game.clip=gdfromscreen(x,y,8,8, {transparent=spidey.imgEdit.transparent,transparentcolor=spidey.imgEdit.transparentColor or "#000000",nobk=true})

--            spidey.imgEdit.clip = clip
--        end
--    end
    if game.clip then
        gui.gdoverlay(16,16, game.clip)
    end
end

function spidey.draw()
    if spidey.oam then
        if useExtraWindow then
            if spidey.oam.spriteSize == 1 then
                label_spriteSize.title = "Sprite Size: 8x16"
            else
                label_spriteSize.title = "Sprite Size: 8x8"
            end
            label_oamAddress.title = string.format("OAM address: 0x%04x",spidey.oam.address * 0x100)
            label_spriteCount.title = string.format("Sprite count: 0x%02x",spidey.oam.sprite.count)
            label_spritePatternTable.title = string.format("Sprite pattern table address: 0x%04x",(spidey.oam.sprite.patternTable) * 0x1000)
        end
        
        for spriteNum=0,#spidey.oam.sprite do
            local sprite = spidey.oam.sprite[spriteNum]
            if sprite then
                local x,y = sprite.x, sprite.y+1
                if sprite.hide then
                    -- pass
                else
                    if hexGrid then
                        for i=0,spidey.oam.spriteSize do
                            local sx, sy = spidey.gridPos(sprite.tile+i)
                            sx = sx * 8
                            sy = sy * 8
                            if spidey.selection.width then
                                if (x>=spidey.selection.x) and (y+8*i>=spidey.selection.y) and (x+8<=spidey.selection.x+spidey.selection.width) and (y+8*i+8<=spidey.selection.y+spidey.selection.height) then
                                    gui.drawimage(x,y+8*i, hexGrid, sx,sy, 8,8)
                                end
                            else
                                gui.drawimage(x,y+8*i, hexGrid, sx,sy, 8,8)
                            end
                        end
                    else
                        gui.drawrect(x,y, x+7,y+7, "clear", "red")
                        gui.text(x,y, string.format("%02x",sprite.tile),"white","clear")
                    end
                end
            end
        end
    end

    if spidey.selection.tiles then
        local txt=""
        --txt = txt .. string.format("0x%04x\n",spidey.oam.sprite.patternTable * 0x1000)
        
        
        txt = txt .. string.format("//OAM address: 0x%04x\n",spidey.oam.address * 0x100)
        txt = txt .. string.format("//Sprite count: 0x%02x\n",spidey.oam.sprite.count)
        txt = txt .. string.format("//Sprite pattern table address: 0x%04x\n",spidey.oam.sprite.patternTable * 0x1000)

        
        txt = txt .. "start tilemap test\n    gridsize = 1\n"
        txt = txt .. "    address = %CHRSTART%\n"
        for k,v in ipairs(spidey.selection.tiles) do
            txt = txt..string.format("    %02x %02x %02x\n",v.id, v.x-spidey.selection.spriteLeft,v.y-spidey.selection.spriteTop)
        end
        txt = txt.."end tilemap"
        if spidey.inp.leftbutton_release and useExtraWindow then
            text_output.value = txt
        end
        --gui.drawrect(0,0, 16+8*24,16+8*20, "#111111b0", "black")
        --gui.text(8,16, txt,spidey.nes.palette[0x2c],"clear")
        --spidey.writeToFile("Spidey/tilemap_output.txt", txt)
    end

end

spidey.run()