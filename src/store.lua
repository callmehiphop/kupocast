local _ = require('kupocast/libs/luadash')
local EventEmitter = require('kupocast/libs/events')

local Store = {}

Store.__index = function(t, k)
  if t.state[k] ~= nil then
    return t.state[k]
  elseif _.isFunction(t.getters[k]) then
    return t.getters[k](t)
  elseif _.isFunction(t.actions[k]) then
    return t.actions[k]
  end
  return rawget(t, k) or Store[k]
end

Store.__newindex = function(t, k, v)
  if t.state[k] ~= v then
    t.state[k] = v
    t._ee:emit('statechange', k, v)
    t._ee:emit('statechange:' .. tostring(k), v)
  end
end

function Store.new(config)
  config = config or {}

  local store = {}
  store._ee = EventEmitter.new()
  store.state = _.assign({}, config.state)
  store.getters = _.assign({}, config.getters)
  store.actions = _.assign({}, config.actions)
  setmetatable(store, Store)

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

function Store:destroy()
  self._ee:removeAllListeners()
end

function Store:subscribe(callback)
  self._ee:on('statechange', callback)
end

function Store:watch(key, callback)
  self._ee:on('statechange:' .. tostring(key), callback)
end

return Store
