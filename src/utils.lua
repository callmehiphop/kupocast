local _ = require('kupocast/libs/luadash')

local utils = {}

function utils.combine(...)
  return _.assign({}, ...)
end

function utils.disabled(slots, disabled)
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
  if gear then
    return gFunc.Equip(set, gear)
  end

  if type(set) == 'string' then
    set = gProfile.Sets[set]
  end

  if not set then
    error('Unable to equip ' .. type(set) .. ' value')
  end

  gFunc.EquipSet(set)

  -- we could inject here with gProfile.store ?
  _.forEach(set.Computed, function(factory, slot)
    gFunc.Equip(slot, factory())
  end)

  _.forEach(set.Effects, function(effect, slot)
    if effect.When() then
      gFunc.Equip(slot, effect.Name)
    end
  end)
end

function utils.exec(template, ...)
  local cmd = string.replace(template, ...)
  AshitaCore:GetChatManager():QueueCommand(-1, cmd)
end

function utils.getParams(func)
  local info = debug.getinfo(func, 'u')
  local params = {}

  for i = 1, info.nparams do
    table.insert(params, debug.getlocal(func, i))
  end

  return params
end

function utils.lockStyle(set)
  if type(set) == 'number' then
    return utils.exec('/lockstyleset %d', set)
  end

  if type(set) == 'string' then
    set = gProfile.Sets[set]
  end

  if type(set) ~= 'table' then
    error('Unable to lock style with ' .. type(set))
  end

  gFunc.LockStyle(set)
end

return utils
