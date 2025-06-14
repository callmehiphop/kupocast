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
      iteratee(value, key)
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

_.map = function(collection, iteratee)
  local mapped = {}
  _.forEach(collection, function(value, key)
    mapped[key] = iteratee(value, key)
  end)
  return mapped
end

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

_.transform = function(object, iteratee, accumulator)
  accumulator = accumulator or {}
  _.forEach(object, function(value, key)
    accumulator = iteratee(accumulator, value, key, object) or accumulator
  end)
  return accumulator
end

_.upperFirst = function(str)
  return (str:gsub('^%1', string.upper))
end

return _
