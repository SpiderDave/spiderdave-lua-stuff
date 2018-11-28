local cv2={}

cv2.relics = {
    [0]= {},
    [1] = {name = "rib"},
    [2] = {name = "heart"},
    [3] = {name = "eye"},
    [4] = {name = "nail"},
    [5] = {name = "ring"},
    [6] = {name = "white crystal", displayName="crystal", varName = "whiteCrystal"},
    [7] = {name = "blue crystal", displayName="crystal", varName = "blueCrystal"},
    [8] = {name = "red crystal", displayName="crystal", varName = "redCrystal"},
}

cv2.mansions = {
    {name="Berkeley",relic="rib", orbValue = 24},
    {name="Rover",relic="heart", orbValue = 25},
    {name="Braham",relic="eye", orbValue = 26},
    {name="Bodley",relic="nail", orbValue = 27},
    {name="Laruba",relic="ring", orbValue = 28},
}

for i=1,8 do
    local n = cv2.relics[i].name
    cv2.relics[i].displayNameLong = string.gsub(" "..n, "%W%l", string.upper):sub(2)
    
    cv2.relics[i].varName = cv2.relics[i].varName or cv2.relics[i].name
end

cv2.weapons = {
    {name = "Dagger"},
    {name = "Silver Dagger"},
    {name = "Golden Dagger"},
    {name = "Holy Water"},
    {name = "Diamond"},
    {name = "Sacred Flame"},
    {name = "Oak Stake"},
    {name = "Laurel"},
    {name = "Garlic"},
    {name = "Banshee Boomerang"},
    {name = "Axe"},
}

cv2.whips = {
    names={[0]="Leather Whip", "Thorn Whip", "Chain Whip", "Morning Star", "Flame Whip"}
}

