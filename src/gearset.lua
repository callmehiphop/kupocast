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
  set.inject = _.bind(injector.inject, injector)
  set.gear = gear
  set.__index = self
  return setmetatable(set, self)
end

function GearSet:build()
  local set = _.omit(self.gear, { 'Computed', 'Effects' })

  _.forEach(self.gear.Computed, function(factory, slot)
    local gear = self.inject(factory)
    if gear then
      set[slot] = gear
    end
  end)

  _.forEach(self.gear.Effects, function(effect, slot)
    if self.inject(effect.When) then
      set[slot] = effect.Name
    end
  end)

  return set
end

return GearSet
