local _ = require('kupocast/libs/luadash')
local utils = require('kupocast/src/utils')

local Input = {}

Input.__index = Input

function Input.normalize(key, options)
  if _.isFunction(options) then
    local command = '/lac fwd ' .. key
    options = { handler = options, command = command }
  elseif _.isString(options) then
    options = { command = options }
  end
  if not options.command then
    error('A command or event handler must be provided')
  end
  return key, options
end

function Input:new(config)
  local input = setmetatable({}, self)

  input.bindings = {}
  input.commands = {}

  _.forEach(config, function(options, key)
    key, options = Input.normalize(key, options)
    input.bindings[key] = options.command

    if options.handler then
      input.commands[key] = options.handler
    end
  end)

  return input
end

function Input:bindAll()
  _.forEach(self.bindings, function(command, key)
    utils.exec('/bind %s %s', key, command)
  end)
end

function Input:invoke(command, args)
  local handler = self.commands[command]

  if _.isFunction(handler) then
    handler(table.unpack(args))
  end
end

function Input:unbindAll()
  _.forEach(self.bindings, function(command, key)
    utils.exec('/unbind %s', key)
  end)
end

return Input
