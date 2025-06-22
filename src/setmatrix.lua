local _ = require('kupocast/libs/luadash')
local memo = require('kupocast/libs/memoize')
local equipment = require('kupocast/src/equipment')

local SetMatrix = {}
SetMatrix.__index = SetMatrix

SetMatrix.__pairs = function(t)
  return pairs(t:get())
end

SetMatrix.__newindex = function(t, k, v)
  table.insert(t._sets, k)
  return rawset(t, k, v)
end

function SetMatrix.new(injector, keys)
  local matrix = {}
  matrix._injector = injector
  matrix._keys = keys
  matrix._sets = {}
  matrix.build = memo(_.bind(SetMatrix._build, matrix))
  -- set metatable last to avoid newindex magic
  return setmetatable(matrix, SetMatrix)
end

function SetMatrix:_build(...)
  local keys = _.intersection(self._sets, { ... })
  if _.isEmpty(keys) then
    return self.Default or {}
  end
  local sets = _.map(keys, function(key)
    return self[key]
  end)
  if #sets > 1 then
    return equipment.combine(table.unpack(sets))
  end
  return sets[1]
end

function SetMatrix:destroy()
  self.build = nil
end

function SetMatrix:get()
  if not self.build then
    error('Attempting to build set after destroy')
  end
  local keys = _.map(self._keys, function(key)
    return self._injector:get(key)
  end)
  return self.build(table.unpack(keys))
end

return SetMatrix
