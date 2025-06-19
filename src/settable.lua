local _ = require('kupocast/libs/luadash')
local SetMatrix = require('kupocast/src/setmatrix')

local SetTable = {}
SetTable.__index = SetTable

function SetTable.new(injector)
  local sets = setmetatable({}, SetTable)
  sets._injector = injector
  return sets
end

function SetTable:select(key)
  return SetMatrix.new(self._injector, { key })
end

function SetTable:weave(...)
  return SetMatrix.new(self._injector, { ... })
end

return SetTable
