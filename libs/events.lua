local EventEmitter = {}
EventEmitter.__index = EventEmitter

function EventEmitter:new()
  local ee = setmetatable(self, EventEmitter)
  ee._events = {}
  return ee
end

function EventEmitter:emit(event, ...)
  local callbacks = self._events[event] or {}
  for _, func in ipairs(callbacks) do
    func(...)
  end
end

function EventEmitter:on(event, callback)
  local callbacks = self._events[event] or {}
  table.insert(callbacks, callback)
  self._events[event] = callbacks
end

function EventEmitter:once(event, callback)
  local function proxy(...)
    self:off(event, proxy)
    callback(...)
  end
  return self:on(event, proxy)
end

-- TODO: support manual off() when bound with once()
function EventEmitter:off(event, callback)
  local callbacks = self._events[event] or {}
  local filtered = {}
  for _, func in ipairs(callbacks) do
    if func ~= callback then
      table.insert(filtered, func)
    end
  end
  self._events[event] = (#filtered and filtered) or nil
end

function EventEmitter:removeAllListeners()
  self._events = {}
end

return EventEmitter
