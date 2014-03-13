
-- Mods files: info file (.ini) / mod file (.lua)
-- Table containing all the functions needed to access and create mods
_mf.mods = {}

-- A table containing tables filled with the mod and about information.
_mf.modlist = {}

_mf.mods.Instance = {}
_mf.mods.Instance_mt = { __index = _mf.mods.Instance }

-- We will store a sequence of strings in this table. Their position indicates their load priority.
_mf.loadorder = {}

function _mf.mods.Instance:new(modname, active)
	local infofile = assert(io.open())

	local m = {}

	setmetatable(m, _mf.mods.Instance_mt)

	m.modname = modname

	-- We temporarily store the name of the mod in the modlist to avoid an endless loop of loading.
	_mf.modlist[modname] = m.modname

	m.active = active or true

	-- 1.0 Handle the table of information here (Currently just .ini line reading)
	self:handleInfo(_mf.modhandle.loadInfo(self.modname))()

	-- 1.1 Check if we have a load order - otherwise load dependecies.
	if not table.getn(_mf.loadorder) then
		if table.getn(self.dependecies) then
			for i, k in ipairs(self.dependecies) do
				_mf.mods.load(k)
			end
		end
	end

	-- We will store the executed chunk and it's returned table in this function.
	m.mod = _mf.modhandle.loadmod(modname)

	-- Make sure that a chunk was actually loaded. If so, execute it.
	if m.mod then
		m.mod = m.mod()
	end

	-- Make sure that the mod is an actual table returned from executing the chunk
	if m.mod ~= nil and type(m.mod) == "table" then
		_mf.modlist[modname] = m

		if m.mod.load then
			m.mod:load()
		end

		return m
	else
		-- We obvious didn't load anything so we might as well just clear the table entry.
		_mf.modlist[modname] = nil
	end
end

function _mf.mods.Instance:handleInfo(information)
	-- We take in the information and simply pass it on to our variables.
	self.author 		= information.author or "Unknown"
	self.version 		= information.version or ""
	self.gameversion	= information.gameversion or "124i"
	self.dependecies	= information.dependecies or {}
	self.description	= information.description or ""
	self.creationdate	= information.creationdate or ""
end

function _mf.mods.Instance:reloadMod()
	if self.mod.unload then
		self.mod:unload()
	end

	m.mod = _mf.modhandle.loadmod(self.modname)()
end

function _mf.mods.Instance:reloadInfo()
	-- Currently requires executing since it's a lua chunk of a table
	self:handleInfo(_mf.modhandle.loadInfo(self.modname))()
end

function _mf.mods.Instance:unload()
	if self.mod.unload then
		self.mod:unload()
	end

	_mf.modlist[self.modname] = nil
end

-- Loads a mod as well as the mods info file (modname is the name of the mod inside of the mods folder)
function _mf.mods.load(modname, active)
	if not _mf.modlist[modname] then
		return _mf.mods.Instance(modname, active)
	end
end

-- Unloads a mod as well as the information for a mod from the modlist table
function _mf.mods.unload(modname)
	_mf.modlist[modname] = nil
end

-- Reads and executes an already added mods lua script
function _mf.mods.reloadMod(modname)
	if _mf.modlist[modname] then
		_mf.modlist[modname]:reloadMod()
	end
end

function _mf.mods.reloadInfo(modname)
	if _mf.modlist[modname] then
		_mf.modlist[modname]:reloadInfo()
	end
end

-- Returns true if the mod with the name of modname was found in _mf.modlist .
-- Warning: The list may simply contain the info chunk but not the actual mod itself. Use getActive for more reliable mod checking.
function _mf.mods.exists(modname)
	if _mf.modlist[modname] then
		return true
	else
		return false
	end
end

-- Returns the mod table of a certain mod. This table contains the information about the mod as well as the mod itself.
function _mf.mods.getMod(modname)
	if _mf.modlist[modname] then
		return _mf.modlist[modname].mod
	end
end

-- Returns true if a mod's active variable is set to true.
function _mf.mods.getActive(modname)
	if _mf.modlist[modname] then
		return _mf.modlist[modname].active
	end
end

-- The entry point for the mod system
function _mf.mods.init()
	--[[
		This is the only part that needs to be done for now. We need a function that will go through each file in the mods folder.
		Currently this is a little tricky since we would probably use the io library for the loading of files and the construction of a file tree.
		However, the io library works with absolute file paths which we can simply not use because there has not been a way to get the current working directory
		of a lua file. Of course this is possible to be done and I am missing the components and the time to currently do so.

		The above traversing over every single file will however be done after the loadorder file has been read and loaded.
		This means that mods inside of the loadorder have a higher priority than mods that are not bound to the loadorder.
	--]]
end

-- We can call this function if we want to restart the system from the init function.
function _mf.mods.restart()
	_mf.modlist = {}

	_mf.mods.init()
end