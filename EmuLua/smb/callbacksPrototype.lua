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

