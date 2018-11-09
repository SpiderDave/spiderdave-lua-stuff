local cv2={}

cv2.relics = {
    [0]= {},
    [1] = {name = "rib"},
    [2] = {name = "heart"},
    [3] = {name = "eye"},
    [4] = {name = "nail"},
    [5] = {name = "ring"},
    [6] = {name = "white crystal", displayName="crystal"},
    [7] = {name = "blue crystal", displayName="crystal"},
    [8] = {name = "red crystal", displayName="crystal"},
}

for i=1,8 do
    local n = cv2.relics[i].name
    cv2.relics[i].displayNameLong = string.gsub(" "..n, "%W%l", string.upper):sub(2)
    
end

cv2.weapons = {
    {name = "Dagger", cost = 1},
    {name = "Silver Dagger", cost = 2},
    {name = "Golden Dagger", cost = 3},
    {name = "Holy Water", cost = 2},
    {name = "Diamond", cost = 3},
    {name = "Sacred Flame", cost = 4},
    {name = "Oak Stake", cost =0},
    {name = "Laurel", cost = 0},
    {name = "Garlic", cost = 0},
    {name = "Banshee Boomerang", cost = 4},
}

cv2.whips = {
    names={[0]="Leather Whip", "Thorn Whip", "Chain Whip", "Morning Star", "Flame Whip"}
}

cv2.enemies = {
    [0x00] = {name="Nothing", exp=1},
    [0x01] = {name="Town Raven", exp=1},
    [0x02] = {name="Swamp Worm", exp=1},
    [0x03] = {name="Skeleton", exp=1},
    [0x04] = {name="Fishman", exp=1},
    [0x05] = {name="Pitchfork Armor", exp=1},
    [0x06] = {name="Snakeman", exp=3},
    [0x07] = {name="Splash", exp=0},
    [0x08] = {name="Eyeball", exp=1},
    [0x09] = {name="Bat", exp=1},
    [0x0A] = {name="Medusa", exp=1},
    [0x0B] = {name="?", exp=1},
    [0x0C] = {name="Skeleton Bone", exp=0},
    [0x0D] = {name="Jumping Skeleton", exp=3},
    [0x0E] = {name="Spider", exp=1},
    [0x0F] = {name="Gargoyle", exp=3},
    [0x10] = {name="Skull", exp=2},
    [0x11] = {name="Hanging Bat", exp=1},
    [0x12] = {name="Wolf", exp=2},
    [0x13] = {name="Werewolf", exp=2},
    [0x14] = {name="Mansion Zombie", exp=1},
    [0x15] = {name="Swamp Ghost", exp=1},
    [0x16] = {name="Freddie", exp=2},
    [0x17] = {name="Zombie", exp=1},
    [0x18] = {name="Swamp Ghoul", exp=1},
    [0x19] = {name="Skeledrag Segment", exp=1},
    [0x1A] = {name="Skeledrag Segment", exp=1},
    [0x1B] = {name="Eagle", exp=1},
    [0x1C] = {name="Deborah Cliff Tornado ", exp=0},
    [0x1D] = {name="Flameman", exp=2},
    [0x1E] = {name="Secret Merchant", exp=0},
    [0x1F] = {name="Blob", exp=1},
    [0x20] = {name="Spikeshot", exp=0},
    [0x21] = {name="Sideways block", exp=0},
    [0x22] = {name="Floating block", exp=0},
    [0x23] = {name="?", exp=0},
    [0x24] = {name="Sign", exp=0},
    [0x25] = {name="Orb", exp=0},
    [0x26] = {name="Sacred Flame", exp=0},
    [0x27] = {name="Book", exp=0},
    [0x28] = {name="Town Man", exp=0},
    [0x29] = {name="Town Woman", exp=0},
    [0x2A] = {name="Town Man", exp=0},
    [0x2B] = {name="Town Man", exp=0},
    [0x2C] = {name="Town Old Woman", exp=0},
    [0x2D] = {name="Priest", exp=0},
    [0x2E] = {name="Merchant", exp=0},
    [0x2F] = {name="Town Knight", exp=0},
    [0x30] = {name="Fireball", exp=0},
    [0x31] = {name="Fireball", exp=0},
    [0x32] = {name="Fireball (from flame man)", exp=0},
    [0x33] = {name="Spider Web", exp=0},
    [0x34] = {name="Single Floating Block", exp=0},
    [0x35] = {name="Town Old Man", exp=1},
    [0x36] = {name="Flame after killing enemy", exp=0},
    [0x37] = {name="Heart after killing enemy", exp=0},
    [0x38] = {name="Hand", exp=1},
    [0x39] = {name="Ghost", exp=2},
    [0x3A] = {name="Mummy", exp=4},
    [0x3B] = {name="Eagleman", exp=2},
    [0x3C] = {name="Ferry Man", exp=0},
    [0x3D] = {name="Ferry Boat", exp=0},
    [0x3E] = {name="Falling Rock", exp=0},
    [0x3F] = {name="Thornweed", exp=1},
    [0x40] = {name="Swamp Worm (high)", exp=1},
    [0x41] = {name="High Jump Blob", exp=1},
    [0x42] = {name="Camilla", exp=50},
    [0x43] = {name="Marsh", exp=0},
    [0x44] = {name="Death", exp=100},
    [0x45] = {name="Camilla drops", exp=0},
    [0x46] = {name="Death hatchet", exp=0},
    [0x47] = {name="Dracula", exp=0},
    [0x48] = {name="Dracula shot", exp=0},
    [0x49] = {name="Item after killing boss", exp=1},
    [0x4A] = {name="Skeledrag", exp=2},
    [0x4B] = {name="Money bags rising", exp=0},
    [0x4C] = {name="Flame that burns dracula's parts", exp=0},
    [0x4D] = {name="Flame that ends game", exp=0},
}

