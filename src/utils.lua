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

function utils.exec(template, ...)
  local cmd = string.replace(template, ...)
  AshitaCore:GetChatManager():QueueCommand(-1, cmd)
end

return utils
