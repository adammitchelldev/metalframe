
-- Loads files from the mod folder.

_mf.modhandle = {}

function _mf.modhandle.loadInfo(modname)
	-- Currently handling ini files as a table. Will fix this later.
	return assert(loadfile(modname ..".ini"))()
end

function _mf.modhandle.loadMod(modname)
	return assert(loadfile(modname ..".lua"))
end