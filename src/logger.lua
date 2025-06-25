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

local logger = {}
local timers = {}

local function serialize(message)
  if _.isTable(message) then
    return dump(message)
  end
  return tostring(message)
end

local function log(color, ...)
  local messages = _.map({ ... }, serialize)
  local message = _.join(messages, ' ')
  print(chat.header('kupocast') .. chat.color1(color, message))
end

logger.info = _.bind(log, Colors.INFO)
logger.error = _.bind(log, Colors.ERROR)
logger.fatal = _.bind(log, Colors.FATAL)
logger.success = _.bind(log, Colors.SUCCESS)
logger.warn = _.bind(log, Colors.WARN)

function logger.time(name)
  name = name or 'default'
  if not _.isNil(timers[name]) then
    return logger.warn("Timer '" .. name .. "' already exists")
  end
  timers[name] = os.time()
end

function logger.timeEnd(name)
  name = name or 'default'
  if _.isNil(timers[name]) then
    return logger.warn("Timer '" .. name .. "' does not exist")
  end
  local elapsed = os.difftime(os.time(), timers[name]) * 1000
  timers[name] = nil
  logger.info(name .. ':', tostring(elapsed), 'ms')
end

return logger
