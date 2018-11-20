-- whipBase values:
--
-- 0 Leather Whip
-- 1 Thorn Whip
-- 2 Chain Whip
-- 3 Morning Star
-- 4 Flame Whip

local items = {
    {
        name = "Dagger",
        type = "weapon",
        desc = "",
        weaponIndex = 1,
    },
    {
        name = "Silver Dagger",
        type = "weapon",
        desc = "",
        weaponIndex = 2,
    },
    {
        name = "Golden Dagger",
        type = "weapon",
        desc = "",
        weaponIndex = 3,
    },
    {
        name = "Holy Water",
        type = "weapon",
        desc = "Can be used to discover \nfalse bricks.",
        weaponIndex = 4,
    },
    {
        name = "Diamond",
        type = "weapon",
        desc = "Ricochets around the area.",
        weaponIndex = 5,
    },
    {
        name = "Sacred Flame",
        type = "weapon",
        desc = "",
        weaponIndex = 6,
    },
    {
        name = "Oak Stake",
        type = "weapon",
        desc = "",
        weaponIndex = 7,
    },
    {
        name = "Laurel",
        type = "weapon",
        desc = "",
        weaponIndex = 8,
    },
    {
        name = "Garlic",
        type = "weapon",
        desc = "",
        weaponIndex = 9,
    },
    {
        name = "Banshee Boomerang",
        type = "weapon",
        desc = "",
        weaponIndex = 10,
    },
    {
        name = "Classic Tunic",
        type = "armor",
        desc = "Classic tan leather tunic.",
        palette = {0x0f, 0x08, 0x27, 0x37},
    },
    {
        name = "Red Tunic",
        type = "armor",
        desc = "A red and black tunic.",
        palette = {0x0f, 0x0f, 0x16, 0x20},
    },
    {
        name = "Red Tunic (remix)",
        type = "armor",
        desc = "A red and black tunic, \nslightly muted colors.",
        palette = {0x0f, 0x0f, 0x17, 0x37}
    },
    {
        name = "Night Armor",
        type = "armor",
        desc = "Reduce damage from enemies\nat night.",
        palette = {0x0f, 0x0f, 0x13, 0x35},
    },
    {
        name = "Magic Armor",
        type = "armor",
        desc = "50 percent more invincible\ntime after getting hit.",
        palette = {0x0f, 0x0f, 0x14, 0x23},
    },
    {
        name = "Adventure Armor",
        type = "armor",
        desc = "Reduces heart cost of \nsome weapons.",
        palette = {0x0f, 0x0f, 0x1c, 0x20},
    },
    {
        name = "Zombie Armor",
        type = "armor",
        desc = "Scary Zombie Clothes",
        palette = {0x0f, 0x0f, 0x00, 0x0b},
    },

    {
        name = "Leather Whip",
        type = "whip",
        whipBase = 0,
    },
    {
        name = "Thorn Whip",
        type = "whip",
        whipBase = 1,
    },
    {
        name = "Chain Whip",
        type = "whip",
        whipBase = 2,
    },
    {
        name = "Morning Star",
        type = "whip",
        whipBase = 3,
    },
    {
        name = "Flame Whip",
        type = "whip",
        whipBase = 4,
    },
    {
        name = "Poison Whip",
        type = "whip",
        whipBase = 1,
    },
    {
        name = "Wall Chicken",
        type = "food",
        hp = 30,
    },
    {
        name = "Church's Chicken",
        type = "food",
        hp = 100,
    },
    {
        name = "Gold",
        type = "gold",
        gold = 50,
    },
    {
        name = "Map",
        type = "map",
    },
    {
        name = "Potion",
        type = "food",
    },
    {
        name = "Elixir",
        type = "food",
    },
    {
        name = "Gold Ring",
        type = "accessory",
    },
    {
        name = "Pendant",
        type = "accessory",
    },
    {
        name = "Charm",
        type = "accessory",
    },
    {
        name = "Stackable Item",
        type = "use",
        stack = 99,
    },
    {
        name = "Axe",
        type = "weapon",
        desc = "",
        weaponIndex = 11,
    },

}


-- Create an index of items by name
local itemIndex = {}
for i,v in ipairs(items) do
    itemIndex[v.name] = i
end
items.index = itemIndex

-- add index to each item
for i = 1, #items do
    items[i].index = i
end



return items