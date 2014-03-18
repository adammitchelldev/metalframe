
-- Table containing the event framework functions
_mf.events = {}

-- We store our events in this table
_mf.eventlist = {}

-- We make the hooks table local since we don't want the user to have direct access to them.
-- Each mod is added to one of these tables if it requires a hook callback.
_mf.events.Instance = {}
_mf.events.Instance_mt = { __index = _mf.events.Instance }

function _mf.events.Instance:new(eventname)
	local e = {}

	setmetatable(e, _mf.events.Instance_mt)

	e.callbackPriorities = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {}
	}

	e.name = eventname
	e.active = true

	_mf.eventlist[eventname] = e

	return e
end

function _mf.events.Instance:pop()
	self = nil
end

function _mf.events.Instance:popCallback(callbackname, priority)
	if priority and type(priority) == "number" then
		if self.callbackPriorities[priority] then
			if self.callbackPriorities[priority][callbackname] then
				self.callbackPriorities[priority][callbackname] = nil
			end
		end
	end

	for i, p in ipairs(self.callbackPriorities) do
		if p[callbackname] then
			p[callbackname] = nil
		end
	end
end

function _mf.events.Instance:fire(...)
	if not self.active then return nil end

	for i, p in ipairs(self.callbackPriorities) do
		for k, c in pairs(p) do
			if c then
				c.fire(...)
			else
				table.remove(p, k)
			end
		end
	end
end

function _mf.events.Instance:registerCallback(callbackname, callback, priority)
	priority = priority or 3

	if self.callbackPriorities[priority] then
		local callbackInstance = self.callbackPriorities[priority][callbackname] or {active = true}

		callbackInstance.name = callbackname
		callbackInstance.fire = callback
		callbackInstance.priority = priority

		self.callbackPriorities[priority][callbackname] = callbackInstance

		if self.callbackPriorities[priority][callbackname] then
			print("Registered: '" ..callbackname .."' to the event '" ..self.name .."'")
		end

		return callbackInstance
	end
end

function _mf.events.Instance:getCallback(callbackname)
	return self.callbacks[callbackname]
end

function _mf.events.registerEvent(eventname)
	return _mf.events.Instance:new(eventname)
end

function _mf.events.popEvent(eventname)
	if _mf.eventlist[eventname] then
		_mf.eventlist[eventname]:pop()
	end
end

function _mf.events.popCallback(eventname, callbackname)
	if _mf.eventlist[eventname] then
		_mf.eventlist[eventname]:popCallback(callbackname)
	end
end

function _mf.events.fire(eventname, ...)
	if _mf.eventlist[eventname] then
		_mf.eventlist[eventname]:fire(...)
	end
end

function _mf.events.setActive(eventname, state)
	if _mf.eventlist[eventname] then
		_mf.eventlist[eventname].active = state
	end
end

function _mf.events.getActive(eventname)
	if _mf.eventlist[eventname] then
		return _mf.eventlist[eventname].active
	end
end

function _mf.events.getEvent(eventname)
	return _mf.eventlist[eventname]
end

function _mf.events.getCallbackFromEvent(eventname, callbackname, priority)
	if _mf.eventlist[eventname] then
		return _mf.eventlist[eventname]:getCallback(callbackname, priority)
	end
end