local SetTable = require('kupocast/src/settable')

local MapSet = {}

MapSet.__index = MapSet
MapSet.__newindex = SetTable.__newindex
setmetatable(MapSet, { __index = SetTable })

MapSet.__pairs = function(t)
  return pairs(t:get())
end

function MapSet:new(injector, key)
  local map = SetTable:new(injector)
  map._key = key
  return setmetatable(map, self)
end

function MapSet:get()
  local key = self._injector:get(self._key) or 'Default'
  return self[key] or {}
end

return MapSet
