local GearSet = require('kupocast/src/gearset')

local SetTable = {}
SetTable.__index = SetTable

SetTable.__newindex = function(t, k, v)
  return rawset(t, k, t:create(v))
end

function SetTable:new(store)
  local settable = {}
  settable._store = store
  settable.__index = self
  return setmetatable(settable, self)
end

function SetTable:create(set)
  return GearSet:new(self._store, set)
end

return SetTable