cv2.enemies = {
    [0x00] = {
        name="Nothing",
        exp=1,
    },
    [0x01] = {
        name="Town Raven",
        exp=1,
    },
    [0x02] = {
        name="Swamp Worm",
        exp=1,
        attack=10,
        hp=1,
    },
    [0x03] = {
        name="Skeleton",
        exp=1,
        attack = 7,
        hp = 15,
    },
    [0x04] = {
        name="Fishman",
        exp=1,
        attack = 5,
        hp = 9,
    },
    [0x05] = {
        name="Pitchfork Armor",
        exp=1,
        hp=40,
    },
    [0x06] = {
        name="Snakeman",
        exp=3,
        attack = 14,
        hp=30,
    },
    [0x07] = {name="Splash", exp=0},
    [0x08] = {name="Eyeball", exp=1},
    [0x09] = {
        name="Bat",
        exp=1,
        attack = 3,
        hp=1,
    },
    [0x0A] = {
        name="Medusa",
        exp=1,
    },
    [0x0B] = {name="?", exp=1},
    [0x0C] = {name="Skeleton Bone", exp=0},
    [0x0D] = {
        name="Jumping Skeleton",
        exp=3,
        attack = 7,
        hp = 13,
    },
    [0x0E] = {
        name="Spider",
        exp=1,
        attack=8,
        hp=1,
    },
    [0x0F] = {
        name="Gargoyle",
        exp=3,
    },
    [0x10] = {name="Skull", exp=2},
    [0x11] = {
        name="Hanging Bat",
        exp=1,
        attack = 3,
        hp=1,
    },
    [0x12] = {
        name="Wolf",
        exp=2,
        attack = 11,
        hp = 10,
    },
    [0x13] = {
        name="Werewolf",
        exp=2,
        attack = 8,
        hp = 35,
    },
    [0x14] = {name="Mansion Zombie", exp=1},
    [0x15] = {
        name="Swamp Ghost",
        exp=1,
        attack=7,
        hp=12,
    },
    [0x16] = {name="Freddie", exp=2},
    [0x17] = {
        name="Zombie",
        exp=1,
        attack = 5,
    },
    [0x18] = {
        name="Swamp Ghoul",
        exp=1,
        attack=7,
        hp=32,
    },
    [0x19] = {name="Skeledrag Segment", exp=1},
    [0x1A] = {name="Skeledrag Segment", exp=1},
    [0x1B] = {name="Eagle", exp=1},
    [0x1C] = {name="Deborah Cliff Tornado ", exp=0},
    [0x1D] = {name="Flameman", exp=2},
    [0x1E] = {name="Secret Merchant", exp=0, hp=0},
    [0x1F] = {name="Blob", exp=1},
    [0x20] = {name="Spikeshot", exp=0, hp="initial"},
    [0x21] = {name="Sideways block", exp=0, hp="initial"},
    [0x22] = {name="Floating block", exp=0, hp="initial"},
    [0x23] = {name="?", exp=0},
    [0x24] = {
        name="Sign",
        exp=0,
        hp=0,
    },
    [0x25] = {name="Orb", exp=0, hp="initial"},
    [0x26] = {name="Sacred Flame", exp=0, hp="initial"},
    [0x27] = {name="Book", exp=0, hp="initial"},
    [0x28] = {name="Town Man", exp=0, hp=0},
    [0x29] = {name="Town Woman", exp=0, hp=0},
    [0x2A] = {name="Town Man", exp=0, hp=0},
    [0x2B] = {name="Town Man", exp=0, hp=0},
    [0x2C] = {name="Town Old Woman", exp=0, hp=0},
    [0x2D] = {name="Priest", exp=0, hp=0},
    [0x2E] = {name="Merchant", exp=0, hp=0},
    [0x2F] = {name="Town Knight", exp=0, hp=0},
    [0x30] = {name="Fireball", exp=0},
    [0x31] = {name="Fireball", exp=0},
    [0x32] = {name="Fireball (from flame man)", exp=0},
    [0x33] = {
        name="Spider Web",
        exp=0,
        hp=1,
        attack=5,
    },
    [0x34] = {name="Single Floating Block", exp=0},
    [0x35] = {name="Town Old Man", exp=1, hp=0},
    [0x36] = {name="Flame after killing enemy", exp=0},
    [0x37] = {name="Heart", exp="initial"},
    [0x38] = {name="Hand", exp=1},
    [0x39] = {
        name="Ghost",
        exp=2,
    },
    [0x3A] = {
        name="Mummy",
        exp=4,
    },
    [0x3B] = {name="Eagleman", exp=2},
    [0x3C] = {name="Ferry Man", exp=0},
    [0x3D] = {name="Ferry Boat", exp=0},
    [0x3E] = {name="Falling Rock", exp=0},
    [0x3F] = {name="Thornweed", exp=1},
    [0x40] = {name="Swamp Worm (high)", exp=1},
    [0x41] = {name="High Jump Blob", exp=1},
    [0x42] = {name="Camilla", exp=50},
    [0x43] = {
        name="Marsh",
        exp=0,
        hp=0,
        },
    [0x44] = {name="Death", exp=100},
    [0x45] = {name="Camilla drops", exp=0},
    [0x46] = {name="Death hatchet", exp=0},
    [0x47] = {
        name="Dracula",
        exp=0,
        hp=255,
    },
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
                    local name = locations[a1][a2][a3]
                    local displayName = string.gsub(name, '%s%(Pt[1234]%)','')
                    displayName = string.gsub(displayName, "'s",'')
                    
                    locations[a1][a2][a3]={
                        name = name,
                        displayName = displayName,
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

cv2.palettes = {
    simon={
        {palette = {0x0f, 0x0f, 0x16, 0x20}, desc = "original black and red"},
        {palette = {0x0f, 0x0f, 0x1c, 0x20}, desc = "black and blue"},
        {palette = {0x0f, 0x0f, 0x17, 0x37}, desc = "original look, slightly less red, more skin tone"},
        {palette = {0x0f, 0x0f, 0x13, 0x35}, desc = "black and purple"},
        {palette = {0x0f, 0x0f, 0x14, 0x23}, desc = "black and purple (better?)"},
        {palette = {0x0f, 0x08, 0x16, 0x33}, desc = "lighter version of original; brown and redish"},
        {palette = {0x0f, 0x08, 0x27, 0x37}, desc = "classic tan"},
        {palette = {0x0f, 0x08, 0x17, 0x37}, desc = "darker version of classic tan; slightly more redish"},
    }
}

cv2.map = {
    locations = {
        {x=87, y=209, text="Jova"},
        {x=0x76, y=0xb8, text="Jova Woods"},
        {x=40, y=193, text="Belasco Marsh"},
        {x=0xb5, y=0xbc, text="South Bridge"},
        {x=0xe0, y=0xdb, text="Veros"},
        {x=0xf7, y=0xc6, text="Veros Woods"},
    }
}


cv2.messages = {
    [0x38]={
        {
            condition=function() return relics.list.whiteCrystal end,
            text="THE WHITE \nCRYSTAL CAN\nREVEAL A \nHIDDEN \nOBJECT.",
            notes="something useful for him to say once you bought the crystal.",
        },
        {
            text="FIRST THING\nTO DO IN\nTHIS TOWN IS\nBUY A WHITE\nCRYSTAL.",
        },
    },
    [0x64]={
        {
            cycle = true,
            text={"GO AWAY!","LEAVE ME \nALONE!"},
        },
    },
    [0x44]={
        {
            text="RUMOR HAS IT\nTHE FERRYMAN\nAT DEAD RIVER\nLOVES GARLIC.",
            notes="** removed the comma and bad formatting.  still a bogus clue.",
        },
    },
    [0x4c]={
        {
            text="THERE ARE \nTRADERS IN \nTOWNS WHO DO \nBUSINESS IN \nHIDING.",
            notes = "** pretty close to original.  I don't take the extra step \
                        here and tell the player that they're behind fake walls \
                        specifically.",
        },
    },
    [0x53]={
        {
            text="LEFT: \nWICKED DITCH\n\nRIGHT: \nNORTH BRIDGE",
        },
    },
    [0x57]={
        {
            text="IF YOU ARE\nTIRED OR IN\nPAIN, VISIT\nTHE CHURCH.",
        },
    },
    [0x5e]={
        {
            cycle = true,
            text={"I WARNED YOU\nNOT TO \nRETURN.","HAVEN'T YOU \nDONE ENOUGH?","I HOPED I'D \nNEVER SEE \nYOU AGAIN.","THIS IS \nALL YOUR \nFAULT."},
            notes = "",
        },
    },
    [0x65]={
        {
            cycle = true,
            text={"IT'S NOT SAFE\nHERE ANYMORE.","THIS IS \nYOUR FAULT.","LEAVE THIS \nPLACE AND \nNEVER RETURN!"},
            notes = "",
        },
    },
    [0x55]={
        {
            text="I'LL GIVE YOU\nA BLUE\nCRYSTAL.",
        },
    },
    [0x56]={
        {
            text="I'LL GIVE YOU\nA RED\nCRYSTAL.",
        },
    },
    [0x6b]={
        {
            condition=function() return displayarea=="Alba" and relics.list.redCrystal end,
            text="THE RED\nCRYSTAL CAN\nREVEAL A \nHIDDEN \nPATH.",
        },
        {
            condition=function() return displayarea=="Aljiba" and relics.list.blueCrystal end,
            text="THE BLUE\nCRYSTAL CAN\nREVEAL A \nHIDDEN \nPATH.",
        },
        {
            condition=function() return displayarea=="Alba" and not relics.list.blueCrystal and not relics.list.redCrystal end,
            text="I HAVE A RED\nCRYSTAL.",
            notes = "",
        },
        {
            condition=function() return displayarea=="Aljiba" and not relics.list.whiteCrystal and not relics.list.blueCrystal end,
            text="I HAVE A BLUE\nCRYSTAL.",
            notes = "",
        },
    },

}

cv2.defaultMessages = {
    [0]="WHAT A\nHORRIBLE\nNIGHT TO\nHAVE A\nCURSE.",
    [1]="THE MORNING\nSUN HAS\nVANQUISHED\nTHE HORRIBLE\nNIGHT.",
    [2]="NOTHING.",
    [3]="YOUR LEVEL\nOF SKILL HAS\nINCREASED TO\n1.",
    [4]="YOUR LEVEL\nOF SKILL HAS\nINCREASED TO\n2.",
    [5]="YOUR LEVEL\nOF SKILL HAS\nINCREASED TO\n3.",
    [6]="YOUR LEVEL\nOF SKILL HAS\nINCREASED TO\n4.",
    [7]="YOUR LEVEL\nOF SKILL HAS\nINCREASED TO\n5.",
    [8]="YOUR LEVEL\nOF SKILL HAS\nINCREASED TO\n6.",
    [9]="YOUR LEVEL\nOF SKILL HAS\nINCREASED TO\n7.",
    [0x0a]="SURE, I'LL\nTAKE YOU TO\nA GOOD\nPLACE. HEH!\nHEH! HEH!",
    [0x0b]="LET ME SHOW\nYOU THE WAY.",
    [0x0c]="TO REPLENISH\nEARTH ,KNEEL\nBY THE LAKE\nWITH THE\nBLUE CRYSTAL.",
    [0x0d]="I'LL GIVE\nYOUR MORNING\nSTAR POWER\nTO BURN AWAY\nEVIL.",
    [0x0e]="I'LL GIVE\nYOU A SILK\nBAG.",
    [0x0f]="I'LL GIVE\nYOU THIS\nSILVER KNIFE\nTO SAVE YOUR\nNECK.",
    [0x10]="DRACULA'S\nEVIL KNIFE\nBLURS\nCAMILLA'S\nVISION.",
    [0x11]="I'LL GIVE\nYOU A\nDIAMOND.",
    [0x12]="I'LL SHOW\nYOU THE WAY.",
    [0x13]="DRACULA'S\nNAIL MAY\nSOLVE\nTHE EVIL\nMYSTERY.",
    [0x14]="NOTHING.",
    [0x15]="YOU NOW\nPROSSESS\nDRACULA'S\nRIB.",
    [0x16]="YOU NOW\nPROSSESS\nDRACULA'S\nHEART.",
    [0x17]="YOU NOW\nPROSSESS\nDRACULA'S\nEYEBALL.",
    [0x18]="YOU NOW\nPROSSESS\nDRACULA'S\nNAIL.",
    [0x19]="YOU NOW\nPROSSESS\nDRACULA'S\nRING.",
    [0x1a]="INVEST IN AN\nOAK STAKE?",
    [0x1b]="A SYMBOL OF\nEVIL WILL\nAPPAER WHEN\nYOU STRIKE\nTHE STAKE.",
    [0x1c]="DESTROY THE\nCURSE AND\nYOU'LL RULE\nBRAHM'S\nMANSION.",
    [0x1d]="A FLAME\nFLICKERS\nINSIDE THE\nRING OF\nFIRE.",
    [0x1e]="GARLIC IN\nTHE\nGRAVEYARD\nSUMMONS A\nSTRANGER.",
    [0x1f]="DESTROY THE\nCURSE WITH\nDRACULA'S\nHEART.",
    [0x20]="PLACE THE\nLAURELS IN A\nSILK BAG TO\nBRING THEM\nTO LIFE.",
    [0x21]="WAIT FOR A\nSOUL WITH A\nRED CRYSTAL\nON DEBORAH\nCLIFF.",
    [0x22]="THE CURSE\nHAS KILLED\nTHE LAUREL\nTREE.",
    [0x23]="YOU NOW\nPOSSESS THE\nMAGIC CROSS.",
    [0x24]="NOTHING.",
    [0x25]="WILL YOU BUY\nSOME GARLIC?",
    [0x26]="BUY SOME OF\nMY LAURELS?",
    [0x27]="REST HERE\nFOR A WHILE.",
    [0x28]="BUY A WHITE\nCRYSTAL?",
    [0x29]="BUY A THORN\nWHIP?",
    [0x2a]="PURCHASE A\nCHAIN WHIP?",
    [0x2b]="MORNING STAR\n- BUY ONE?",
    [0x2c]="WILL YOU BUY\nA DAGGER?",
    [0x2d]="WANT TO BUY\nHOLY WATER?",
    [0x2e]="FIRST THING\nTO DO IN\nTHIS TOWN IS\nBUY A WHITE\nCRYSTAL.",
    [0x2f]="YOU'VE GOT A\nFRIEND WAIT-\nING FOR YOU\nIN THE TOWN\nOF ALJIBA.",
    [0x30]="TURN RIGHT\nFOR THE JOVA\nWOODS. LEFT\nFOR BELASCO\nMARSH.",
    [0x31]="TURN RIGHT\nFOR DABI'S\nPATH LEFT\nFOR THE\nVEROS WOODS.",
    [0x32]="TURN RIGHT\nFOR SADAM\nWOODS, LEFT\nFOR THE JAM\nWASTELAND.",
    [0x33]="YOU HAVE A\nFRIEND IN\nTHE TOWN OF\nALDRA. GO AND\nSEE HIM.",
    [0x34]="13 CLUES\nWILL SOLVE\nDRACULA'S\nRIDDLE.",
    [0x35]="A MAN LIVING\nIN DARKNESS\nCAN GIVE\nYOUR WHIP\nPOWER.",
    [0x36]="A RIB CAN\nSHIELD YOU\nFROM EVIL.",
    [0x37]="A MAGIC\nPOTION WILL\nDESTROY THE\nWALL OF\nEVIL.",
    [0x38]="CLEAR A PATH\nAT BERKELEY\nMANSION WITH\nA WHITE\nCRYSTAL.",
    [0x39]="LAURELS IN\nYOUR SOUP\nENHANCES ITS\nAROMA.",
    [0x3a]="RUMOR HAS IT\n, THE FERRY-\nMAN AT DEAD\nRIVER LOVES\nGARLIC.",
    [0x3b]="DIG UP THE\n4TH GRAVE IN\nTHE CEMETERY\nFOR A\nDIAMOND.",
    [0x3c]="BELIEVE IN\nMAGIC AND\nYOU'LL BE\nSAVED.",
    [0x3d]="TAKE MY\nDAUGHTER,\nPLEASE!",
    [0x3e]="YOU LOOK\nPALE,MY SON.\nYOU MUST\nREST IN THE\nCHURCH.",
    [0x3f]="DON'T LOOK\nINTO THE\nDEATH STAR,\nOR YOU WILL\nDIE.",
    [0x40]="DON'T MAKE\nME STAY.\nI'LL DIE.",
    [0x41]="WHEN I WAS\nYOUR AGE,\nWOMEN LOVED\nME.",
    [0x42]="A CROOKED\nTRADER IS\nOFFERING BUM\nDEALS IN\nTHIS TOWN.",
    [0x43]="A FLAME IS\nON TOP OF\nTHE 6TH TREE\nIN DENIS\nWOODS.",
    [0x44]="CLUES TO\nDRACULA'S\nRIDDLE ARE\nIN THE TOWN\nOF VEROS.",
    [0x45]="CLUES TO\nDRACULA'S\nRIDDLE ARE\nIN THE TOWN\nOF ALBA.",
    [0x46]="CLUES TO\nDRACULA'S\nRIDDLE ARE\nIN BERKELEY\nMANSION.",
    [0x47]="TURN RIGHT\nFOR CAMILLA\nCEMETERY,\nLEFT FOR THE\nALJIBA WOODS.",
    [0x48]="TURN RIGHT\nFOR THE DEAD\nRIVER, LEFT\nFOR THE \nSADAM WOODS.",
    [0x49]="TURN LEFT\nFOR THE\nWICKED DITCH\n, RIGHT TO\nGO NORTH.",
    [0x4a]="TURN RIGHT\nFOR VRAD\nGRAVEYARD,\nLEFT FOR THE\nDORA WOODS.",
    [0x4b]="I'D LIKE TO\nEXCHANGE A\nWHITE\nCRYSTAL FOR\nA BLUE ONE.",
    [0x4c]="I'D LIKE TO\nEXCHANGE A\nBLUE CRYSTAL\nFOR A RED\nONE.",
    [0x4d]="TO RESTORE\nYOUR LIFE,\nSHOUT IN\nFRONT OF\nTHE CHURCH.",
    [0x4e]="THE DEAD\nRIVER WAITS\nTO BE FREED\nFROM THE\nCURSE.",
    [0x4f]="DRACULA'S\nEYEBALL\nREFLECTS\nTHE CURSE.",
    [0x50]="LET'S LIVE\nHERE\nTOGETHER.",
    [0x51]="A LAUREL \nWILL PROTECT\nYOU FROM THE\nPOISON\nMARSH.",
    [0x52]="AN OLD GYPSY\nHOLDS A\nDIAMOND IN\nFRONT OF DE-\nBORAH CLIFF.",
    [0x53]="HIT DEBORAH\nCLIFF WITH\nYOUR HEAD TO\nMAKE A HOLE.",
    [0x54]="AFTER\nCASTLEVANIA\nI WARNED YOU\nNOT TO\nRETURN.",
    [0x55]="SORRY, PAL.\nNO TIME NOW,\nMAYBE\nLATER.",
    [0x56]="BUY SOME\nGARLIC.\nIT HAS\nSPECIAL\nPOWERS.",
    [0x57]="I'VE BEEN\nWAITING FOR\nA GOOD\nLOOKING GUY\nLIKE YOU.",
    [0x58]="I WANT TO\nGET TO KNOW\nYOU BETTER.",
    [0x59]="I'LL SEE\nYOU AT\nMIDNIGHT\nON THE\nRIVER BANK.",
    [0x5a]="GET BACK!",
    [0x5b]="YOU'VE\nUPSET THE\nPEOPLE.\nNOW GET OUT\nOF TOWN!",
    [0x5c]="GET A SILK\nBAG FROM THE\nGRAVEYARD\nDUCK TO LIVE\nLONGER.",
    [0x5d]="CLUES TO\nDRACULA'S\nRIDDLE ARE\nIN THE VEROS\nWOODS.",
    [0x5e]="CLUES TO\nDRACULA'S\nRIDDLE ARE\nIN BODLEY\nMANSION.",
    [0x5f]="CLUES TO\nDRACULA'S\nRIDDLE ARE\nIN ROVER\nMANSION.",
    [0x60]="THE CROSS IN\nLARUBA'S \nMANSION MUST\nBE FOUND.",
    [0x61]="I REFUSE TO\nEXCHANGE MY\nCRYSTAL FOR\nYOURS.",
    [0x62]="NOTHING.",
    [0x63]="TO BREAK MY\nSPELL, COME\nBACK WITH A\nPOWERFUL\nWEAPON.",
    [0x64]="YOU NOW\nPOSSESS\nTHE SACRED\nFLAME.",
    [0x65]="YOU NOW\nPOSSESS\nTHE GOLDEN\nKNIFE.",
    [0x66]="I BEG OF YOU\nTO TAKE\nTHESE\nLAURELS.",
}

cv2.placedItems = {
    {x=0x198, y=0x9d, area = {0x02,0x03,0x01}, name="Classic Tunic", location="dabis path on some bricks."},
    {x=0x38, y=0x13d, area = {0x02,0x03,0x03}, name="Night Armor", location="below aljiba woods to left of stairs."},
    {x=0x3e8, y=0x9d, area = {0x00,0x00,0x00}, name="Gold", location="jova top right side."},
    {x=0xd8, y=0x5d, area = {0x00,0x07,0x00, 0x05}, name="Church's Chicken", location="church in doina."},
    {x=0x58, y=0xbd, area = {0x00,0x08,0x00, 0x00}, name="Gold", location="room with thorn whip in jova."},
    {x=0xb8, y=0x9d, area = {0x00,0x07,0x00, 0x00}, name="Axe", location="church in jova."},
}

cv2.story = [[
1698 --

It was seven years ago
that Simon Belmont,
the legendary vampire
hunter, defeated
Dracula in the events
of Castlevania.

The victory proved
painful, as critical
wounds inflicted in
that final
confrontation gnawed
at his soul.

Upon visiting his
family's resting
ground in the morning
mist, Simon
encountered a young
maiden who told him a
curse was placed upon
him during that final
battle, and he does
not have long to live.
She explained that the
curse could only be
undone by bringing
Dracula's remains to
the ruins of his
castle and purifying
them with fire.
]]

return cv2