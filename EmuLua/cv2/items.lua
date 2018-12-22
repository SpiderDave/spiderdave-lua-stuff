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
        heartCost = 1,
    },
    {
        name = "Silver Knife",
        type = "weapon",
        desc = "",
        weaponIndex = 2,
        heartCost = 2,
    },
    {
        name = "Golden Knife",
        type = "weapon",
        desc = "",
        weaponIndex = 3,
        heartCost = 3,
    },
    {
        name = "Holy Water",
        type = "weapon",
        desc = "Can be used to discover \nfalse bricks.",
        weaponIndex = 4,
        heartCost = 2,
    },
    {
        name = "Diamond",
        type = "weapon",
        desc = "Ricochets around the area.",
        weaponIndex = 5,
        heartCost = 3,
    },
    {
        name = "Sacred Flame",
        type = "weapon",
        desc = "",
        weaponIndex = 6,
        heartCost = 4,
    },
    {
        name = "Oak Stake",
        type = "weapon",
        stack = 99,
        desc = "",
        weaponIndex = 7,
    },
    {
        name = "Laurel",
        type = "weapon",
        desc = "",
        weaponIndex = 8,
        stack = 99,
    },
    {
        name = "Garlic",
        type = "weapon",
        desc = "",
        weaponIndex = 9,
        stack = 99,
    },
    {
        name = "Banshee Boomerang",
        shortName = "B. Boomerang",
        type = "weapon",
        desc = "",
        weaponIndex = 10,
        weaponBase = 1,
        heartCost = 4,
    },
    {
        name = "Simon's Plate",
        type = "armor",
        desc = "Classic tan leather\nbreastplate.",
        palette = {0x0f, 0x08, 0x27, 0x37},
        ar = 10,
    },
    {
        name = "Red Plate",
        type = "armor",
        desc = "Red and black breastplate.",
        palette = {0x0f, 0x0f, 0x16, 0x20},
        ar = 2,
    },
    {
        name = "Red Plate (remix)",
        type = "armor",
        desc = "Red and black breastplate,\nslightly muted colors.",
        palette = {0x0f, 0x0f, 0x17, 0x37},
        ar = 6,
    },
    {
        name = "Night Armor",
        type = "armor",
        desc = "Reduce damage from enemies\nat night.",
        palette = {0x0f, 0x0f, 0x13, 0x35},
        ar = 12,
    },
    {
        name = "Magic Armor",
        type = "armor",
        desc = "50 percent more invincible\ntime after getting hit.",
        palette = {0x0f, 0x0f, 0x14, 0x23},
        ar = 12,
    },
    {
        name = "Adventure Armor",
        type = "armor",
        desc = "Reduces heart cost of \nsome weapons.",
        palette = {0x0f, 0x0f, 0x1c, 0x20},
        ar = 6,
    },
    {
        name = "Zombie Armor",
        type = "armor",
        desc = "Scary Zombie Clothes",
        palette = {0x0f, 0x0f, 0x00, 0x0b},
        ar = 20,
    },
    {
        name = "Leather Whip",
        type = "whip",
        whipBase = 0,
        attack = 8,
    },
    {
        name = "Thorn Whip",
        type = "whip",
        whipBase = 1,
        attack = 11,
    },
    {
        name = "Chain Whip",
        type = "whip",
        whipBase = 2,
        attack = 13,
    },
    {
        name = "Morning Star",
        type = "whip",
        whipBase = 3,
        attack = 20,
    },
    {
        name = "Flame Whip",
        type = "whip",
        whipBase = 4,
        attack = 25,
    },
    {
        name = "Poison Whip",
        type = "whip",
        whipBase = 1,
        attack = 8,
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
        hp=30,
    },
    {
        name = "Elixir",
        type = "food",
        hp=100,
    },
    {
        name = "Gold Ring",
        type = "accessory",
    },
    {
        name = "Pendant",
        type = "accessory",
        desc = "allows safe passage\naccross Joma Marsh.",
    },
    {
        name = "Charm",
        type = "accessory",
        desc = "Reduces heart cost of \nsome weapons.",
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
        weaponBase = 1,
        heartCost = 1,
    },
    {
        name = "Grab Bag",
        type = "bag",
        desc = "",
        bagList = {
            "Simon's Plate",
            "Red Plate",
            "Red Plate (remix)",
            "Night Armor",
            "Magic Armor",
            "Adventure Armor",
            "Zombie Armor",
            "Leather Whip",
            "Thorn Whip",
            "Chain Whip",
            "Morning Star",
            "Flame Whip",
            "Poison Whip",
            "Cross",
        }
    },
    {
        name = "Cross",
        type = "accessory",
        damageReduction = 1,
        desc = "Reduce all damage by 1.",
    },
    {
        name = "Soul of Bat",
        type = "accessory",
        damageReduction = 1,
        palette = {0x0f, 0x0f, 0x13, 0x35},
        desc = "Bat Mode.",
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


for i = 1, #items do
    items[i].shortName = items[i].shortName or items[i].name
end


return items