local cv2={}

cv2.relics = {
    names = {'rib','heart','eye','nail','ring','crystal'}
}

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
    
    [0x03] = {
        name="Skeleton/Skeleton Soldier",
        exp = 1,
    },
    [0x04] = {
        name="The Fish Man",
        exp = 1,
    },
    [0x05] = {name="Knight",exp = 1,},
    [0x06] = {name="Two-Headed Creature",exp = 3,},
    [0x08] = {name="Ghostly Eyeball",exp = 1,},
    [0x09] = {
        name="Bat",
        exp = 1,
    },
    [0x0a] = {
        name="Medusa Head",exp = 1,
    },
    [0x0D] = {name="Skeleton Bone Thrower",exp = 3,},
    [0x0E] = {name="The Spider",exp = 1,},
    [0x0f] = {name="The Gargoyle",exp = 1,},
    [0x13] = {name="The Wolf Man",exp = 1,},
    [0x16] = {name="Freddie",exp = 1,},
    [0x17] = {name="Town Zombie",exp = 1,},
    [0x18] = {name="Slimy BarSinister",},
    [0x30] = {name="Fireball",exp = 0,},
    [0x33] = {name="Web",exp = 0,},
    [0x38] = {name="The Zombie Hand",exp = 0,},
    [0x40] = {name="The Ghastly Leech",exp = 1,},
    [0x41] = {name="Slime",exp = 1,},
    [0x42] = {name="Carmilla",exp = 50,},
    [0x4a] = {name="Dragon Bones",exp = 2,},
}

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

cv2.locations=locations

return cv2