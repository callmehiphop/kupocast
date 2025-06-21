------------
-- A small Set implementation for Lua
-- @classmodule Set
-- @author callmehiphop
-- @license MIT
---
local Set = {}
Set.__index = Set

Set.__len = function(set)
  return set.size
end

function Set.new(iterable)
  local set = setmetatable({}, Set)

  set.size = 0
  set._values = {}

  if iterable then
    for i = 1, #iterable do
      set:add(iterable[i])
    end
  end

  return set
end

function Set:add(value)
  if not self._values[value] then
    self._values[value] = true
    self.size = self.size + 1
  end
  return self
end

function Set:clear()
  self._values = {}
  self.size = 0
end

function Set:delete(value)
  if not self._values[value] then
    return false
  end
  self._values[value] = nil
  self.size = self.size - 1
  return true
end

function Set:forEach(callback)
  for key in pairs(self._values) do
    callback(key, key, self)
  end
end

function Set:has(value)
  return self._values[value] or false
end

return Set
