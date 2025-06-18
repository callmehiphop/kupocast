local _ = require('kupocast/libs/luadash')

local Store = {}

setmetatable(Store, {
  __call = function(config)
    return Store:new(config)
  end,
})

Store.__index = function(t, k)
  if not _.isNil(t.state[k]) then
    return t.state[k]
  elseif _.isFunction(t.getters[k]) then
    return t.getters[k](t)
  elseif _.isFunction(t.action[k]) then
    return t.actions[k]
  end
  return rawget(t, k)
end

Store.__newindex = function(t, k, v)
  t.state[k] = v
  t:_onStateChange(k, v)
end

function Store:new(config)
  config = config or {}

  local store = {}
  store.state = _.assign({}, config.state or {})
  store.getters = _.assign({}, config.getters or {})
  store.actions = _.assign({}, config.actions or {})
  store._subscriptions = {}
  setmetatable(store, self)

  _.forEach(config.cycles, function(values, key)
    store:createCycle(key, values)
  end)

  _.forEach(config.toggles, function(value, key)
    store:createToggle(key, value)
  end)

  return store
end

function Store:_onStateChange(key, value)
  _.forEach(self._subscriptions, function(subscriber)
    subscriber(key, value)
  end)
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
  table.insert(self._subscriptions, subscriber)
end

return Store
