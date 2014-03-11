
-- Table containing the eventsystem functions
_mf.event = {}

-- We store our events in this table
_mf.events = {}

-- We make the hooks table local since we don't want the user to have direct access to them.
-- Each mod is added to one of these tables if it requires a hook callback.

_mf.event.Instance = {}
_mf.event.Instance_mt = { __index = _mf.event.Instance }

function _mf.event.Instance:new(eventname)
	local e = {}
	setmetatable(e, _mf.event.Instance_mt)
	e.callbacks = {
		[1] = {}
		[2] = {}
		[3] = {}
		[4] = {}
		[5] = {}
	}
	e.name = eventname
	e.active = true
	_mf.events[eventname] = e
	return e
end

function _mf.event.Instance:pop()
	self = nil
end

function _mf.event.Instance:fire()
	if not self.active return nil
	for i, p in ipairs(self.callbackPriorities) do
		for k, c in ipairs(p) do
			if c then
				c.fire()
			else
				table.remove(p, k)
			end
		end
	end
end

function _mf.event.Instance:registerCallback(callbackname, callback, priority)
	priority = priority or 3
	if self.callbackPriorities[priority] then
		local callbackInstance = self.callbacks[callbackname]
		if not callbackInstance then
			self.callbacks[callbackname] = {}
			callbackInstance = self.callbacks[callbackname]
			callbackInstance.active = true
		end
		callbackInstance.fire = callback
		callbackInstance.priority = priority
		table.insert(self.callbackPriorities[priority], callbackInstance)
		return callbackInstance
	end
end

function _mf.event.registerEvent(eventname)
	return _mf.event.Instance:new(eventname)
end

function _mf.event.popEvent(eventname)
	if _mf.events[eventname] then
		_mf.events[eventname]:pop()
	end
end

function _mf.event.popCallback(eventname, callbackname)
	if _mf.events[eventname] then
		_mf.events[eventname]:popCallback(callbackname)
	end
end

function _mf.event.fire(eventname)
	if _mf.events[eventname] then
		_mf.events[eventname]:fire()
	end
end