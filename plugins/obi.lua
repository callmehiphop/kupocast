local elementWeakness = {
  Dark = 'Light',
  Earth = 'Wind',
  Fire = 'Water',
  Ice = 'Fire',
  Light = 'Dark',
  Thunder = 'Earth',
  Water = 'Thunder',
  Wind = 'Ice',
}

local getPotency = function(el, env)
  local weakness = elementWeakness[el]
  local potency = 0

  if el == env.DayElement then
    potency = potency + 10
  elseif weakness == env.DayElement then
    potency = potency - 10
  end

  local isDoubleWeather = env.Weather:match('x2')
  local weatherBonus = (isDoubleWeather and 25) or 10

  if el == env.WeatherElement then
    potency = potency + weatherBonus
  elseif weakness == env.WeatherElement then
    potency = potency - weatherBonus
  end

  return potency
end

return {
  name = 'Obi',
  install = function(profile)
    local store = profile.store

    store.getters.obiPotency = function(state)
      return getPotency(state.action.Element, state.environment)
    end

    store.getters.hasObiBonus = function(state)
      return state.obiPotency > 0
    end

    profile:on('precast', function()
      store.environment = gData.GetEnvironment()
    end)
  end,
}
