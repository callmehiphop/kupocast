local _ = require('kupocast/libs/luadash')

local utils = {}

function utils.combine(...)
  local set = {}
  local computed = {}
  local effects = {}

  _.forEach({ ... }, function(set)
    -- add new static slots and remove any conflicting computed slots
    _.forEach(set, function(gear, slot)
      computed[slot] = nil
      set[slot] = gear
    end)
    -- new computed slots take precedence over older static slots
    _.forEach(set.Computed, function(factory, slot)
      set[slot] = nil
      computed[slot] = factory
    end)
    -- merge all effects, although maybe we nil these out?
    if set.Effects then
      _.assign(effects, set.Effects)
    end
  end)

  set.Computed = computed
  set.Effects = effects

  return set
end

function utils.disabled(disabled, slots)
  if type(slots) ~= 'table' then
    slots = { slots }
  end

  _.forEach(slots, function(slot)
    local index = gData.GetEquipSlot(slot)

    if slotIndex ~= 0 then
      gState.Disabled[index] = disabled
    end
  end)
end

function utils.exec(template, ...)
  local cmd = string.replace(template, ...)
  AshitaCore:GetChatManager():QueueCommand(-1, cmd)
end

return utils
