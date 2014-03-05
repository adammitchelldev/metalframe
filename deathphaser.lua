deathphaser = {} -- create our own table to store global functions (so we don't overwrite anything)

local function onInit()
    ITEMS.phaserGun.aimRange = 2000
	ITEMS.phaserGun.alwaysAim = true
	ATTACKS.physical.damage = 0
	ATTACKS.physical.useImpulseDamageModifier = false
	ITEMS.phaserGun.ai.attackDist = 2000
	ITEMS.phaserGun.ai.attackArc = 0.03
	ITEMS.phaserGun.ai.dangerFactor = 10
	pigbones.addPostHook(ITEMS.phaserGun.useMethod, onPhaser)
end

local function onPhaser (values,args) -- our recoil function (which is called when a gun has finished firing)
	if(values[1] == true) then -- if the gun actually fired
		args[2]:propel(args[3],200) -- propel the shooter in the direction of the new angle a proportion of the gun's real recoil
	end
	return values -- return the values so that the game can still use them VERY IMPORTANT
end

hook.add("gameInit", onInit) -- call onInit when the game starts