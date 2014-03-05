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

function pigbones.addhook (target, callback, hooktype)
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

function pigbones.recursivePrint (values, indent, level)
	level = level or 1
	indent = indent or ""
	for k,v in pairs(values) do
		print(indent..tostring(k)..":"..tostring(v))
		if(type(v) == "table" and level < 2) then
			pigbones.recursivePrint(v, indent.."    ", level + 1)
		end
	end
end
	
--hook.add("gameInit", onInit)