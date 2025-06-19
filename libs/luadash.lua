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

_.castArray = function(value)
  if _.isArrayLike(value) then
    return value
  end
  return { value }
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
      if _.isNumber(key) then
        table.insert(filtered, value)
      else
        filtered[key] = value
      end
    end
  end)
  return filtered
end

_.forEach = function(collection, iteratee)
  if _.isTable(collection) then
    for key, value in pairs(collection) do
      if iteratee(value, key) == false then
        return collection -- lua doesnt have a break
      end
    end
  end
  return collection
end

_.forEachRight = function(collection, iteratee)
  if _.isTable(collection) then
    if not #collection then
      return _.forEachRight(_.keys(collection), function(key)
        return iteratee(collection[key], key)
      end)
    end
    for i = #collection, 1, -1 do
      if iteratee(collection[i], i) == false then
        return collection
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

_.isArrayLike = function(value)
  return _.isTable(value) and #value > 0
end

_.isBoolean = function(value)
  return type(value) == 'boolean'
end

_.isEmpty = function(value)
  if _.isString(value) then
    return not #value
  elseif not _.isTable(value) then
    return true
  end
  for k, v in pairs(value) do
    return false
  end
  return true
end

_.isFunction = function(value)
  return type(value) == 'function'
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

_.isNil = function(value)
  return value == nil
end

_.isNumber = function(value)
  return type(value) == 'number'
end

_.isString = function(value)
  return type(value) == 'string'
end

_.isTable = function(value)
  return type(value) == 'table'
end

_.join = function(t, separator)
  return table.concat(t, separator or ',')
end

_.keys = function(object)
  local keys = {}
  _.forEach(object, function(value, key)
    table.insert(keys, key)
  end)
  return keys
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
  return collection
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
  return (str:gsub('^%l', string.upper))
end

_.unshift = function(collection, ...)
  _.forEachRight({ ... }, function(value)
    table.insert(collection, 1, value)
  end)
  return collection
end

return _
