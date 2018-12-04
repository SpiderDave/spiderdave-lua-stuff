-- Ninja Gaiden Lua script by SpiderDave
spidey=require "Spidey.SpideyStuff"
local font=require "Spidey.default_font"

game = {}
game.paused = false

--current_font=2
current_font=1

cheats={
    enabled=true,
    active=false,
    hp=true,
    cantDie=true,
    lives=true
}


classMenu=spidey.classes.Menu
mnu=classMenu:new()
mnu.font=font[current_font]
mnu.background="small"
mnu.background_color="black"
mnu.items={}
mnu.items={
    {
        text=function()
            return string.format("area %d", game.area+1)
        end,
        
        left = function()
            game.area = math.max(0, game.area - 1)
            memory.writebyte(0x006d, game.area)
        end,
        right = function()
            game.area = game.area + 1
            memory.writebyte(0x006d, game.area)
        end,
        
        action=function()
            game.endLevel = true
        end,
    },
}

mnu:addStandard()

cheatMenu=classMenu:new()
cheatMenu.background="small"
cheatMenu.background_color="black"
cheatMenu.font=font[current_font]

mnu.items[#mnu.items+1]=
    {text="Cheat Engine",
    action=function()
        spidey.cheatEngine.menuOpen=not spidey.cheatEngine.menuOpen
    end}
cheatMenu.items=spidey.cheatEngine.menu.main

emu.registerexit(function(x) emu.message("") end)
function spidey.update(inp,joy)
    lastinp=inp
    
    game.paused=(memory.readbyte(0x001e)>=0x80)
    game.area = memory.readbyte(0x006d)
    
    if game.endLevel then
        memory.writebyte(0x001e, 0) -- unpause
        memory.writebyte(0x04b8, 0xff)
        emu.frameadvance()
        memory.writebyte(0x04b8, 0x3f)
        game.endLevel = false
    end
    
    if cheats.active then
        if cheats.hp then memory.writebyte(0x0065, 0x10) end
        if cheats.lives then memory.writebyte(0x0076, 0x09) end
        if cheats.cantDie then memory.writebyte(0x008b, 0x01) end
    end
    
    if spidey.debug.enabled then
    end
    
    if game.paused and cheats.enabled then
            if spidey.cheatEngine.menuOpen then
                cheatMenu.items= spidey.cheatEngine.menu.current
                cheatMenu:show()
                mnu:hide()
            else
                mnu:show()
                cheatMenu:hide()
            end
    else
        mnu:hide()
    end
end

function spidey.draw()
end

spidey.run()