pigbones = {}
pigbones._oldFuncs = {}
pigbones._hookFuncs = {}
pigbones._preHookTables = {}
pigbones._postHookTables = {}
--local function onInit ()

--end

--item.def.useMethod ( I think )
--parameters 1:(table)item 2:(table)actor 3:(number)angle 4:(number)unknown
--returns 1:(boolean)success
--Actor.propel(angle, force)
--Actor.applyForce(angle,force)

--From Mr_TP's weapon pack
function pigbones.deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, _copy(getmetatable(object)))
    end
    return _copy(object)
end

function pigbones.addPreHook(target, callback)
	local hooked = pigbones.setfield(target)
	pigbones.setfield(target, function (...)
		if callback(...) ~= false then
			return hooked(...)
		end
	end)
end

function pigbones.addPostHook(target, callback)
	local hooked = pigbones.getfield(target)
	pigbones.setfield(target, function (...)
		local returns = {hooked(...)}
		callback(returns, ...)
		return unpack(returns)
	end)
end

function pigbones.createAttack(index, parent)
	if type(parent) == "table" then
		ATTACKS[name] = pigbones.deepcopy(parent)
	elseif type(ATTACKS[parent]) == "table" then
		ATTACKS[name] = pigbones.deepcopy(ATTACKS[parent])
	else
		ATTACKS[name] = {}
	end
	ATTACKS[name].index = name
	return ATTACKS[name]
end

function pigbones.createObject(index, parent, name)
	if type(parent) == "table" then
		OBJECTS[index] = pigbones.deepcopy(parent)
	elseif type(OBJECTS[parent]) == "table" then
		OBJECTS[index] = pigbones.deepcopy(OBJECTS[parent])
	else
		OBJECTS[index] = {}
	end
	OBJECTS[index].index = index
	OBJECTS[index].id = index
	OBJECTS[index].name = name or index
	return OBJECTS[index]
end

function pigbones.createItem(index, parent, name)
	if type(parent) == "table" then
		ITEMS[index] = pigbones.deepcopy(parent)
	elseif type(ITEMS[parent]) == "table" then
		ITEMS[index] = pigbones.deepcopy(ITEMS[parent])
	else
		ITEMS[index] = {}
	end
	ITEMS[index].index = index
	ITEMS[index].name = name or index
	return ITEMS[index]
end

function pigbones.createObjectItem(index, parent, name)
	pigbones.createObject(index, parent, name)
	OBJECTS[index].itemRefIndex = index
	pigbones.createItem(index, parent, name)
	return OBJECTS[index], ITEMS[index]
end

function pigbones.createAmmo(index, parent, name, small, medium, large, icon)
	pigbones.createObjectItem(index, parent, name)
	ITEMS.ammoSmall.ammoAmounts[index] = small or ITEMS.ammoSmall.ammoAmounts[parent]
	ITEMS.ammoSmallDouble.ammoAmounts[index] = small or ITEMS.ammoSmall.ammoAmounts[parent]
	ITEMS.ammoMedium.ammoAmounts[index] = medium or ITEMS.ammoMedium.ammoAmounts[parent]
	ITEMS.ammoMediumDouble.ammoAmounts[index] = medium or ITEMS.ammoMediumDouble.ammoAmounts[parent]
	ITEMS.ammoLarge.ammoAmounts[index] = large or ITEMS.ammoLarge.ammoAmounts[parent]
	ITEMS.ammoLargeDouble.ammoAmounts[index] = large or ITEMS.ammoLargeDouble.ammoAmounts[parent]
	return OBJECTS[index], ITEMS[index]
end

function pigbones.actorShootBullet(actor, bulletName, velocity, angle)
	local bullet = Object:new(bulletName, actor:getWeaponX(), actor:getWeaponY(), actor.map)
	actor.map:addObject(bullet)
	bullet:setOwner(actor)
	angle = angle or actor:getWeaponAngle()
	bullet:setAngle(angle)
	bullet:propel(angle, velocity or 50)
end

