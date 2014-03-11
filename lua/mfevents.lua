
-- Table containing the eventsystem functions
_mf.event = {}

-- We store our events in this table
_mf.events = {}

-- We make the hooks table local since we don't want the user to have direct access to them.
-- Each mod is added to one of these tables if it requires a hook callback.

function _mf.events.registerEvent(eventname)
	if not _mf.events[eventname] then
		local e = {}

		event.callbacks = {}

		_mf.events[eventname] = e
	end
end

function _mf.events.popEvent(eventname)
	if not _mf.events[eventname] then
		_mf.events[eventname] = nil
	end
end

function _mf.events.registerCallback(eventname, callback)
	if _mf.events[eventname] then

		-- Better to do this with table.insert
		if not _mf.events[eventname].callbacks[callback] then
			_mf.events[eventname].callbacks[callback] = callback
		end
	end
end

function _mf.events.popCallback(eventname, callback)
	if _mf.events[eventname] then
		if not _mf.events[eventname].callbacks[callback] then
			_mf.events[eventname].callbacks[callback] = nil
		end
	end
end