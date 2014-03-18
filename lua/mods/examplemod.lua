local mod = {}

--[[
	We define our variables for the mod up here. These could be local variables but since we want to keep things clean we
	add them to the mod table. This also means that other mods will be able to get a reference to this mod allowing them to
	access this mods variables and functions.
--]]

mod.keylog = false

-- We create some event driven functions here.
function mod.update(dt) -- Called each frame.

end

function mod.lateupdate(dt) -- Should be called at the end of each frame but that event has not been added yet.

end

function mod.render()

end

function mod.keypress(key) -- Called when a key is pressed by the user
	if not mod.keylog then
		if key == 49 then
			print("[KEYLOGGER] Activated the keylogger - Press 'DELETE' to clear the console and 'INSERT' to print all keys")

			mod.keylog = true
		end
	else
		if key == 46 then
			daisy.clearPrint()

			return

		elseif key == 45 then
			print("[COMMANDS] 1: Activate keylogging // 2: Disable keylogging // 3: Remove keycallbacks and disable the entire mod")

			return

		elseif key == 50 then
			print("[KEYLOGGER] Disabled the keylogger - Press '1' to enable it again")

			mod.keylog = false
			
			return

		elseif key == 51 then
			print("[KEYLOGGER] Removed key callbacks - The mod is now semi disabled.")

			_mf.events.getEvent("keypress"):popCallback("examplemod/keypress")

			mod.active = false -- This is not working yet since the events system still calls callbacks even if the mod is inactive

			daisy.clearPrint()
			
			return

		end

		print("[KEYLOGGER] Pressed: " ..key)
	end
end

-- Called when the mod is loaded
function mod.load()
	_mf.events.getEvent("update"):registerCallback("examplemod/update", mod.update, 1)
	_mf.events.getEvent("update"):registerCallback("examplemod/lateupdate", mod.lateupdate, 3)
	_mf.events.getEvent("render"):registerCallback("examplemod/render", mod.render, 1)
	_mf.events.getEvent("keypress"):registerCallback("examplemod/keypress", mod.keypress, 1)
end

-- Called when the mod is unloaded or reloaded
function mod:unload()
	_mf.events.getEvent("update"):popCallback("examplemod/update")
	_mf.events.getEvent("update"):popCallback("examplemod/lateupdate")
	_mf.events.getEvent("render"):popCallback("examplemod/render")
end

return mod