------------
-- A tiny EventEmitter class for Lua
-- @classmod EventEmitter
-- @author callmehiphop
-- @license MIT
---
local EventEmitter = {}
EventEmitter.__index = EventEmitter

function EventEmitter.new()
  local ee = setmetatable({}, EventEmitter)
  ee._events = {}
  return ee
end

function EventEmitter:emit(event, ...)
  local listeners = self._events[event]
  if not listeners then
    return false
  end
  for _, listener in ipairs(listeners) do
    listener.callback(...)
  end
  return true
end

function EventEmitter:_on(event, prepend, listener)
  local listeners = self._events[event] or {}
  local index = (prepend and 1) or #listeners + 1
  table.insert(listeners, index, listener)
  self._events[event] = listeners
  return self
end

function EventEmitter:_once(event, prepend, callback)
  local function proxy(...)
    self:off(event, callback)
    callback(...)
  end
  return self:_on(event, prepend, {
    callback = proxy,
    original = callback,
  })
end

function EventEmitter:on(event, callback)
  return self:_on(event, false, { callback = callback })
end

function EventEmitter:pon(event, callback)
  return self:_on(event, true, { callback = callback })
end

function EventEmitter:once(event, callback)
  return self:_once(event, false, callback)
end

function EventEmitter:ponce(event, callback)
  return self:_once(event, true, callback)
end

function EventEmitter:off(event, callback)
  local listeners = self._events[event] or {}
  local filtered = {}
  for _, listener in ipairs(listeners) do
    local func = listener.original or listener.callback
    if func ~= callback then
      table.insert(filtered, listener)
    end
  end
  self._events[event] = (#filtered and filtered) or nil
  return self
end

function EventEmitter:removeAllListeners()
  self._events = {}
  return self
end

return EventEmitter
