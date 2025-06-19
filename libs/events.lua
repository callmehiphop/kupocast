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

function EventEmitter:on(event, callback)
  local listeners = self._events[event] or {}
  table.insert(listeners, { callback = callback })
  self._events[event] = listeners
  return self
end

function EventEmitter:once(event, callback)
  local listeners = self._events[event] or {}
  local function proxy(...)
    self:off(event, callback)
    callback(...)
  end
  table.insert(listeners, { callback = proxy, original = callback })
  self._events[event] = listeners
  return self
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
