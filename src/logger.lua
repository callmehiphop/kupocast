local chat = require('chat')
local _ = require('kupocast/libs/luadash')
local json = require('kupocast/libs/json')

local Colors = {
  INFO = 106,
  ERROR = 68,
  FATAL = 76,
  SUCCESS = 2,
  WARN = 104,
}

local function stringify(message)
  if _.isTable(message) then
    return json.stringify(message)
  end
  return tostring(message)
end

local function log(color, ...)
  local messages = _.map({...}, stringify)
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
