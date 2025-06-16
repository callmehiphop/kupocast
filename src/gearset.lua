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

  if not computed and not effects then
    return self.gear
  end

  local set = _.omit(self.gear, { 'Computed', 'Effects' })

  if computed then
    _.assign(set, computed)
  end
  if effects then
    _.assign(set, effects)
  end

  return set
end

function GearSet:_getComputed()
  local computed = self.gear.Computed
  local built = computed
    and _.map(computed, function(factory)
      return self.injector:inject(factory)
    end)
  return (not _.isEmpty(built) and built) or nil
end

function GearSet:_getEffects()
  local effects = self.gear.Effects
  local built = effects
    and _.map(effects, function(effect)
      if self.injector:inject(effect.When) then
        return effect.Name
      end
    end)
  return (not _.isEmpty(built) and built) or nil
end

return GearSet
