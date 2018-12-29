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
    {name="Brahm",relic="eye", orbValue = 26},
    {name="Bodley",relic="nail", orbValue = 27},
    {name="Laruba",relic="ring", orbValue = 28},
}

cv2.towns = {
    {name = "Doina"},
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
        exp=1,attack=0
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
        attack=7,
        hp=1,
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
    [0x10] = {name="Skull", exp=2, hp=1},
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
        attack = 4,
        hp = 10,
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
    [0x19] = {name="Skeledrag Segment", exp=1, hp="initial"},
    [0x1A] = {name="Skeledrag Segment", exp=1, hp="initial"},
    [0x1B] = {name="Eagle", exp=1},
    [0x1C] = {name="Deborah Cliff Tornado ", exp=0, hp="initial"},
    [0x1D] = {name="Flameman", exp=2},
    [0x1E] = {name="Secret Merchant", exp=0, hp="initial"},
    [0x1F] = {name="Blob", exp=1},
    [0x20] = {name="Spikeshot", exp=0, hp="initial"},
    [0x21] = {name="Sideways block", exp=0, hp="initial"},
    [0x22] = {name="Floating block", exp=0, hp="initial"},
    [0x23] = {name="?", exp=0},
    [0x24] = {
        name="Sign",
        exp=0,
        hp="initial",
    },
    [0x25] = {name="Orb", exp=0, hp="initial"},
    [0x26] = {name="Sacred Flame", exp=0, hp="initial"},
    [0x27] = {name="Book", exp=0, hp="initial"},
    [0x28] = {name="Town Man", exp=0, hp="initial"},
    [0x29] = {name="Town Woman", exp=0, hp="initial"},
    [0x2A] = {name="Town Man", exp=0, hp="initial"},
    [0x2B] = {name="Town Man", exp=0, hp="initial"},
    [0x2C] = {name="Town Old Woman", exp=0, hp="initial"},
    [0x2D] = {name="Priest", exp=0, hp="initial"},
    [0x2E] = {name="Merchant", exp=0, hp="initial"},
    [0x2F] = {name="Town Knight", exp=0, hp="initial"},
    [0x30] = {name="Fireball", exp=0, hp="initial"},
    [0x31] = {name="Fireball", exp=0, hp="initial"},
    [0x32] = {name="Fireball (from flame man)", exp=0, hp="initial"},
    [0x33] = {
        name="Spider Web",
        exp=0,
        hp=1,
        attack=5,
    },
    [0x34] = {name="Single Floating Block", exp=0, hp="initial"},
    [0x35] = {name="Town Old Man", exp=1, hp=0},
    [0x36] = {name="Flame after killing enemy", exp=0},
    [0x37] = {name="Heart", exp=0, hp="initial"},
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
    [0x3C] = {name="Ferry Man", exp=0, hp="initial"},
    [0x3D] = {name="Ferry Boat", exp=0, hp="initial"},
    [0x3E] = {name="Falling Rock", exp=0, hp="initial"},
    [0x3F] = {name="Thornweed", exp=1},
    [0x40] = {name="Swamp Worm (high)", exp=1},
    [0x41] = {
        name="High Jump Blob",
        exp=1,
        hp=4,
        attack=7,
    },
    [0x42] = {name="Camilla", exp=50},
    [0x43] = {
        name="Marsh",
        exp=0,
        hp="initial",
        },
    [0x44] = {name="Death", exp=100},
    [0x45] = {name="Camilla drops", exp=0, hp="initial"},
    [0x46] = {name="Death hatchet", exp=0, hp="initial"},
    [0x47] = {
        name="Dracula",
        exp=0,
        hp=255,
    },
    [0x48] = {name="Dracula shot", exp=0, hp="initial"},
    [0x49] = {name="Item after killing boss", exp=1, hp="initial"},
    [0x4A] = {name="Skeledrag", exp=2},
    [0x4B] = {name="Money bags rising", exp=0, hp="initial"},
    [0x4C] = {name="Flame that burns dracula's parts", exp=0, hp="initial"},
    [0x4D] = {name="Flame that ends game", exp=0, hp="initial"},
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
locations[0][19]={[0]='(room)','(room)','(room)'}
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

locations.getAreaName = function(a1,a2,a3,a4)
    if locations[a1] and locations[a1][a2] and locations[a1][a2][a3] then
--        if a4==1 then
--            return string.format("%s (%s)", locations[a1][a2][a3].displayName, locations[0][a1][0].displayName)
--        end
        return locations[a1][a2][a3].displayName
    else
        return string.format('%s %s %s',a1 or 0,a2 or 0,a3 or 0)
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
        {x=40, y=0xb0, text="Belasco Marsh"},
        {x=0xb5, y=0xbc, text="South Bridge"},
        {x=0xe0, y=0xdb, text="Veros"},
        {x=0xf7, y=0xc6, text="Veros Woods"},
        {x=0x0e, y=0x64, text="Dead River"},
        {x=0x0e, y=0x55, text="Alba"},
        {x=0x25, y=0x7a, text="Bhram's\n Mansion"},
        {x=0x5a, y=0x89, text="Castlevania"},
        {x=0xfd, y=0xaa, text="Berkeley\n Mansion"},
        {x=0x19e, y=0xbd, text="Rover\n Mansion"},
        {x=0x191, y=0xd5, text="Yuba Lake"},
        {x=0x121, y=0x98, text="Denis\n Woods"},
        {x=0xfc, y=0x8f, text="Denis\n Marsh"},
        {x=0xf3, y=0x7d, text="East Bridge"},
        {x=0x57, y=0x9e, text="Vrad Mountain"},
    }
}