function pigbones.actorShootGrenade(actor, grenadeName, velocity, angle)
	local bullet = Object:new(grenadeName, actor:getWeaponX(), actor:getWeaponY(), actor.map)
	angle = angle or actor:getWeaponAngle()
	if grenadeName ~= "grenade" then 
		item = Item:new(grenadeName)
		if grenadeName == "spikedMine" then
			item.active = false
			item.stick = true
		else
			item.prepare = true
			item.hitActive = true
		end
		bullet.itemRef = item
	end
	actor.map:addObject(bullet)
	bullet:setOwner(actor)
	bullet:setAngle(angle)
	bullet:propel(angle, velocity or 50)
end

function pigbones.createUseWeaponFunction(bulletName, velocity)
	return function(weapon, actor, angle)
		if weapon.ammo == nil then
			pigbones.actorShootBullet(actor, bulletName, velocity, angle)
		elseif weapon.ammo > 0 then
			pigbones.actorShootBullet(actor, bulletName, velocity, angle)
			weapon.ammo = weapon.ammo - 1
			return true
		end
		return false
	end
end

function pigbones.createUseGrenadeFunction(grenadeName, velocity)
	return function(weapon, actor, angle)
		if weapon.ammo == nil then
			pigbones.actorShootGrenade(actor, grenadeName, velocity, angle)
		elseif weapon.ammo > 0 then
			pigbones.actorShootGrenade(actor, grenadeName, velocity, angle)
			weapon.ammo = weapon.ammo - 1
			return true
		end
		return false
	end
end

function pigbones._addhook (target, callback, hooktype)
	if pigbones._oldFuncs[target] == nil then -- we need to create the hook first time round
		pigbones._oldFuncs[target] = pigbones.getfield(target) -- store the old function
		pigbones._hookFuncs[target] = function (...) -- create the new function
			local args = pigbones._prehook(target, {...}) -- call all of the prehooks
			if(args == nil) then return end -- a nil return means the 'event' was cancelled
			local values = {pigbones._oldFuncs[target](unpack(args))} -- call the original function
			return unpack(pigbones._posthook(target, values, args)) -- call all of the post hooks
			--return false
		end
		pigbones.setfield(target, pigbones._hookFuncs[target]) -- set the new function to be called
		pigbones._preHookTables[target] = {n = 0} -- setup pre hook storage
		pigbones._postHookTables[target] = {n = 0} -- setup post hook storage
	end
	if hooktype == nil or callback == nil then return end
	if hooktype == "pre" then
		pigbones._preHookTables[target].n = pigbones._preHookTables[target].n + 1
		pigbones._preHookTables[target][pigbones._preHookTables[target].n] = callback
	elseif hooktype == "post" then
		--print("callback added")
		pigbones._postHookTables[target].n = pigbones._postHookTables[target].n + 1
		pigbones._postHookTables[target][pigbones._postHookTables[target].n] = callback
	end
end

function pigbones._prehook (target, args)
	for i,v in ipairs(pigbones._preHookTables[target]) do
		args = v(args)
		if args == nil then return nil end
	end
	return args
end

function pigbones._posthook (target, values, args)
	--print("posthook")
	--print(target)
	for k,v in pairs(pigbones._postHookTables[target]) do
		if k ~= "n" then
			--print("callback")
			values = v(values, args)
		end
	end
	return values
end

function pigbones.getfield (f)
	local v = _G    -- start with the table of globals
	for w in string.gfind(f, "[%w_]+") do
		v = v[w]
	end
	return v
end

function pigbones.setfield (f, v)
	local t = _G    -- start with the table of globals
	for w, d in string.gfind(f, "([%w_]+)(.?)") do
		if d == "." then      -- not last field?
			t[w] = t[w] or {}   -- create table if absent
			t = t[w]            -- get the table
		else                  -- last field
			t[w] = v            -- do the assignment
		end
	end
end

function pigbones.recursivePrint (values, levels, indent)
	level = level or 1
	indent = indent or ""
	for k,v in pairs(values) do
		print(indent..tostring(k)..":"..tostring(v))
		if(type(v) == "table" and level > 1) then
			pigbones.recursivePrint(v, level - 1, indent.."    ")
		end
	end
end
	
--hook.add("gameInit", onInit)