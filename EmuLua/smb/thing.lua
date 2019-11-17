-- Things; objects, enemies, etc
local thing = {}

-- This is a holder for things.
local holder = {}

holder.max = 9000

holder.getUnused = function()
        local index=-1 -- If past the max it will be created in index -1
        for i=1,holder.max do
            if holder[i] and (holder[i].active==true) then
            else
                index = i
                break
            end
        end
        return index
end


function holder.add(...)
    local i = holder.getUnused()
    holder[i] = thing.new(holder[i], ...)
    return holder[i]
end

function holder.setAI(ai)
    holder.ai = ai
end

function thing:new(t, x, y, args)
    local o = {
        active=true,
        x=0,
        y=0,
        xs=0,
        ys=0,
        r=math.random(255),
        parent = holder,
        initialOffScreen = true,
        aliveTime = 0,
    }
    
    args = args or {}
    
    if type(t) == "table" then
        args = t or {}
        t = args.type
        x = args.x
        y = args.y
    end
    
    for k,v in pairs(args) do
        o[k] = v
    end
    
    o.type = t or o.type
    o.x = x or o.x
    o.y = y or o.y
    
    setmetatable(o, { __index = thing})
    return o
end

function thing:destroy()
    self.active = false
    if self.onDestroy then
        self.onDestroy()
    end
end

function thing:update()
    self.aliveTime=(self.aliveTime or 0)+1
    
    if self.ai then
        for _,v in pairs(self.ai) do
            holder.ai[v].update(self)
        end
    end
    
end

thing.holder = holder
holder.parent = thing
return thing