local _ = require('kupocast/libs/luadash')
local MapSet = require('kupocast/src/mapset')

local Store = {}

setmetadata(Store, {
  __call = function(config)
    return Store:new(config)
  end,
})

Store.__index = function(t, k)
  if t.state[k] ~= nil then
    return t.state[k]
  elseif type(t.getters[k]) == 'function' then
    return t.getters[k](t)
  elseif type(t.actions[k]) == 'function' then
    return t.actions[k]
  end
  return rawget(t, k)
end

Store.__newindex = function(t, k, v)
  t.state[k] = v
end

function Store:new(config)
  config = config or {}

  local store = self
  store.state = _.assign({}, config.state or {})
  store.getters = _.assign({}, config.getters or {})
  store.actions = _.assign({}, config.actions or {})
  setmetadata(store, Store)

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

return Store
