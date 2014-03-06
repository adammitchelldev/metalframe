deathphaser = {} -- create our own table to store global functions (so we don't overwrite anything)

local function onInit()
	--Edit the phaser
    ITEMS.phaserGun.aimRange = 2000 --set the aim range high for long range auto-aim
	ITEMS.phaserGun.alwaysAim = true --make auto-aim permanently on
	ATTACKS.physical.damage = 0 --turn off fall (or wall) damage
	ATTACKS.physical.useImpulseDamageModifier = false --extra precaution
	ITEMS.phaserGun.ai.attackDist = 2000 --let the AI know the new attack distance
	ITEMS.phaserGun.ai.attackArc = 0.03 --let the AI know the new attack doesn't drop as much
	ITEMS.phaserGun.ai.dangerFactor = 10 --let the AI know it's good
	OBJECTS.phaserBullet.bulletTimeDistanceFactor = 2 --increase bullet time (i think)
	OBJECTS.phaserBullet.bulletTimeFactor = 5 --increase bullet time
	pigbones.addPostHook("ITEMS.phaserGun.useMethod", deathphaser.onPhaser) --hook into the old firing function
	
	--Make the Rail Heater
	pigbones.createAttack("slugMediumHeated","slugMedium") --copy old attack into a new one
	ATTACKS.slugMediumHeated.damage = 0.3 --set damage lower
	ATTACKS.slugMediumHeated.heat = 2 --make the attack 'heated'
	pigbones.createObject("slugMediumHeated","slugMedium") --copy the old bullet into a new one
	OBJECTS.slugMediumHeated.attack = ATTACKS.slugMediumHeated --use the new 'heated' attack
	pigbones.createObjectItem("railHeater","railVanquisher","Rail Heater") --copy the old gun into a new one
	ITEMS.railHeater.cooldown = 0.1 --set the time between shots lower
	ITEMS.railHeater.maxAmmo = 30 --set the clip size high
	ITEMS.railHeater.useMethod = pigbones.createUseWeaponFunction("slugMediumHeated", 100) --replace the firing function with a new one that fires the new bullet
	
	--Make blasters fire grenades
	ITEMS.blasterGun.useMethod = pigbones.createUseGrenadeFunction("sphereGrenade", 30) --replace the firing function with one that shoots grenades
end

function deathphaser.onPhaser (returns, object, player, angle) -- phaser function
	player:propel(angle,200) -- propel the shooter in the direction of the new angle
end



hook.add("gameInit", onInit) -- call onInit when the game starts