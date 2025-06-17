local _ = require('kupocast/libs/luadash')
local log = require('kupocast/src/logger')

local equipment = {}

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

local function equipWith(Equip, setOrSlot, maybeGear)
  local profile = gProfile
  local set = setOrSlot

  if maybeGear then
    set = { [setOrSlot] = maybeGear }
  end
  if _.isString(set) then
    set = profile.Sets[setOrSlot]
  end
  if not set then
    return log.error('Invalid set provided')
  end

  local injector = profile.injector

  _.forEach(set, function(gear, slot)
    if _.isFunction(gear) then
      gear = injector:inject(gear)
    elseif _.isArrayLike(gear) then
      gear = equipment.resolve(gear)
    end
    Equip(slot, gear)
  end)
end

function equipment.equip(setOrSlot, gear)
  return equipWith(gFunc.Equip, setOrSlot, gear)
end

function equipment.interimEquip(setOrSlot, gear)
  return equipWith(gFunc.InterimEquip, setOrSlot, gear)
end

function equipment.resolve(gearList)
  local injector = gProfile.injector
  local resolved = nil

  _.forEach(gearList, function(gear)
    if _.isFunction(gear) then
      gear = injector:inject(gear)
    end
    resolved = gear
    return not resolved
  end)

  return resolved
end

return equipment
