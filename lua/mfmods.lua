
-- Table containing all the functions need to access and create mods
_mf.mods = {}

_mf.modlist = {}
_mf.modorder = {}

_mf.mods.Instance = {}
_mf.mods.Instance_mt = { __index = _mf.mods.Instance }

function _mf.mods.Instance:new(modname)
	local m = {}

	setmetatable(m, _mf.mods.Instance_mt)

	m.name = modname
	m.active = true

	_mf.modlist[modname] = m

	return m
end

function _mf.load(modname)
	if not _mf.modlist[modname] then
		chunk = assert(loadfile("mods/" ..modname))
	end
end