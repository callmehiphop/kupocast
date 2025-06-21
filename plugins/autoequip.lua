local kupo = require('kupocast/kupocast')
local _ = require('kupocast/libs/luadash')

local fastCastGearValues = {
  ['Wlk. Chapeau +1'] = 0.10,
  ['Loquac. Earring'] = 0.02,
  ["Duelist's Tabard"] = 0.10,
  ["Warlock's Mantle"] = 0.02,
  ['Homam Cosciales'] = 0.05,
  ['Rostrum Pumps'] = 0.02,
}

local getFastCastTraitValue = function(player)
  local rdmLevel = 0
  local bluLevel = 0

  if player.MainJob == 'RDM' then
    rdmLevel = player.MainJobLevel
  elseif player.SubJob == 'RDM' then
    rdmLevel = player.SubJobLevel
  end

  if player.MainJob == 'BLU' then
    bluLevel = player.MainJobLevel
  end

  if rdmLevel >= 55 then
    return 0.20
  elseif rdmLevel >= 35 then
    return 0.15
  elseif rdmLevel >= 15 or bluLevel >= 72 then
    return 0.10
  end

  return 0
end

local getFastCastGearValue = function(set)
  local fastCast = 0
  for _, gear in pairs(set) do
    fastCast = fastCast + (fastCastGearValues[gear] or 0)
  end
  return fastCast
end

local getCastDelay = function(player, action, set)
  local traitFC = getFastCastTraitValue(player)
  local gearFC = getFastCastGearValue(set)
  local fastCast = math.min(traitFC + gearFC, 0.80)
  local minBuffer = 0.1
  return ((action.CastTime * (1 - fastCast)) / 1000) - minBuffer
end

return {
  name = 'AutoEquip',
  install = function(profile, options)
    options = options or {}

    local sets = profile.Sets
    local store = profile.store
    -- TODO: use plugin manager to check
    local packetDelay = (options.packetFlow and 0.25) or 0.4

    profile:on('default', function(player)
      if sets[player.Status] then
        kupo.equip(sets[player.Status])
      end
    end)

    profile:on('precast', function(action)
      local precastSet = sets.Precast or {}
      if precastSet then
        kupo.equip(precastSet)
      end
      local castDelay = getCastDelay(store.player, action, precastSet)
      if castDelay >= packetDelay then
        gFunc.SetMidDelay(castDelay)
      end
    end)

    profile:on('midcast', function(action)
      if sets.InterimCast then
        kupo.interimEquip(sets.InterimCast)
      end
      if sets.Recast then
        kupo.equip(sets.Recast)
      end
      if sets[action.Name] then
        return kupo.equip(sets[action.Name])
      end
      local tagSets = _.filter(action.Tags, function(tag)
        return sets[tag]
      end)
      if #tagSets > 0 then
        kupo.equip(sets[_.last(tagSets)])
      elseif sets[action.Skill] then
        kupo.equip(sets[action.Skill])
      elseif sets.Midcast then
        kupo.equip(sets.Midcast)
      end
    end)

    profile:on('ability', function(action)
      if sets[action.Name] then
        kupo.equip(sets[action.Name])
      elseif sets.Ability then
        kupo.equip(sets.Ability)
      end
    end)

    profile:on('weaponskill', function(action)
      if sets[action.Name] then
        kupo.equip(sets[action.Name])
      elseif sets.Weaponskill then
        kupo.equip(sets.Weaponskill)
      end
    end)

    -- this will only fire if the pet plugin is loaded
    profile:on('petaction', function(action)
      if action.Name:find('Breath') and sets.Breath then
        kupo.equip(sets.Breath)
      end
    end)
  end,
}
