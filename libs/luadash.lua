local _ = {}

_.assign = function(object, ...)
  local sources = { ... }
  _.forEach(sources, function(source)
    _.forEach(source, function(value, key)
      object[key] = value
    end)
  end)
  return object
end

_.bind = function(func, ...)
  local partials = { ... }
  return function(...)
    local params = _.concat(partials, { ... })
    return func(table.unpack(params))
  end
end

_.clone = function(value)
  return { table.unpack(value) }
end

_.concat = function(first, ...)
  local concated = _.clone(first)
  _.forEach({ ... }, function(tbl)
    _.forEach(tbl, function(value)
      table.insert(concated, value)
    end)
  end)
  return concated
end

_.filter = function(collection, iteratee)
  local filtered = {}
  _.forEach(collection, function(value, key)
    if iteratee(value, key) then
      if type(key) == 'number' then
        table.insert(filtered, value)
      else
        filtered[key] = value
      end
    end
  end)
  return filtered
end

_.forEach = function(collection, iteratee)
  if type(collection) == 'table' then
    for key, value in pairs(collection) do
      if iteratee(value, key) == false then
        return collection -- lua doesnt have a break
      end
    end
  end
  return collection
end

_.includes = function(collection, value)
  for k, v in pairs(collection) do
    if v == value then
      return true
    end
  end
  return false
end

_.invert = function(collection)
  local inverted = {}
  _.forEach(collection, function(value, key)
    inverted[value] = key
  end)
  return inverted
end

_.isEmpty = function(value)
  if type(value) ~= 'table' then
    return true
  end
  for k, v in pairs(value) do
    return false
  end
  return true
end

_.isInstanceOf = function(value, cls)
  while value do
    value = getmetatable(value)
    if value == cls then
      return true
    end
  end
  return false
end

_.join = function(tbl, separator)
  separator = separator or ','
  return table.join(tbl, separator)
end

_.map = function(collection, iteratee)
  local mapped = {}
  _.forEach(collection, function(value, key)
    mapped[key] = iteratee(value, key)
  end)
  return mapped
end

_.noop = function() end

_.omit = function(collection, paths)
  return _.filter(collection, function(value, key)
    return not _.includes(paths, key)
  end)
end

_.push = function(collection, ...)
  _.forEach({ ... }, function(value)
    table.insert(collection, value)
  end)
end

_.reduce = function(collection, iteratee, accumulator)
  _.forEach(collection, function(value, key)
    accumulator = iteratee(accumulator, value, key, collection)
  end)
  return accumulator
end

_.size = function(collection)
  return _.reduce(collection, function(size)
    return size + 1
  end, 0)
end

_.transform = function(object, iteratee, accumulator)
  return _.reduce(object, iteratee, accumulator or {})
end

_.upperFirst = function(str)
  return (str:gsub('^%1', string.upper))
end

return _