-- Clue numbering based on this: http://castlevania.wikia.com/wiki/13_Clues
-- which in turn was based on a Japanese guide book.
cv2.clues = {0x1e, 0x1f, 0x20, 0x42, 0x0d, 0x22, 0x21, 0x5c, 0x24, 0x23, 0x14, 0x25, 0x11}

cv2.messages = {
    [0x0b]={
        {
            text = "SURE I'LL\nTAKE YOU TO\nA GOOD\nPLACE. HEH,\nHEH.",
            notes = "toned down the laughing and !!.  why is he shouting?",
        }
    },
    [0x0d]={
        {
            text = "KNEEL BY THE\nLAKE WITH THE\nBLUE CRYSTAL.",
            notes = "no more sutff about replenishing earth.",
        }
    },
    [0x0e]={
        {
            condition=function() return hasInventoryItem("Flame Whip") end,
            text="GOOD LUCK.",
        },
        {
            condition=function() return hasInventoryItem("Morning Star")==false end,
            text="TO BREAK MY\nSPELL, COME\nBACK WITH A\nPOWERFUL\nWEAPON.",
        },
        {
            text = "I'LL GIVE\nYOUR MORNING\nSTAR POWER\nTO BURN AWAY\nEVIL.",
        }
    },
    [0x10]={
        {
            condition=function() return hasInventoryItem("Silver Knife") end,
            text="GOOD LUCK.",
        },
        {
            text = "I'LL GIVE\nYOU THIS\nSILVER KNIFE\nTO SAVE YOUR\nNECK.",
        }
    },
    [0x11]={
        {
            text = "DEATH'S\nHIDDEN\nKNIFE BLURS\nCARMILLA'S\nVISION.",
        }
    },
    [0x12]={
        {
            condition=function() return hasInventoryItem("Diamond")==true end,
            text="DIAMONDS ARE\nFOREVER.",
            notes="Could use a better message here, or maybe just make the guy gone.",
        },
        {
            text = "I'LL GIVE\nYOU A\nDIAMOND.",
        }
    },
    [0x14]={
        {
            text = "DRACULA'S\nNAIL MAY\nSOLVE\nTHE EVIL\nMYSTERY.",
            notes = "Need something to indicate that it breaks walls.",
        }
    },
    [0x1e]={
        {
            text = "A SYMBOL OF\nDRACULA WILL \nAPPEAR WHEN\nUSING THE\nSTAKE.",
        }
    },
    [0x1f]={
        {
            text = "DESTROY THE\nCURSE AND\nYOU'LL RULE\nBRAHM'S\nMANSION.",
        }
    },
    [0x20]={
        {
            text = "A FLAME\nFLICKERS\nINSIDE THE\nRING OF\nFIRE.",
        }
    },
    [0x21]={
        {
            text = "GARLIC IN\nTHE\nGRAVEYARD\nSUMMONS A\nSTRANGER.",
        }
    },
    [0x22]={
        {
            text = "DESTROY THE\nCURSE WITH\nDRACULA'S\nHEART.",
        }
    },
    [0x23]={
        {
            text = "PLACE THE\nLAURELS IN A\nSILK BAG TO\nBRING THEM\nTO LIFE.",
        }
    },
    [0x24]={
        {
            text = "KNEEL WITH\nA RED CRYSTAL\nAT DEBORAH\nCLIFF.",
        }
    },
    [0x25]={
        {
            text = "THE CURSE\nHAS KILLED\nTHE LAUREL\nTREE.",
        }
    },
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
    [0x42]={
        {
            text = "CLEAR A PATH\nAT BERKELEY\nMANSION WITH\nA WHITE\nCRYSTAL.",
        }
    },
    [0x5c]={
        {
            text = "AN OLD GYPSY\nHOLDS A\nDIAMOND IN\nSOUTHERN JAM\nWASTELAND.",
        }
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
    [0x66]={
        {
            cycle = true,
            text = {
                "GET A SILK\nBAG FROM A\nMAN IN\nSTORIGORI\nGRAVEYARD.",
                "A SILK BAG\nCAN BE USED\nTO CARRY\nLAURELS.",
                "I HATE DUCKS.\nDUCKS SCARE\nME MORE THAN\nDRACULA.",
            }
        }
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
    [0x78]={
        {
            condition=function() return hasInventoryItem("Pendant") end,
            text="GOOD LUCK.",
        },
        {
            text = "THIS PENDANT\nWILL HELP YOU\nSURVIVE JOMA\nMARSH.",
        }
    },

}

cv2.placedItems = {
    {x=0x198, y=0x9d, area = {0x02,0x03,0x01}, name="Simon's Plate", location="dabis path on some bricks."},
    {x=0x38, y=0x13d, area = {0x02,0x03,0x03}, name="Night Armor", location="below aljiba woods to left of stairs."},
    {x=0x3e8, y=0x9d, area = {0x00,0x00,0x00}, name="Gold", location="jova top right side."},
    {x=0xd8, y=0x5d, area = {0x00,0x07,0x00, 0x05}, name="Church's Chicken", location="church in doina."},
    {x=0x58, y=0xbd, area = {0x00,0x08,0x00, 0x00}, name="Gold", location="room with thorn whip in jova."},
    {x=0xb8, y=0x9d, area = {0x00,0x07,0x00, 0x00}, name="Axe", location="church in jova."},
}

cv2.placedItems = {} -- disabled

cv2.candles = {
}


cv2.story = [[
       PROLOGUE


- 1698 -

            It was 
            seven 
            years
            ago that 
            Simon 
            Belmont,
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

cv2.credits = [[
           CREDITS            



        Castlevania II        
        Simon's Quest

           by Konami          




  Castlevania II Improvement  
   Lua Script by SpiderDave   



Coding..............SpiderDave
Candle Edits......krunkcleanup
Graphics/edit.......THiN CRUST
Play Testing......krunkcleanup
Play Testing.........Snorenado
NirCmd.........www.nirsoft.net




]]


cv2.medusaHeads = {
    {x1=0xae, x2=0x250, area = {0x04,0x00,0x00}, location="Vrad Mountain", },
    {x1=0x180, x2=0x3d9, area = {0x03,0x00,0x00}, location="Camilla Cemetary", },
}

cv2.sounds = {
    getMoneyBag = "cv1/23.wav"
}


return cv2