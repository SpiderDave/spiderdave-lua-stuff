local cv2={}

cv2.relics = {
    names = {'rib','heart','eye','nail','ring','crystal'}
}

cv2.weapons = {
    names={'Dagger','Silver Dagger','Golden Dagger','Holy Water','Diamond','Sacred Flame','Oak Stake','Laurel','Garlic'}
}

cv2.whips = {
    names={[0]="Leather Whip", "Thorn Whip", "Chain Whip", "Morning Star", "Flame Whip"}
}

cv2.enemies = {
    
    [0x03] = {
        name="Skeleton/Skeleton Soldier",
    },
    [0x04] = {
        name="The Fish Man",
    },
    [0x05] = {name="Knight",},
    [0x06] = {name="Two-Headed Creature",},
    [0x08] = {name="Ghostly Eyeball",},
    [0x09] = {name="Fireball/Bat",},
    [0x0a] = {
        name="Medusa Head",
    },
    [0x0D] = {name="Skeleton Bone Thrower",},
    [0x0E] = {name="The Spider",},
    [0x0f] = {name="The Gargoyle",},
    [0x13] = {name="The Wolf Man",},
    [0x16] = {name="Freddie",},
    [0x18] = {name="Slimy BarSinister",},
    [0x30] = {name="Fireball",},
    [0x33] = {name="Web",},
    [0x38] = {name="The Zombie Hand",},
    [0x40] = {name="The Ghastly Leech",},
    [0x41] = {name="Slime",},
    [0x42] = {name="Carmilla",},
    [0x4a] = {name="Dragon Bones",},
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