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
	
	--Make railGun bullets homing
	--OBJECTS.slugMedium.updateMethod = OBJECTS.homingMissile.updateMethod
	
	--Make the Rail Heater
	pigbones.createAttack("slugMediumHeated","slugMedium") --copy old attack into a new one
	ATTACKS.slugMediumHeated.damage = 0.3 --set damage lower
	ATTACKS.slugMediumHeated.heat = 2 --make the attack 'heated'
	pigbones.createObject("slugMediumHeated","slugMedium") --copy the old bullet into a new one
	OBJECTS.slugMediumHeated.attack = ATTACKS.slugMediumHeated --use the new 'heated' attack
	pigbones.createObjectItem("railHeater","railVanquisher","Rail Heater") --copy the old gun into a new one
	ITEMS.railHeater.cooldown = 0.1 --set the time between shots lower
	ITEMS.railHeater.maxAmmo = 15 --set the clip size high
	ITEMS.railHeater.bullet = "slugMediumHeated"
	
	--[[
	--Make blasters fire grenades
	pigbones.createObjectItem("armedSphereGrenade", "sphereGrenade", "Armed Sphere Grenade")
	OBJECTS.armedSphereGrenade.prepare = true
	OBJECTS.armedSphereGrenade.hitActive = true
	--ITEMS.blasterGun.bullet = "none"
	ITEMS.blasterGun.useMethod = ITEMS.grenadeGun.useMethod
	pigbones.recursivePrint(OBJECTS.sphereGrenade)
	--pigbones.addPostHook("OBJECTS.armedSphereGrenade.initMethod", deathphaser.onInitGrenade)
	--ITEMS.blasterGun.useMethod = pigbones.createUseGrenadeFunction("sphereGrenade", 30) --replace the firing function with one that shoots grenades
	--]]
	
	pigbones.createObjectItem("railTri","railVanquisher","Rail Shotgun")
	ITEMS.railTri.maxAmmo = 3
	--ITEMS.railTri.automatic = nil
	ITEMS.railTri.reloadTime = ITEMS.railCannon.reloadTime
	ITEMS.railTri.reloadSequence = ITEMS.railCannon.reloadSequence
	ITEMS.railTri.reloadAnimation = ITEMS.railCannon.reloadAnimation
	ITEMS.railTri.reloadBoosts = ITEMS.railCannon.reloadBoosts
	deathphaser.oldRailTriUseMethod = ITEMS.railScout.useMethod
	ITEMS.railTri.useMethod = deathphaser.onUseTriRail
	
	
end

function deathphaser.onInitGrenade(self)
	item = Item:new("armedSphereGrenade")
	item.prepare = true
	item.hitActive = true
	self.itemRef = item
	self.ref = item
end

function deathphaser.onPhaser (returns, object, player, angle) -- phaser function
	player:propel(angle,200) -- propel the shooter in the direction of the new angle
end

function deathphaser.onUseTriRail (weapon, actor, angle, ...)
	--print(getClassNameOf(weapon:super()))
	--pigbones.recursivePrint(weapon:super())
	--print(weapon:super())
	--pigbones.dumpToFile("actor.txt",actor,4)
	local x, y = actor:getAbsoluteNodeXY()
	weapon.def.bullet = "slugMediumHeated"
	local val = deathphaser.oldRailTriUseMethod(weapon, actor, angle, ...)
	local halfPi = math.pi / 2
	local spread = 15
	weapon.def.bullet = "slugMedium"
	actor:setPosition(x + math.cos(angle - halfPi) * spread, y + math.sin(angle - halfPi) * spread)
	deathphaser.oldRailTriUseMethod(weapon, actor, angle, ...)
	actor:setPosition(x + math.cos(angle + halfPi) * spread, y + math.sin(angle + halfPi) * spread)
	deathphaser.oldRailTriUseMethod(weapon, actor, angle, ...)
	actor:setPosition(x, y)
	return val
end

function deathphaser.onUseTriRailShotgun (weapon, actor, angle, ...)
	local spread = 0.1
	local val = deathphaser.oldRailTriUseMethod(weapon, actor, angle, ...)
	deathphaser.oldRailTriUseMethod(weapon, actor, angle + spread, ...)
	deathphaser.oldRailTriUseMethod(weapon, actor, angle + spread, ...)
	return val
end



hook.add("gameInit", onInit) -- call onInit when the game starts