--00- Nothing		
--01- Town Raven
--02- Swamp Worm
--03- Skeleton
--04- Fishman
--05- Pitchfork Armor
--06- Snakeman
--07- Splash
--08- Eyeball
--09- Bat
--0A- Medusa
--0B- ?
--0C- Skeleton Bone
--0D- Jumping Skeleton 
--0E- Spider
--0F- Gargoyle
--10- Skull
--11- Hanging Bat
--12- Wolf
--13- Werewolf
--14- Mansion Zombie
--15- Swamp Ghost
--16- Freddie
--17- Zombie
--18- Swamp Ghoul
--19- Skeledrag Segment
--1A- Skeledrag Segment
--1B- Eagle
--1C- Deborah Cliff Tornado 
--1D- Flameman
--1E- Secret Merchant
--1F- Blob 
--20- Spikeshot
--21- Sideways block
--22- Floating block
--23- ?
--24- Sign
--25- Orb
--26- Sacred Flame
--27- Book
--28- Town Man
--29- Town Woman
--2A- Town Man
--2B- Town Man
--2C- Town Old Woman
--2D- Priest
--2E- Merchant
--2F- Town Knight
--30- Fireball
--31- Fireball
--32- Fireball (from flame man)
--33- Spider Web
--34- Single Floating Block
--35- Town Old Man
--36- Flame after killing enemy
--37- Heart after killing enemy
--38- Hand
--39- Ghost
--3A- Mummy
--3B- Eagleman
--3C- Ferry Man
--3D- Ferry Boat
--3E- Falling Rock
--3F- Thornweed
--40- Swamp Worm (high)
--41- High Jump Blob
--42- Camilla
--43- Marsh
--44- Death
--45- Camilla drops
--46- Death hatchet
--47- Dracula
--48- Dracula shot
--49- Item after killing boss
--4A- Skeledrag
--4B- Money bags rising
--4C- Flame that burns dracula's parts
--4D- Flame that ends game


