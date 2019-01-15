-- adapted from the standalone script found here:
-- https://forum.speeddemosarchive.com/post/castlevania_ii_simons_quest_collision_box_viewer.html

local hitboxes = {}
local hb = {}

--Toggles
local show_hud = false
local show_elife = false -- enemy life

-- Player
local px = 0x348
local py = 0x324
local pl = 0x80
local ph = 0x48
local pe = 0x46
local pt = 0x85

-- Enemy
local el = 0x4C2
local ex = 0x348
local ey = 0x324
local oob = 0x3C6
local point = 0x3FC

local function hex(val)
    val = string.format("%X",val)
    return val
end

function findbit(p) 
    return 2 ^ (p - 1)
end

function hasbit(x, p) 
    return x % (p + p) >= p 
end


local function formatstring(adr)
    if adr == pt then
        return string.format("%02X:%02X", memory.readbyte(adr+1), memory.readbyte(adr))
    else
        return string.format("%04X", memory.readbyte(adr+1) * 0x100 + memory.readbyte(adr))
    end
end

local function buildbox(i)
    local offset1 = memory.readbyte(0x3B4 + i) * 2
    local pointer1 = rom.readbyte(0x4AD0 + offset1) + (rom.readbyte(0x4AD1 + offset1) * 0x100)
    
    local offset2 = memory.readbyte(0x3FC + i)
    
    if offset2 > 0 then
        offset2 = offset2 - 1
    end
    
--    if i==2+5 then
--    emu.message(string.format("%02x %02x %02x %04x",i, offset1, offset2, pointer1))
--    end
    
    
    local offset3 = rom.readbyte(pointer1 + offset2 - 0x3FF0)
    local offset3 = ((offset3 * 2) + offset3) % 0x100
    local box = { rom.readbytesigned(0x4B8E + offset3), rom.readbyte(0x4B8F + offset3),rom.readbyte(0x4B90 + offset3) } -- yoff/yrad/xrad
    
    return box
end

local function player()
    local x = memory.readbyte(px)
    local y = memory.readbyte(py)
    hb.player = {}
    hb.whip = {}
    
    --gui.box(x - 6,y + 3 - 0x0A,x + 6,y + 3 + 0x0A,"#0000FF40","#0000FFFF")
    hb.player = {
        type = "player",
        color = {"#0000FF40","#0000FFFF"},
        rect={x - 6,y + 3 - 0x0A,x + 6,y + 3 + 0x0A},
    }
    
    -- Whip
    if memory.readbyte(0x445) == 3 then
        local wxoff = 0x16
        local wyoff = -4
        local wxrad
        local wyrad = 4
        local woff = memory.readbyte(0x434)
        if memory.readbyte(0x420) == 0 then
            wxoff = wxoff * -1
        end
        wxrad = rom.readbyte(0x4BED + woff)
        --gui.box(x+wxoff-wxrad,y+wyoff-wyrad,x+wxoff+wxrad,y+wyoff+wyrad,"#FFFFFF40","#FFFFFFFF")
        hb.whip = {
            type = "whip",
            color = {"#FFFFFF40","#FFFFFFFF"},
            rect={x+wxoff-wxrad,y+wyoff-wyrad,x+wxoff+wxrad,y+wyoff+wyrad},
        }
    end


end

local function objects()
    local x 
    local y 
    local l
    local box
    local active
    local fill 
    local outl 
    local isoob
    local etype
    hb.object = {}
    
    for i = 2,19,1 do
        
        active = memory.readbyte(0x3D8 + i)
        isoob = memory.readbyte(oob + i)
        etype = memory.readbyte(0x3B4 +i)
        local index = i-6
        local subType=""
        if etype > 0 and etype ~= 0x43 and etype ~= 0x1E and etype ~= 0x2A then
            box = buildbox(i)
            x = memory.readbyte(ex + i)
            y = memory.readbyte(ey + i)
            l = memory.readbyte(el + i)
            if hasbit(active,findbit(1)) and not hasbit(active,findbit(8)) then  -- Enemy
                if bit.rshift(bit.band(isoob,0xF0),4) ~= 8 and bit.rshift(bit.band(isoob,0xF0),4) ~= 4 then  -- If not offscreen
                    if show_elife == true then
                        gui.text(x-8,y-28,"HP: " .. l)
                    end
                end
                fill = "#FF000040"
                outl = "#FF0000FF"
                subType = "Enemy"
            elseif hasbit(active,findbit(8)) and hasbit(active,findbit(1)) then -- Hidden enemy, no active box
                outl = "#FF000040"
                fill = "#FF000000"
                subType = "Inactive"
                if bit.rshift(bit.band(isoob,0xF0),4) ~= 8 and bit.rshift(bit.band(isoob,0xF0),4) ~= 4 then  -- If not offscreen
                    if show_elife == true then
                        gui.text(x-8,y-28,"HP: " .. l)
                    end
                end
            elseif hasbit(active,findbit(8)) and hasbit(active,findbit(2)) then  -- Simon's projectiles
                outl = "#00FFFFFF"
                fill = "#00FFFF40"
                index = i-3
                subType = "SimonProjectile"
            elseif not hasbit(active,findbit(8)) and hasbit(active,(2)) then -- Enemy projectile
                outl = "#FFFF00FF"
                fill = "#FFFF0040"
                subType = "EnemyProjectile"
            elseif hasbit(active,findbit(8)) and not hasbit(active,findbit(2)) then  -- Inactive box
                outl = 0
                fill = 0
            elseif hasbit(active,findbit(7)) then -- NPC
                outl = "#FF00FFFF"
                fill = "#FF00FF40"
                subType = "NPC"
            elseif hasbit(active,findbit(3)) then -- Item pickups
                outl = "#FFA500FF"
                fill = "#FFA50040"
                subType = "Item"
            end
            if bit.rshift(bit.band(isoob,0xF0),4) ~= 8 and bit.rshift(bit.band(isoob,0xF0),4) ~= 4 then  -- If not offscreen
                --gui.box(x - box[3],y+box[1]+box[2],x+box[3],y+box[1]-box[2],fill,outl)
                hb.object[i] = {
                    type = "object",
                    subType=subType,
                    index = index,
                    color = {fill, outl},
                    rect={x - box[3],y+box[1]+box[2],x+box[3],y+box[1]-box[2]},
                }
            end

        end
        
    end
    
end

hitboxes.draw = function()
    local drawHitBox = function(object)
        if object and object.rect then
            gui.box(object.rect[1],object.rect[2],object.rect[3],object.rect[4],object.color[1],object.color[2])
            --gui.text(object.rect[1],object.rect[2],string.format("%02x",object.index or 0),"white")
        end
    end
    
    drawHitBox(hb.player)
    drawHitBox(hb.whip)
    for i=2,19 do
        drawHitBox(hb.object[i])
    end
    
end

local function HUD()
    local l = memory.readbyte(pl)
    local h = 0
    local e = 0
    local t = 0
    
    -- Hearts
    h = formatstring(ph)
    -- Experience
    e = formatstring(pe)
    -- Time
    t = formatstring(pt)
    
    gui.text(14, 9, l)
    gui.text(256 - 40, 09,"H: " .. h)
    gui.text(256 - 40, 17,"E: " .. e)
    gui.text(256 - 85, 09, "T: " .. t)
end

hitboxes.update = function()
    player()
    objects()
    hitboxes.player = hb.player
    hitboxes.whip = hb.whip
    hitboxes.object = hb.object
end

hitboxes.drawHUD = HUD


return hitboxes