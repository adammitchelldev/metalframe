deathphaser = {} -- create our own table to store global functions (so we don't overwrite anything)

local function onInit()
    ITEMS.phaserGun.aimRange = 2000
	ITEMS.phaserGun.alwaysAim = true
	ATTACKS.physical.damage = 0
	ATTACKS.physical.useImpulseDamageModifier = false
	ITEMS.phaserGun.ai.attackDist = 2000
	ITEMS.phaserGun.ai.attackArc = 0.03
	ITEMS.phaserGun.ai.dangerFactor = 10
	OBJECTS.phaserBullet.bulletTimeDistanceFactor = 2
	OBJECTS.phaserBullet.bulletTimeFactor = 5
	pigbones.addPostHook("ITEMS.phaserGun.useMethod", deathphaser.onPhaser)
	
	ITEMS.blasterGun.useMethod = pigbones.createUseGrenadeFunction("sphereGrenade", 30)
end

function deathphaser.onPhaser (returns, object, player, angle) -- phaser function
	player:propel(angle,200) -- propel the shooter in the direction of the new angle
end



hook.add("gameInit", onInit) -- call onInit when the game starts