local _ = require('kupocast/libs/luadash')

local utils = {}

function utils.debounce(func, delay)
  local state = nil
  delay = (delay or 0) / 1000

  return function(...)
    local args = { ... }

    if state then
      state.cancelled = true
    end

    state = { cancelled = false }
    local _state = state

    ashita.tasks.once(delay, function()
      if not _state.cancelled then
        func(table.unpack(args))
      end
    end)
  end
end

function utils.exec(template, ...)
  local cmd = string.format(template, ...)
  AshitaCore:GetChatManager():QueueCommand(-1, cmd)
end

function utils.switch(value, cases)
  local case = cases[value] or cases.default or _.noop
  return case()
end

return utils
