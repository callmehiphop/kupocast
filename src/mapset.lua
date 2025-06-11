local MapSet = {}

MapSet.__index = function(t, k)
  local set = t:get()
  if set[k] then
    return set[k]
  end
  return rawget(t, k)
end

MapSet.__pairs = function(t)
  return pairs(t:get())
end

function MapSet:new(store, key)
  local map = setmetatable(self, MapSet)
  map.store = store
  map.key = key
  return map
end

function MapSet:get()
  local setKey = self.store[self.key]
  return self[setKey] or self.Default or {}
end

return MapSet
