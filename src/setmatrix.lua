local _ = require('kupocast/libs/luadash')
local memo = require('kupocast/libs/memoize')
local equipment = require('kupocast/src/equipment')

local SetMatrix = {}

SetMatrix.__index = SetMatrix

SetMatrix.__pairs = function(t)
  return pairs(t:get())
end

function SetMatrix:new(injector, keys)
  local matrix = setmetatable({}, self)
  matrix._injector = injector
  matrix._keys = keys
  matrix._cache = {}
  matrix._build = memo(_.bind(matrix.build, matrix), matrix._cache)
  return matrix
end

function SetMatrix:build(...)
  local sets = _.map({ ... }, function(key)
    return self[key] or self.Default or {}
  end)
  if #sets > 1 then
    return equipment.combine(table.unpack(sets))
  end
  return sets[1]
end

function SetMatrix:get()
  local keys = _.map(self._keys, function(key)
    return self._injector:get(key)
  end)
  return self._build(table.unpack(keys))
end

return SetMatrix
