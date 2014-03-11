_mf = {}
_mf._oldFuncs = {}
_mf._hookFuncs = {}
_mf._preHookTables = {}
_mf._postHookTables = {}
--local function onInit ()

--holy grail = http://pastebin.com/8KYbeX9g http://pastebin.com/KmVJFMyu http://pastebin.com/Rn5AuT2G http://pastebin.com/C3BS0HQB
--EXPLOSIONS.type.emit(object,intensity,range)
--Entity -> MapEntity -> Object
--self:super()
--MapEntity:emitOmniHeat(range, amt)
--end

--item.def.useMethod ( I think )
--parameters 1:(table)item 2:(table)actor 3:(number)angle 4:(number)unknown
--returns 1:(boolean)success
--Actor:propel(angle, force)
--Actor:applyForce(angle,force)

--<Trif> <thewreck> local soundToVisFactor = 1/250
--<Trif> <thewreck> local recoilToVisFactor = 0.5


--From Mr_TP's weapon pack
function _mf.deepcopy(object)
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

function _mf.addPreHook(target, callback)
	local hooked = _mf.setfield(target)
	_mf.setfield(target, function (...)
		if callback(...) ~= false then
			return hooked(...)
		end
	end)
end

function _mf.addPostHook(target, callback)
	local hooked = _mf.getfield(target)
	_mf.setfield(target, function (...)
		local returns = {hooked(...)}
		callback(returns, ...)
		return unpack(returns)
	end)
end

function _mf.createAttack(index, parent)
	if type(parent) == "table" then
		ATTACKS[index] = _mf.deepcopy(parent)
	elseif type(ATTACKS[parent]) == "table" then
		ATTACKS[index] = _mf.deepcopy(ATTACKS[parent])
	else
		ATTACKS[index] = {}
	end
	ATTACKS[index].index = index
	return ATTACKS[index]
end

function _mf.createObjectItem(index, parent, name)
	_mf.createObject(index, parent, name)
	OBJECTS[index].itemRefIndex = index
	_mf.createItem(index, parent, name)
	return OBJECTS[index], ITEMS[index]
end

function _mf.actorShootBullet(actor, bulletName, velocity, angle)
	local bullet = Object:new(bulletName, actor:getWeaponX(), actor:getWeaponY(), actor.map)
	actor.map:addObject(bullet)
	bullet:setOwner(actor)
	angle = angle or actor:getWeaponAngle()
	bullet:setAngle(angle)
	bullet:propel(angle, velocity or 50)
end

function _mf.actorShootGrenade(actor, grenadeName, velocity, angle)
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

--[[ deprecated
function _mf.createUseWeaponFunction(bulletName, velocity)
	return function(weapon, actor, angle)
		if weapon.ammo == nil then
			_mf.actorShootBullet(actor, bulletName, velocity, angle)
		elseif weapon.ammo > 0 then
			_mf.actorShootBullet(actor, bulletName, velocity, angle)
			weapon.ammo = weapon.ammo - 1
			return true
		end
		return false
	end
end

function _mf.createUseGrenadeFunction(grenadeName, velocity)
	return function(weapon, actor, angle)
		if weapon.ammo == nil then
			_mf.actorShootGrenade(actor, grenadeName, velocity, angle)
		elseif weapon.ammo > 0 then
			_mf.actorShootGrenade(actor, grenadeName, velocity, angle)
			weapon.ammo = weapon.ammo - 1
			return true
		end
		return false
	end
end
--]]



function _mf._addhook (target, callback, hooktype)
	if _mf._oldFuncs[target] == nil then -- we need to create the hook first time round
		_mf._oldFuncs[target] = _mf.getfield(target) -- store the old function
		_mf._hookFuncs[target] = function (...) -- create the new function
			local args = _mf._prehook(target, {...}) -- call all of the prehooks
			if(args == nil) then return end -- a nil return means the 'event' was cancelled
			local values = {_mf._oldFuncs[target](unpack(args))} -- call the original function
			return unpack(_mf._posthook(target, values, args)) -- call all of the post hooks
			--return false
		end
		_mf.setfield(target, _mf._hookFuncs[target]) -- set the new function to be called
		_mf._preHookTables[target] = {n = 0} -- setup pre hook storage
		_mf._postHookTables[target] = {n = 0} -- setup post hook storage
	end
	if hooktype == nil or callback == nil then return end
	if hooktype == "pre" then
		_mf._preHookTables[target].n = _mf._preHookTables[target].n + 1
		_mf._preHookTables[target][_mf._preHookTables[target].n] = callback
	elseif hooktype == "post" then
		--print("callback added")
		_mf._postHookTables[target].n = _mf._postHookTables[target].n + 1
		_mf._postHookTables[target][_mf._postHookTables[target].n] = callback
	end
