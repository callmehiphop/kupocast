local _ = require('kupocast/libs/luadash')
local memo = require('kupocast/libs/memoize')
local log = require('kupocast/src/logger')

local Injector = {}
Injector.__index = Injector

local function getParams(func)
  local info = debug.getinfo(func, 'u')
  local params = {}
  for i = 1, info.nparams do
    table.insert(params, debug.getlocal(func, i))
  end
  return params
end

function Injector.new(store)
  local injector = setmetatable({}, Injector)
  injector.store = store
  injector.cache = {}
  injector.getDeps = memo(getParams, injector.cache)
  return injector
end

function Injector:clearCache()
  self.cache.children = nil
  self.cache.results = nil
end

function Injector:get(key)
  return self.store[key]
end

function Injector:inject(func)
  local deps = self.getDeps(func)
  local values = _.map(deps, _.bind(self.get, self))
  local success, result = pcall(func, table.unpack(values))
  if success then
    return result
  end
  log.error('Dependency injection failed. Reason:', result)
end

function Injector:destroy()
  self:clearCache()
end

return Injector
