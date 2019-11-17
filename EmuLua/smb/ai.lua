local ai = {}
local smb


function ai.init(s)
    ai.smb = s
    smb = s
end

ai.medusa = {
    update = function(o)
        o.ys=math.cos((o.aliveTime+o.r)*.05)*2
    end
}

ai.sine2 = {
    update = function(o)
        o.ys=math.cos((o.aliveTime+o.r)*.2)*1
        o.xs = o.xs*1.07
    end
}

ai.movement = {
    update = function(o)
        o.x = o.x + o.xs
        o.y = o.y + o.ys
    end
}


ai.bullet = {
    update = function(o)
        --o.ys=math.cos((o.aliveTime+o.r)*.05)*2
        local scroll = smb.getScroll()
        for i=1,5 do
            if smb.hitBoxes[i].active then
                local hb=smb.hitBoxes[i].rect
                --local page=smb.hitBoxes[i].pageLoc
                local page=memory.readbyte(0x6d+i)
                --gui.drawtext(o.x-game.scrollX,o.y,"*")
                --gui.drawtext(hb[1],hb[2],"+")
                --if o.x>= hb[1]-game.scrollX and o.y>=hb[2]-8 and o.x<=hb[3]-game.scrollX and o.y<=hb[4]+8 then
                local state = memory.readbyte(0x1d+i)
                if state~=0x22 then
                    if o.x>= hb[1]+game.scrollX-8 and o.y>=hb[2]-16 and o.x<=hb[3]+game.scrollX-8 and o.y<=hb[4]-16+8 then
                        o:destroy()
                        memory.writebyte(0x1d+i,0x22)
                        smb.setEnemySpeed(i,8,-3)
                        memory.writebyte(0xff, 0x08) -- play smack enemy sound
                    end
                end
                
            end
        end
    end
}


return ai