local locations={}
locations[0]={name="Towns"}
locations[1]={name="Mansion"}
locations[2]={name="Woods 1"}
locations[3]={name="Woods 2"}
locations[4]={name="Woods 3"}
locations[5]={name="Castlevania"}
locations[0][0]={[0]='Jova'}
locations[0][1]={[0]='Veros'}
locations[0][2]={[0]='Aljiba'}
locations[0][3]={[0]='Alba'}
locations[0][4]={[0]='Ondol'}
locations[0][5]={[0]='Doina'}
locations[0][6]={[0]='Yomi'}
locations[0][7]={[0]='Church'}
locations[0][8]={[0]='(room)'}
locations[0][9]={[0]='(room)'}
locations[0][10]={[0]='(room)','(room)'}
locations[0][11]={[0]='(room)'}
locations[0][12]={[0]='(room)'}
locations[0][13]={[0]='(room)','(room)'}
locations[0][14]={[0]='(room)','(room)'}
locations[0][15]={[0]='(room)','(room)'}
locations[0][16]={[0]='(room)','(room)'}
locations[0][17]={[0]='(room)','(room)'}
locations[0][18]={[0]='(room)'}
locations[0][19]={[0]='(room)'}
locations[0][20]={[0]='(room)'}
locations[0][21]={[0]='(room)'}
locations[0][22]={[0]='(room)'}
locations[0][23]={[0]='(room)'}
locations[1][0]={[0]='Laruba (door)'}
locations[1][1]={[0]='Berkeley (door)'}
locations[1][2]={[0]='Rover (door)'}
locations[1][3]={[0]="Brahm's (door)"}
locations[1][4]={[0]='Bodley (door)'}
locations[1][5]={[0]='?'}
locations[1][6]={[0]='Laruba (Pt1)','Laruba (Pt2)','Laruba (Pt3)','Laruba (Pt4)'}
locations[1][7]={[0]="Berkeley's (Pt1)","Berkeley's (Pt2)"}
locations[1][8]={[0]='Rover (Pt1)','Rover (Pt2)'}
locations[1][9]={[0]="Brahm's (Pt1)","Brahm's (Pt2)","Brahm's (Pt3)","Brahm's (Pt4)"}
locations[1][10]={[0]='Bodley (Pt1)','Bodley (Pt2)'}
locations[2][0]={[0]='Jova Woods','South Bridge','Veros Woods (Pt1)','Veros Woods (Pt2)'}
locations[2][1]={[0]='Denis Woods (Pt1)'}
locations[2][2]={[0]='Aljiba Woods (Pt4)'}
locations[2][3]={[0]='Dabis Path (Pt1)','Dabis Path (Pt2)','Aljiba Woods (Pt1)','Aljiba Woods (Pt2)'}
locations[2][4]={[0]='Denis Woods (Pt2)','Denis Woods (Pt3)'}
locations[2][5]={[0]='Aljiba Woods (Pt3)','Yuba Lake'}
locations[2][6]={[0]='Dead River??? (Pt2)'}
locations[2][7]={[0]='Dead River (Pt2)','Dead River (Pt1)','Belasco Marsh'}
locations[2][8]={[0]='North Bridge','Dora Woods (Pt1)','Dora Woods (Pt2)'}
locations[2][9]={[0]='Dora Woods (Pt3)','East Bridge','Bordia Mountains'}
locations[3][0]={[0]='Camilla Cemetery','Joma Marsh (Pt1)'}
locations[3][1]={[0]='Storigori Graveyard'}
locations[3][2]={[0]='Sadam Woods (Pt2)','Sadam Woods (Pt1)'}
locations[3][3]={[0]='Joma Marsh (Pt3)','Joma Marsh (Pt2)','Debious Woods (Pt3)','Debious Woods (Pt2)','Debious Woods (Pt1)'}
locations[3][4]={[0]='Sadam Woods (Pt3)'}
locations[4][0]={[0]='Vrad Mountain (Pt2)','Vrad Mountain (Pt1)'}
locations[4][1]={[0]='Deborah Cliff','Jam Wasteland'}
locations[4][2]={[0]='Wicked Ditch'}
locations[4][3]={[0]='Vrad Graveyard','West Bridge'}
locations[5][0]={[0]='Castlevania (Pt1)','Castlevania (Pt2)'}

for a1=0,5 do
    for a2=0,255 do
        if locations[a1][a2] then
            for a3=0,255 do
                if locations[a1][a2][a3] then
                    locations[a1][a2][a3]={
                        name = locations[a1][a2][a3],
                        displayName = string.gsub(locations[a1][a2][a3], '%s%(Pt[1234]%)',''),
                    }
                end
            end
        end
    end
end

locations.getAreaName = function(a1,a2,a3)
    if locations[a1] and locations[a1][a2] and locations[a1][a2][a3] then
        return locations[a1][a2][a3].displayName
    else
        return string.format('%s %s %s',a1,a2,a3)
    end
end

cv2.locations=locations

return cv2