local _ = require('kupocast/libs/luadash')

local GearSet = {}

GearSet.__index = function(set, key)
  if set.gear[key] then
    return set.gear[key]
  end
  return rawget(set, key)
end

GearSet.__newindex = function(set, slot, gear)
  set.gear[slot] = gear
end

GearSet.__pairs = function(set)
  return next, set:build(), nil
end

function GearSet:new(injector, gear)
  local set = {}
  set.injector = injector
  set.gear = gear
  set.__index = self
  return setmetatable(set, self)
end

function GearSet:build()
  local computed = self:_getComputed()
  local effects = self:_getEffects()
  if _.isEmpty(computed) and _.isEmpty(effects) then
    return self.gear
  end
  return _.assign({}, self.gear, computed, effects)
end

function GearSet:_getComputed()
  return _.map(self.gear.Computed, function(factory)
    return self.injector:inject(factory)
  end)
end

function GearSet:_getEffects()
  return _.map(self.gear.Effects, function(effect)
    if self.injector:inject(effect.When) then
      return effect.Name
    end
  end)
end

return GearSet
