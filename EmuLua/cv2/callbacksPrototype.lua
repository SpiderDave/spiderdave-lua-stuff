-- These are prototypes for the callbacks defined in callbacks.lua.
--
-- This file isn't meant to be used directly but helps define how
-- to use them, and they can be copied with comments as a convenience.

-- Called when setting Simon's walk speed.  speed will be negative if moving left.
function onWalkSpeed(speed)
    return speed
end

-- Called when setting Simon's walk speed left. speed will be negative.
function onWalkSpeedLeft(speed)
    return speed
end

-- Called when setting Simon's walk speed right.
function onWalkSpeedRight(speed)
    return speed
end

-- Called when Simon stops walking.  Also fires when landing from a jump.
function onWalkStop()
    return speed
end

-- Called when setting Simon's jump speed left. speed will be negative.
function onJumpSpeedLeft(speed)
    return speed
end

-- Called when setting Simon's jump speed right.
function onJumpSpeedRight(speed)
    return speed
end

-- Called when setting Simon's jump speed.  speed will be negative if moving left.
function onJumpSpeed(speed)
    return speed
end

-- Called when entering sub screen
function onEnterSubScreen()
end

-- Called when creating an enemy
function onCreateEnemy(index, enemyType)
    return enemyType
end

-- Called when creating an enemy projectile
function onCreateEnemyProjectile(index, projectileType, x, y)
    return projectileType
end

-- Called when starting a game (suitable for setting starting area)
function onStartGame()
end

-- Modify the lives display value
function onPrintLives(lives)
    return lives
end

-- experience gain from hearts
function onExpGain(e)
    return e
end

-- Called when setting the delay for each whip state
function onSetWhipFrameDelay(delay, whipState)
    return delay
end

-- Called when setting jump y-velocity
function onSetJumpSpeedY(v, onPlatform)
    return v
end

-- Called when placing a 8x8 tile.
-- note: will undo it if you sub screen or message over the block
function onPlaceStageTile(tile)
    return tile
end

-- Called when stunning an enemy with whip.
-- Default stun is 0x10
-- Player's whip is out for 9 frames, so setting it low means they get hit more than once.
function onEnemyStun(stunTime)
    return stunTime
end

-- Called when getting hearts from a heart item.
function onHeartPickup(n)
    return n
end

-- Called when Simon throws a special weapon
-- abort is always false when called, added as a convenience.
function onThrowWeapon(weaponType, abort)
    return weaponType, abort
end

-- Called when setting special weapon on the sub menu
function onSetWeapon(weapon)
    return weapon
end

-- Called when getting the RedCrystal
function onGetRedCrystal()
end

-- Called when getting the Cross
function onGetRedCross()
end

-- Called when getting the Diamond
function onGetDiamond()
end

-- Called when using a laurel.  amount is the amount of 
-- laurels to set to.
function onUseLaurel(amount)
    return amount
end

-- Called when the end credits start
-- endingNum is the ending to show:
--   1 (worst ending)
--   2 (better ending)
--   3 (best ending)
function onEnding(endingNum)
    return endingNum
end

