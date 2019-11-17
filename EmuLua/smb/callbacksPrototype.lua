-- NOTE: INCOMPLETE (check callbacks.lua for more callbacks)

-- These are prototypes for the callbacks defined in callbacks.lua.
--
-- This file isn't meant to be used directly but helps define how
-- to use them, and they can be copied with comments as a convenience.

-- Called when checking Mario's status to determine if he can shoot fireballs.
-- Returning a value of 2 makes it so Mario can always shoot fireballs.
function onCheckIfFiery(status)
    return status
end

-- Called when player is injured.  If true is returned, injury is cancelled.
function onPlayerInjury(abort)
    --abort=true
    return abort
end


-- Called when enemy speed is set.
-- eType is the enemy type.
-- speed is the x velocity.
-- return a new speed to change the enemy's speed.
function onSetEnemySpeed(eType, speed)
end

-- Called when a color of the player's palette is set.
-- CurrentPlayer is 0 or 1 for Mario or Luigi.
-- PlayerStatus is 0x02 if fiery.
-- index is the index of palette (0 to 3).
-- c is the color number.
function onSetPlayerPalette(CurrentPlayer, PlayerStatus, index, c)
    return c
end

-- Called when the speed of a fireball is set.
-- axis is the axis "x" or "y".
-- s is the speed (-128 to 127)
-- sign is the sign of the speed (-1, 0, or 1)
function onSetFireballSpeed(axis, speed, sign)
    return speed
end

-- Called when handling the game timer.
-- useTimer is set to 1.
-- return a value of 0 to disable the timer.
function onGameTimer(useTimer)
    --useTimer = 0
    return useTimer
end

-- Called when playing a "square 1" sound.
function onSquare1SfxHandler(sfx)
    return sfx
end

-- ** These two metatile loading callbacks need work.
--    They don't catch all the tiles that are loaded, and 
--    lack some useful information, such as the position
--    of the metatiles.  The syntax may change.

-- Called when loading a background metatile**
function onLoadBackgroundMetatile(n)
    return n
end
-- Called when loading a foreground metatile**
function onLoadForegroundMetatile(n)
    return n
end

-- Called when music is played.
-- The values for music are:
--
-- 01 Ground
-- 02 Water
-- 04 Underground
-- 08 Castle
-- 10 Cloud
-- 20 Pipe Intro
-- 40 Star
-- 80 Silence
--
-- use the "Silence" value to remove music.  If 0 is used, 
-- most music will be gone, but the star music will
-- play forever.  This callback does not remove some of
-- the short music such as end of level music or hurry up 
-- music.
function onMusic(music)
    return music
end

-- Called when setting Lakitu's timer for throwing a spiny.
function onSetLakituTimer(t)
    return t
end

-- Called when lives are displayed on the intermediate screen.
-- digit is 0 for the lives x 10 "crown" digit
-- digit is 1 for the lives <=9 digit
-- lives is the current lives
function onLivesDisplay(digit, n, lives)
    return n
end