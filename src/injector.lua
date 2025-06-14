local _ = require('kupocast/libs/luadash')
local memo = require('kupocast/libs/memoize')
local log = require('kupocast/src/logger')

local Injector = {}
Injector.__index = Injector

function Injector.getDeps(func)
  local info = debug.getinfo(func, 'u')
  local params = {}

  for i = 1, info.nparams do
    table.insert(params, debug.getlocal(func, i))
  end

  return params
end

function Injector:new(store)
  local injector = setmetatable(self, Injector)
  injector.store = store
  injector.cache = {}
  injector.getDeps = memo(Injector.getDeps, injector.cache)
  return injector
end

function Injector:clearCache()
  self.cache.children = nil
  self.cache.results = nil
end

function Injector:inject(func)
  local deps = self.getDeps(func)
  local values = _.map(deps, function(dep)
    return self.store[dep]
  end)
  local result, err = pcall(func, table.unpack(values))
  if err then
    log.error('Dependency inject failed. Reason:\n' .. err)
  end
  return result
end

function Injector:destroy()
  self:clearCache()
end

return Injector
