local mod = {}

-- We are going to create an update function which we will hook into the events system.
function mod:update(dt)

end

function mod:lateupdate(dt)

end

-- Called when the mod is loaded
function mod:load()
	_mf.events.getEvent("update"):registerCallback("examplemod/update", self:update, 1)
	_mf.events.getEvent("update"):registerCallback("examplemod/lateupdate", self:lateupdate, 3)
end

-- Called when the mod is unloaded or reloaded
function mod:unload()
	_mf.events.getEvent("update"):popCallback("examplemod/update")
	_mf.events.getEvent("update"):popCallback("examplemod/lateupdate")
end

return mod