local _ = require('kupocast/libs/luadash')
local log = require('kupocast/src/logger')

local equipment = {}

-- Build/Evals a set table to LAC format
function equipment.build(set)
  local built = {}
  equipment.forEach(set, function(gear, slot)
    built[slot] = gear
  end)
  return built
end

-- Coalesces a list of gear functions/options
function equipment.coalesce(options)
  local resolved = nil
  _.forEach(options, function(gear)
    if _.isFunction(gear) then
      gear = gProfile.injector:inject(gear)
    end
    resolved = gear
    return not resolved
  end)
  return resolved
end

-- Combines gearsets together
function equipment.combine(...)
  local combined = {}
  _.forEach({ ... }, function(set)
    _.forEach(set, function(gear, slot)
      if combined[slot] and _.isFunction(gear) then
        gear = _.unshift(_.castArray(combined[slot]), gear)
      end
      combined[slot] = gear
    end)
  end)
  return combined
end

-- Sets disabled state of specified slots
function equipment.disabled(disabled, slots)
  if not _.isTable(slots) then
    slots = { slots }
  end
  _.forEach(slots, function(slot)
    local index = gData.GetEquipSlot(slot)
    if index ~= 0 then
      gState.Disabled[index] = disabled
    end
  end)
end

-- Generic function for building and equipping a set
function equipment.equipWith(Equip, setOrSlot, maybeGear)
  local set = setOrSlot

  if maybeGear then
    set = { [setOrSlot] = maybeGear }
  end

  equipment.forEach(set, function(gear, slot)
    Equip(slot, gear)
  end)
end

-- foreach helper that calls iteratee with built slot
function equipment.forEach(set, iteratee)
  if _.isString(set) then
    set = gProfile.Sets[set]
  end
  if not set then
    return log.error('Invalid set provided')
  end

  _.forEach(set, function(gear, slot)
    if _.isFunction(gear) then
      gear = gProfile.injector:inject(gear)
    elseif _.isArrayLike(gear) then
      gear = equipment.coalesce(gear)
    end
    iteratee(gear, slot)
  end)
end

return equipment
