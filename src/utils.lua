local _ = require('kupocast/libs/luadash')

local utils = {}

function utils.combine(...)
  local gearset = {}
  local computed = {}
  local effects = {}

  -- sets on the right hand side override things on the left
  _.forEach({ ... }, function(set)
    -- static gear on the right overrides computed gear on the left
    _.forEach(set, function(gear, slot)
      computed[slot] = nil
      gearset[slot] = gear
    end)

    -- we can nil out static gear because computed would just override it
    _.forEach(set.Computed, function(factory, slot)
      gearset[slot] = nil
      computed[slot] = factory
    end)

    -- effects are conditionally equipped, so its up to the user to specify when
    -- these should and shouldn't be active
    if set.Effects then
      _.assign(effects, set.Effects)
    end
  end)

  gearset.Computed = (not _.isEmpty(computed) and computed) or nil
  gearset.Effects = (not _.isEmpty(effects) and effects) or nil

  return gearset
end

function utils.disabled(disabled, slots)
  if type(slots) ~= 'table' then
    slots = { slots }
  end

  _.forEach(slots, function(slot)
    local index = gData.GetEquipSlot(slot)

    if index ~= 0 then
      gState.Disabled[index] = disabled
    end
  end)
end

function utils.exec(template, ...)
  local cmd = string.replace(template, ...)
  AshitaCore:GetChatManager():QueueCommand(-1, cmd)
end

return utils
