local _ = require('kupocast/libs/luadash')
local MapSet = require('kupocast/src/mapset')

local SetTable = {}

SetTable.__index = SetTable

function SetTable:new(injector)
  local sets = {}
  sets._injector = injector
  sets.__index = self
  return setmetatable(sets, self)
end

function SetTable:map(key)
  return MapSet:new(self._injector, key)
end

return SetTable
