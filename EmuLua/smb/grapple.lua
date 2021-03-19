local grapple = {
    counter=0,
    default={
        swingSpeed=.05,
        throwSpeed=3.7,
        range = 180,
    }
}

local distance = function( x1, y1, x2, y2 )
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt ( dx * dx + dy * dy )
end

function grapple.throw(x,y,direction)
    grapple.throwSpeed = grapple.default.throwSpeed
    grapple.x,grapple.y = x,y
    grapple.direction = direction
    grapple.xs = grapple.throwSpeed * -direction *1.5
    grapple.ys = -grapple.throwSpeed
    grapple.state = "throw"
    grapple.counter = 0
end

function grapple.pressButton()
    grapple.button = true
end

function grapple.detach()
    grapple.state = nil
end

grapple.init = function(t)
    for k,v in pairs(t) do
        grapple[k] = t[k]
    end
end

function grapple.update(px, py,facing)
    grapple.lastState = grapple.state
    grapple.range = grapple.range or grapple.default.range
    --spidey.message("%s %d %d %d %d",grapple.state or "nil", grapple.xs or 0,grapple.ys or 0, grapple.x or 0, grapple.y or 0)
    
    if (not grapple.state) and grapple.button then
         grapple.throw(px+8,py+16,-facing)
    end
    
    if grapple.state == "throw" and grapple.counter>0 then
        
        local ScreenEdge_X_Pos = memory.readbyte(0x71c)
        
        local x = grapple.x - grapple.getScrollX()
        local y = grapple.y-0x100
        x = math.floor((x+ScreenEdge_X_Pos % 16)/16)
        y = math.floor(y/16)
        
        local t = grapple.smb.getMetaTileXY(x, y)
        
        if (t and (t.byte ~=0 and t.byte~=2)) or y<0 then
        --if grapple.button then
            grapple.state = "attached"
            grapple.x2 = px
            grapple.y2 = py
            grapple.counter=0
            grapple.direction=-facing
            grapple.swingSpeed = grapple.default.swingSpeed
        end
        
        grapple.x = grapple.x+grapple.xs
        grapple.y = grapple.y+grapple.ys
        
        if distance(px,py,grapple.x,grapple.y)>grapple.range then
            grapple.detach()
        end
    elseif grapple.state == "attached" then
        grapple.xs = 0
        grapple.ys = 0

        local f = function(px,py, ox,oy, angle)
            local x = math.cos(angle) * (px-ox) - math.sin(angle) * (py-oy) + ox
            local y = math.sin(angle) * (px-ox) + math.cos(angle) * (py-oy) + oy
            return x,y
        end
        
        local newx,newy = f(grapple.x2, grapple.y2, grapple.x, grapple.y, grapple.direction*grapple.swingSpeed*grapple.counter)
        grapple.lastNewX = grapple.newX or newx
        grapple.lastNewY = grapple.newY or newy
        grapple.newX = newx
        grapple.newY = newy
        
        grapple.xs = (grapple.newX-grapple.lastNewX)*12
        grapple.ys = (grapple.newY-grapple.lastNewY)*1.5
        
        -- reel it in
        --grapple.x2 = grapple.x2 - (grapple.x2-grapple.x)*.03
        --grapple.y2 = grapple.y2 - (grapple.y2-grapple.y)*.03
        
        if grapple.updatePlayerPosition then
            grapple.updatePlayerPosition(newx,newy)
        end
        
        if grapple.button then grapple.detach() end
        
        
        if px-grapple.getScrollX() >= 240-0x10 then
            grapple.detach()
        end
        
    end
    grapple.button = false
    
    if grapple.state then grapple.draw(px,py) end
    grapple.counter = grapple.counter + 1
end

grapple.getScrollX = function()
    local ScreenEdge_X_Pos = memory.readbyte(0x71c)
    local ScreenEdge_PageLoc = memory.readbyte(0x71a)
    local scrollX = ScreenEdge_PageLoc *0x100 + ScreenEdge_X_Pos
    return scrollX
end

function grapple.draw(px,py)
    local ScreenEdge_X_Pos = memory.readbyte(0x71c)
    local ScreenEdge_PageLoc = memory.readbyte(0x71a)
    local scrollX = ScreenEdge_PageLoc *0x100 + ScreenEdge_X_Pos

    gui.line(px-scrollX+8,py-0x100+16,   grapple.x-scrollX, grapple.y-0x100, "white")
end

return grapple