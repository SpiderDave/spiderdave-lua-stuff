-- entries with numerical index will hold the actual
-- added enemies.
--
-- data contains useful default stuff for enemies
-- need a bunch of extra things, like hard mode changes, 
-- variations.
local enemies = {
    data = {
        {
            name = "Goomba",
            type = 0x06,
            xs = -8,
        },
        {
            name = "Green Koopa",
            type = 0x00,
            xs = -8,
        },
        {
            name = "Springboard",
            type = 0x32,
        },
        {
            name = "Blooper",
            type = 0x07,
        },
        {
            name = "Flying Cheepcheep",
            type = 0x14,
            ys=-4.55,
            xs = math.random(-4,4)*8,
        },
        {
            name = "Power-Up",
            type = 0x2e,
        },
        {
            name = "Flower",
            base = "Power-Up",
            powerUpType = 0x01,
        },
        {
            name = "Rising Flower",
            base = "Flower",
            state = 0x01,
        },
        {
            name = "1-up",
            base = "Power-Up",
            powerUpType = 0x03,
        },
    }
}

enemies.getByName = function(n)
    for i,v in ipairs(enemies.data) do
        if string.lower(v.name)==string.lower(n) then
            return v
        end
    end
    return false
end

enemies.getByType = function(t)
    for i,v in ipairs(enemies.data) do
        if v.type ==t then
            return v
        end
    end
    return false
end

-- check for .base and add in inherited data
for _,e in ipairs(enemies.data) do
    if e.base then
        local eBase = enemies.getByName(e.base)
        for k,v in pairs(eBase) do
            e[k] = e[k] or v
        end
    end
end


enemies.reset = function()
    for i=1,#enemies do
        enemies[i].active = false
    end
end

enemies.load = function(file)
    file = file or enemies.file
    -- remove just the numerical entries
    for i=1,#enemies do
        table.remove(enemies)
    end
    local s = enemies.util.getFileContents(file)
    local t = enemies.TSerial.unpack(s)
    for i=1,#t do
        enemies[i]=t[i]
    end
end

enemies.save = function(file)
    file = file or enemies.file
    -- serialize just the numerical entries
    local t = {}
    for i=1,#enemies do
        t[i] = enemies[i]
    end
    enemies.util.writeToFile(file, enemies.TSerial.pack(t))
end

enemies.init = function(t)
    enemies.TSerial = t.TSerial
    enemies.util = t.util
    enemies.file = t.file
end

return enemies