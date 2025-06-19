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
  injector.getDeps = memo(getParams)
  return injector
end

function Injector:destroy()
  self.getDeps = nil
end

function Injector:get(key)
  return self.store[key]
end

function Injector:inject(func)
  if not self.getDeps then
    error('Attempting to inject from after destroy')
  end
  local deps = self.getDeps(func)
  local values = _.map(deps, _.bind(self.get, self))
  local success, result = pcall(func, table.unpack(values))
  if success then
    return result
  end
  log.error('Dependency injection failed. Reason:', result)
end

return Injector
