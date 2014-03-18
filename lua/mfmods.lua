
-- Mods files: info file (.ini) / mod file (.lua)
-- Table containing all the functions needed to access and create mods
_mf.mods = {}

-- The path to the modfolder
_mf.mods.modDir = string.sub(debug.getinfo(1,'S').source, 2, -11):gsub("\\","/") .."mods/"

-- A table containing tables filled with the mod and about information.
_mf.modlist = {}

_mf.mods.Instance = {}
_mf.mods.Instance_mt = { __index = _mf.mods.Instance }

-- We will store a sequence of strings in this table. Their position indicates their load priority.
_mf.mods.loadorder = {}

function _mf.mods.Instance:new(modname, active)
	local m = {}

	setmetatable(m, _mf.mods.Instance_mt)

	m.modname = modname

	-- We temporarily store the name of the mod in the modlist to avoid an endless loop of loading.
	_mf.modlist[modname] = m.modname

	m.active 	= active or true
	m.errors 	= {} -- This will be used to display errors and information in the mod menu later on.
	m.notices 	= {} -- Also allows overflow handling possibly disabling certain parts of a mod if it creates to many errors.

	--[[
		Currently when there is an error the game is notified by simply priting it on the screen. We will change this 
		to show up in the respective mod's submenu in the modmanager later on. This way, users will be able to see what's broken
		and notify the developer of the mod. Also, this will allow us to keep all the information concerning a certain mod in 
		a single place removing cluttering information during gameplay that may come as a consequenz of some mods error.
	--]]

	-- >>>>>>>>><<<<<<<<<
	-- >> INFO LOADING <<
	-- >>>>>>>>><<<<<<<<<

	-- LEGACY LOADING

	-- 1.0 Handle the table of information here.
	local s, e = pcall(
		function ()
			m:handleInfo(loadfile(_mf.mods.modDir ..modname ..".ini")())
		end
	)

	if not s then
		print("[METALFRAME MOD LOADER][" ..string.upper(modname) .."]" ..e)

		return
	end

	print(m.author)

	-- 1.1 Check if we have a load order - otherwise load dependecies.
	if #_mf.mods.loadorder then
		if self.dependecies and #self.dependecies ~= 0 then
			for i, k in ipairs(self.dependecies) do
				_mf.mods.load(k)
			end
		end
	end

	-- >>>>>>>>><<<<<<<<
	-- >> MOD LOADING <<
	-- >>>>>>>>><<<<<<<<

	local s, e = pcall(function () m.mod = loadfile(_mf.mods.modDir ..modname ..".lua") end)

	if not s then
		print("[METALFRAME MOD LOADER][" ..string.upper(modname) .."]" ..e)
	else
		local s2, e2 = pcall(function () m.mod = m.mod() end)

		if not s2 then
			print("[METALFRAME MOD LOADER][" ..string.upper(modname) .."]" ..e2)
		end
	end

	-- Make sure that the mod is an actual table returned from executing the chunk
	if m.mod ~= nil and type(m.mod) == "table" then
		_mf.modlist[modname] = m

		if m.mod.load then
			m.mod.load()
		end

		return m
	else
		-- We obvious didn't load anything so we might as well just clear the table entry.
		_mf.modlist[modname] = nil
	end
end

function _mf.mods.Instance:handleInfo(t)
	-- We take in the information and simply pass it on to our variables.
	self.author 		= t.author or "Unknown"
	self.version 		= t.version or ""
	self.gameversion	= t.gameversion or "invalid"
	self.dependecies	= t.dependecies or {}
	self.description	= t.description or ""
	self.creationdate	= t.creationdate or ""
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
		return _mf.mods.Instance:new(modname, active)
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

function _mf.mods.setActive(modname, value)
	if _mf.modlist[modname] then
		if typeof(value) == "boolean" then
			_mf.modlist[modname].active = value
		end
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
	-- Loading of mods if we don't have a loadorder.ini file
	local infofiles = daisy.getFolderContents("lua/mods", "*.ini")

	-- First do a quick sweep checking if the loadorder file exists.
	for i, f in pairs(infofiles) do
		if f == "loadorder.ini" then
			-- Handle the loadorder by inserting entries into the loadorder table
		end
	end

	if #_mf.mods.loadorder == 0 then
		-- If the loadorder is empty we just execute each mod after the other
		for i, f in pairs(infofiles) do
			_mf.mods.load(string.sub(f, 1, -5), true)
		end
	else
		-- Otherwise we will just go over each indexed entry in the loadorder table
		for i, f in pairs(_mf.mods.loadorder) do
			_mf.mods.load(string.sub(f, 1, -5), true)
		end
	end
end

-- We can call this function if we want to restart the system from the init function.
function _mf.mods.restart()
	_mf.modlist = {}

	_mf.mods.init()
end