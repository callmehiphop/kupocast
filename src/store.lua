local _ = require('kupocast/libs/luadash')
local EventEmitter = require('kupocast/libs/events')
local utils = require('kupocast/src/utils')

local Store = {}

-- Store.__index = Store
setmetatable(Store, { __index = EventEmitter })

-- YUCK: gotta do better
Store.__index = function(t, k)
  local state = rawget(t, 'state')
  if state[k] then
    return state[k]
  end
  local getters = rawget(t, 'getters')
  if getters[k] then
    return getters[k](t)
  end
  local actions = rawget(t, 'actions')
  if actions[k] then
    return actions[k]
  end
  return rawget(t, k) or Store[k] or EventEmitter[k]
end

Store.__newindex = function(t, k, v)
  t.state[k] = v
  t:emit('statechange', k, v)
  t:emit('statechange:' .. tostring(k), v)
end

function Store:new(config)
  config = config or {}

  local store = EventEmitter:new()
  store.state = _.assign({}, config.state)
  store.getters = _.assign({}, config.getters)
  store.actions = _.assign({}, config.actions)
  setmetatable(store, self)

  _.forEach(config.cycles, function(values, key)
    store:createCycle(key, values)
  end)

  _.forEach(config.toggles, function(value, key)
    store:createToggle(key, value)
  end)

  return store
end

function Store:createCycle(key, values)
  local i = 1
  self[key] = values[i]
  self.actions['cycle' .. _.upperFirst(key)] = function()
    i = (i % #values) + 1
    self[key] = values[i]
    return values[i]
  end
end

function Store:createToggle(key, value)
  self.actions['toggle' .. _.upperFirst(key)] = function()
    value = not value
    self[key] = value
    return value
  end
end

function Store:subscribe(subscriber)
  self:on('statechange', subscriber)
  return _.bind(self.off, self, 'statechange', subscriber)
end

function Store:watch(key, callback)
  local event = 'statechange:' .. tostring(key)
  local debounced = utils.debounce(callback, 250)
  self:on(event, debounced)
  return _.bind(self.off, self, event, debounced)
end

return Store
