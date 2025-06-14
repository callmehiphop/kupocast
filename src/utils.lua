local _ = require('kupocast/libs/luadash')

local utils = {}

function utils.combine(...)
  return _.assign({}, ...)
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

function utils.equip(set, gear)
  local profile = gProfile
  local store = profile.store

  if gear then
    set = { [set] = gear }
  end

  if type(set) == 'string' then
    set = profile.Sets[set]
  end

  if not set then
    error('Unable to equip ' .. type(set) .. ' value')
  end

  gFunc.EquipSet(set)

  _.forEach(set.Computed, function(factory, slot)
    gFunc.Equip(slot, store:inject(factory))
  end)

  _.forEach(set.Effects, function(effect, slot)
    if store:inject(effect.When) then
      gFunc.Equip(slot, effect.Name)
    end
  end)
end

function utils.exec(template, ...)
  local cmd = string.replace(template, ...)
  AshitaCore:GetChatManager():QueueCommand(-1, cmd)
end

return utils
