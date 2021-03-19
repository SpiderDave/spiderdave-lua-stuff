local menus = {}

-- This is meant to resolve dynamic things like
-- a .text item that can also be a function that
-- returns text.  It's very simple but makes 
-- the code look cleaner.
function menus.resolve(t)
    if type(t) == "function" then
        return t()
    else
        return t
    end
end


menus.cfg = {}
menus.allSettings = {
    "airTurn",
    "luigiFriction",
}

menus.allSettings = {
    {"air turn", "airTurn"},
    {"hold enemies", "holdEnemies"},
    {"disable inter", "disableIntermediate"},
    {"Luigi friction", "LuigiFriction"},
    {"Luigi jump", "LuigiJump"},
    {"demote to big", "demoteToBig"},
    {"stompJump", "stompJump"},
    {"switchPlayer", "switchPlayer"},
    {"noTimer", "noTimer"},
    {"ShowLivesInHud", "ShowLivesInHud"},
    {"invulnerable", "invulnerable"},
    {"continueScreen", "continueScreen"},
    {"demoSound", "demoSound"},
    {"menuSound", "menuSound"},
    {"bridgeConveyer", "bridgeConveyer"},
    {"randomMessages", "randomMessages"},
    {"cannonBallSuit", "cannonBallSuit"},
    {"grapple", "grapple"},
}


--local data = menus.util.getFileContents(menus.file)
--if data then
--    menus.cfg = menus.TSerial.unpack(data)
--end

local options= {
    index=1,
    {
        text = "load cfg", 
        action = function()
            menus.loadConfig()
            spidey.message("loaded.")
        end,
    },
    {
        text = "save cfg", 
        action = function()
            menus.saveConfig()
            spidey.message("saved.")
        end,
    },
}

for k,v in pairs(menus.allSettings) do
    local t = {}

    local txt = v[1]
    local opt = v[2]
    local f = function(txt, opt)
        return function() return string.format("%s %s", txt, menus.cfg[opt] and "on" or "off") end
    end
    t.text = f(txt, opt)
    
    local f = function(txt, opt)
        return function()
            menus.cfg[opt] = not menus.cfg[opt]
            menus.config[opt] = menus.cfg[opt]
        end
    end
    t.action = f(txt, opt)
    
    table.insert(options, t)
end

for i, v in ipairs(options) do
    if v.makeOption then
        local txt = v.makeOption[1]
        local opt = v.makeOption[2]
        local f = function(txt, opt)
            return function() return string.format("%s %s", txt, menus.cfg[opt] and "on" or "off") end
        end
        v.text = f(txt, opt)
        
        local f = function(txt, opt)
            return function()
                menus.cfg[opt] = not menus.cfg[opt]
                menus.config[opt] = menus.cfg[opt]
            end
        end
        v.action = f(txt, opt)
    end
end

menus.loadConfig = function()
    local data = menus.util.getFileContents(menus.file)
    if data then
        menus.cfg = menus.TSerial.unpack(data)
    end
    
    for k,v in pairs(menus.allSettings) do
        --menus.config[v[2]] = menus.cfg[v[2]] or menus.config[v[2]]
        menus.config[v[2]] = menus.cfg[v[2]]
    end
end

menus.saveConfig = function()
    menus.util.writeToFile(menus.file, menus.TSerial.pack(menus.cfg))
end

menus.init = function(t)
    menus.TSerial = t.TSerial
    menus.util = t.util
    menus.file = t.file
    menus.config = t.config
    menus.spidey = t.spidey
end

menus.options = options
return menus