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
  local computed = self.gear.Computed
  local effects = self.gear.Effects

  if not computed and not effects then
    return self.gear
  end

  local set = _.omit(self.gear, { 'Computed', 'Effects' })

  if computed then
    self:_applyComputed(set, computed)
  end

  if effects then
    self:_applyEffects(set, effects)
  end

  return set
end

function GearSet:_applyComputed(set, computed)
  _.forEach(computed, function(factory, slot)
    local gear = self.injector:inject(factory)
    if gear then
      set[slot] = gear
    end
  end)
end

function GearSet:_applyEffects(set, effects)
  _.forEach(effects, function(effect, slot)
    local condition = false

    if type(effect.When) == 'string' then
      condition = self.injector:get(effect.When)
    elseif type(effect.When) == 'function' then
      condition = self.injector:inject(effect.When)
    end

    if condition then
      set[slot] = effect.Name
    end
  end)
end

return GearSet
