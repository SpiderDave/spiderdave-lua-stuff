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


local options= {
    index=1,
    {
        text = "option item 1", 
        action = function() spidey.message("test") end,
    },
}

menus.options = options
return menus