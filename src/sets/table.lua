local LayeredSet = require('kupocast/src/sets/layered')
local MappedSet = require('kupocast/src/sets/mapped')

local SetTable = {}

SetTable.__index = SetTable

function SetTable.new(injector)
  local sets = {}
  sets._injector = injector
  return setmetatable(sets, SetTable)
end

function SetTable:layer(...)
  return LayeredSet.new(self._injector, { ... })
end

function SetTable:select(key)
  return MappedSet.new(self._injector, key)
end

return SetTable
