local _ = require('kupocast/libs/luadash')
local memo = require('kupocast/libs/memoize')
local equip = require('kupocast/src/equipment')

local LayeredSet = {}

LayeredSet.__index = LayeredSet

-- TODO: maybe improve this in case of duplicate keys
-- and/or deleting a set. Not sure the use case.. but ya know
LayeredSet.__newindex = function(t, k, v)
  table.insert(t._layers, k)
  return rawset(t, k, v)
end

LayeredSet.__pairs = function(t)
  return next, t:get(), nil
end

function LayeredSet.new(injector, keys)
  local set = {}
  set._injector = injector
  set._keys = keys
  set._layers = {}
  set._getOrBuild = memo(_.bind(LayeredSet.build, set))
  return setmetatable(set, LayeredSet)
end

function LayeredSet:build(...)
  local layers = _.intersection(self._layers, { ... })
  if _.isEmpty(layers) then
    return self.Default or {}
  elseif #layers == 1 then
    return self[layers[1]]
  end
  local sets = _.map(layers, function(layer)
    return self[layer]
  end)
  return equip.combine(table.unpack(sets))
end

function LayeredSet:get()
  local state = _.map(self._keys, function(key)
    return self._injector:get(key)
  end)
  return self._getOrBuild(table.unpack(state))
end

return LayeredSet
