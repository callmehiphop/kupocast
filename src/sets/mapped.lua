local _ = require('kupocast/libs/luadash')

local MappedSet = {}

MappedSet.__index = MappedSet

MappedSet.__pairs = function(t)
  return next, t:get(), nil
end

function MappedSet.new(injector, key)
  local set = {}
  set._injector = injector
  set._key = key
  return setmetatable(set, MappedSet)
end

function MappedSet:get()
  local state = self._injector:get(self._key)
  if _.isBoolean(state) then
    state = state and _.upperFirst(self._key)
  end
  return self[state] or self.Default or {}
end

return MappedSet
