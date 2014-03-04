deathphaser = {} -- create our own table to store global functions (so we don't overwrite anything)

local function onInit()
	--pigbones.recursivePrint(ITEMS)
    pigbones.setItemData("phaserGun","aimRange",2000)
	pigbones.setItemData("phaserGun","alwaysAim",true)
	pigbones.setAttackData("physical","damage",0)
	pigbones.setAttackData("physical","useImpulseDamageModifier",false)
	--ACTIONS.item.getters.isType.parameters.itemType.table.phaserGun.ai.attackDist = 2000
	--ACTIONS.item.getters.isType.parameters.itemType.table.phaserGun.ai.attackArc = 0.03
	--ACTIONS.item.getters.isType.parameters.itemType.table.phaserGun.ai.dangerFactor = 10
	ITEMS.phaserGun.ai.attackDist = 2000
	ITEMS.phaserGun.ai.attackArc = 0.03
	ITEMS.phaserGun.ai.dangerFactor = 10
	pigbones.addhook("ITEMS.phaserGun.useMethod", deathphaser.onPhaser, "post")
	pigbones.addhook("Actor.onSpawned", deathphaser.actorSpawned, "post")
end

function deathphaser.onPhaser (values,args) -- our recoil function (which is called when a gun has finished firing)
	if(values[1] == true) then -- if the gun actually fired
		args[2]:propel(args[3],200) -- propel the shooter in the direction of the new angle a proportion of the gun's real recoil
	end
	return values -- return the values so that the game can still use them VERY IMPORTANT
end

function deathphaser.actorSpawned (values,args)
	--pigbones.recursivePrint(args)
	return values
end

hook.add("gameInit", onInit) -- call onInit when the game starts