end

function _mf._prehook (target, args)
	for i,v in ipairs(_mf._preHookTables[target]) do
		args = v(args)
		if args == nil then return nil end
	end
	return args
end

function _mf._posthook (target, values, args)
	--print("posthook")
	--print(target)
	for k,v in pairs(_mf._postHookTables[target]) do
		if k ~= "n" then
			--print("callback")
			values = v(values, args)
		end
	end
	return values
end

function _mf.getfield (f)
	local v = _G    -- start with the table of globals
	for w in string.gfind(f, "[%w_]+") do
		v = v[w]
	end
	return v
end

function _mf.setfield (f, v)
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

function _mf.report(returns)
	_mf.recursivePrint(returns, 2)
end

local function sortFunc(a, b)
	aType = type(a)
	bType = type(b)
	if(aType == bType) then
		if aType == "table" then
			return true
		else
			return a < b
		end
	else
		if aType == "number" then
			return true
		elseif bType == "number" then
			return false
		elseif aType == "string" then
			return true
		elseif bType == "string" then
			return false
		end
	end
end

function _mf.recursivePrint (values, level, indent)
	if type(values) ~= "table" then values = {values} end
	level = level or 1
	indent = indent or ""
	a = {}
    for k,_ in pairs(values) do table.insert(a, k) end
    table.sort(a)
	for _,k in pairs(a) do
		print(indent..tostring(k)," = "..tostring(values[k]))
		if(type(values[k]) == "table" and level > 1) then
			_mf.recursivePrint(values[k], level - 1, indent.."    ")
		end
	end
end

function _mf.recursiveSearch (search, values, level, indent)
	if type(values) ~= "table" then values = {values} end
	level = level or 1
	indent = indent or ""
	a = {}
    for k in pairs(values) do table.insert(a, k) end
    table.sort(a)
	for _,k in pairs(a) do
		if type(k) == "string" and string.find(string.lower(k), string.lower(search)) ~= nil then
			print(indent..tostring(k)," = "..tostring(values[k]))
			if(type(values[k]) == "table" and level > 1) then
				_mf.recursiveSearch(search, values[k], level - 1, indent.."    ")
			end
		end
	end
end

function _mf.recursiveWrite (file, values, level, indent)
	if type(values) ~= "table" then values = {values} end
	level = level or 1
	indent = indent or ""
	local a = {}
    for k,v in pairs(values) do table.insert(a, k) end
    table.sort(a)
	for _,k in ipairs(a) do
		file:write(indent)
		file:write(tostring(k))
		file:write(" = ")
		file:write(tostring(values[k]))
		if(type(values[k]) == "table" and level > 1) then
			file:write(" : {\n")
			_mf.recursiveWrite(file, values[k], level - 1, indent.."    ")
			file:write(indent.."}\n")
		else
			file:write("\n")
		end
	end
end

function _mf.dumpToFile (fileName, values, level)
	local file = io.open(fileName, "w")
	_mf.recursiveWrite(file, values, level)
	file:flush()
	file:close()
end

local function onInit()
	--Load Pigbones Files	
	assert(require("mfitems"))
	_mf._initItems()
	
	

	--_mf.recursiveSearch("missile",OBJECTS)
	--_mf.recursiveSearch("launcher",ITEMS)
	--_mf.dumpToFile ("dump.txt", OBJECTS)
	--local window = gui.createComponent("window")
	--window:setWidth(400)
	--window:setHeight(400)
	--window:centerOnParent()
	--daisy.setMouseVisible(true)
	--_mf.addPostHook("MapEntity.new", _mf.report)
	--_mf.recursivePrint(ITEMS.matterWar)
	--_mf.dumpToFile("matterWar.txt", ITEMS, 1)
	--_mf.dumpToFile("entity.txt",Entity,1)
end

local function renderMouse()
	daisy.setMouseVisible(true)
end

hook.add("gameInit", onInit)
--hook.add("frameRender", renderMouse)