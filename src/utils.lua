local _ = require('kupocast/libs/luadash')

local utils = {}

function utils.exec(template, ...)
  local cmd = string.format(template, ...)
  AshitaCore:GetChatManager():QueueCommand(-1, cmd)
end

function utils.switch(value, cases)
  local case = cases[value] or cases.default or _.noop
  return case()
end

return utils
