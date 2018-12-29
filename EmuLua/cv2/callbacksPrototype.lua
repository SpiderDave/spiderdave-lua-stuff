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

-- Called when a sub weapon cost is applied
function onSubWeaponCost(cost)
    return cost
end

-- Called when a sub weapon breaks
function onSubWeaponBreak(weaponType, weaponIndex)
    return weaponType
end

-- Called just after enemy creation is finished
-- Suitable for manipulating enemy data.
function onEnemyCreated(enemyIndex, enemyType, enemyX, enemyY)
end

-- Called continually when on continue screen
function onContinueScreen()
end

-- Called just as a message is created, before it's displayed.
-- Cancel only works for automatic messages.
function onMessage(messageNum, cancel)
    return messageNum, cancel
end

-- Called when a message is about to be printed.
function onMessage2(messageNum)
    return messageNum
end

-- Called as a message is printed, suitable for
-- setting the address where the message starts.
function onMessageWriteAddress(address)
    return address
end

-- Called when setting the player's facing direction when hit.
function onSetPlayerFacingWhenHit(newFacing, facing)
    return newFacing
end

-- Called when setting the player's velocity when hit.
-- Called for each axis.  Values for axis are strings: "x", "y".
-- v1 and v2 are the two byte values for speed (major, minor)
-- Alternately, return only v in place of v1, v2 to use the major value as a signed int.
function onSetPlayerVelocityWhenHit(axis, v1, v2)
    
    -- return v
    return v1, v2
end

-- Called when setting the player's state when hit.
function onSetPlayerStateWhenHit(newState, state)
    return newState
end

-- Called when setting the player's frame when hit.
-- note, frame values dont' match.  the first one is more like an animation set
function onSetPlayerFrameWhenHit(newFrame, frame)
    return newFrame
end

-- Called when setting the player's starting lives.
function onSetStartingLives(lives)
    return lives
end


-- Called when an enemy deals damage.
function onEnemyDamage(index,enemyType,damage)
    return damage
end

-- Called when the player deals damage with the whip.
function onWhipDamage(damage, target)
    return damage
end

-- Called when a heart cost is checked (for buying or using sub weapon).
function onHeartCost(cost)
    return cost
end

-- Called when a heart cost is deducted (for buying or using sub weapon).
-- There are two of these, for both bytes of the heart value.
function onDeductHeartCost1(oldHeartValue, newHeartValue)
    return oldHeartValue
end
function onDeductHeartCost2(oldHeartValue, newHeartValue)
    return oldHeartValue
end

-- Called during vertical blanking.
-- Suitable for things like ppu writes.
function onVBlank()
end

-- Called when attacking to check if it's an attempt to
-- use a sub weapon or whip.
function onWhipOrSubWeapon(isSubWeapon)
    return isSubWeapon
end

-- Called when getting the sacred flame
function onGetSacredFlame()
end

-- Called when getting the silver knife.
function onGetSilverKnife()
end

-- Called when getting the golden knife.
function onGetGoldenKnife()
end
