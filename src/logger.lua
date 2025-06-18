local chat = require('chat')
local _ = require('kupocast/libs/luadash')
local dump = require('kupocast/libs/dump')

local Colors = {
  INFO = 106,
  ERROR = 68,
  FATAL = 76,
  SUCCESS = 2,
  WARN = 104,
}

local function log(color, ...)
  local messages = _.map({...}, function(message)
    return dump(message)
  end)
  local output = _.join(messages, ' ')
  print(chat.header('kupocast') .. chat.color1(color, output))
end

return {
  info = _.bind(log, Colors.INFO),
  error = _.bind(log, Colors.ERROR),
  fatal = _.bind(log, Colors.FATAL),
  success = _.bind(log, Colors.SUCCESS),
  warn = _.bind(log, Colors.WARN),
}
