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

local skillMap = {
  ['Healing Magic'] = 'Healing',
  ['Dark Magic'] = 'Dark',
  ['Enhancing Magic'] = 'Enhancing',
  ['Enfeebling Magic'] = 'Enfeebling',
  ['Elemental Magic'] = 'Elemental',
}

local elementalDebuffs = T({
  'Burn',
  'Choke',
  'Shock',
  'Drown',
  'Frost',
  'Rasp',
})

local getSpellFamily = function(action)
  if action.Skill == 'Healing Magic' then
    if action.Name:match('^Cur[ea]+g?a?') then
      return 'Cure'
    end
  elseif action.Skill == 'Dark Magic' then
    if action.Name:match('^Absorb') then
      return 'Absorb'
    end
  elseif action.Skill == 'Enhancing Magic' then
    if action.Name:match(' Spikes$') then
      return 'Spikes'
    end
  elseif action.Skill == 'Enfeebling Magic' then
    if action.Name:match('^Dia') then
      return 'Dia'
    end
    if action.Type == 'White Magic' then
      return 'WhiteEnfeebling'
    end
    return 'BlackEnfeebling'
  elseif action.Skill == 'Elemental Magic' then
    if not elementalDebuffs:contains(action.Name) then
      return 'Nuke'
    end
  end
  return nil
end

return {
  name = 'AutoEquip',
  install = function(profile, options)
    options = options or {}

    local sets = profile.Sets
    local store = profile.store
    local packetDelay = (options.packetFlow and 0.25) or 0.4

    profile:on('default', function(player)
      if sets[player.Status] then
        gFunc.EquipSet(sets[player.Status])
      end
    end)

    profile:on('precast', function(action)
      local set = sets.Precast or {}
      if set then
        gFunc.EquipSet(set)
      end
      local castDelay = getCastDelay(store.player, action, set)
      if castDelay >= packetDelay then
        gFunc.SetMidDelay(castDelay)
      end
    end)

    profile:on('midcast', function(action)
      if sets.InterimCast then
        gFunc.InterimEquipSet(sets.InterimCast)
      end
      if sets.Recast then
        gFunc.EquipSet(sets.Recast)
      end
      if sets[action.Name] then
        return gFunc.EquipSet(sets[action.Name])
      end
      local spellFamily = getSpellFamily(action)
      if sets[spellFamily] then
        return gFunc.EquipSet(sets[spellFamily])
      end
      local spellSkill = skillMap[action.Skill] or action.Skill
      if sets[spellSkill] then
        gFunc.EquipSet(sets[spellSkill])
      elseif sets.Midcast then
        gFunc.EquipSet(sets.Midcast)
      end
    end)

    profile:on('ability', function(action)
      if sets[action.Name] then
        gFunc.EquipSet(sets[action.Name])
      elseif sets.Ability then
        gFunc.EquipSet(sets.Ability)
      end
    end)

    profile:on('weaponskill', function(action)
      if sets[action.Name] then
        gFunc.EquipSet(sets[action.Name])
      elseif sets.Weaponskill then
        gFunc.EquipSet(sets.Weaponskill)
      end
    end)

    -- this will only fire if the pet plugin is loaded
    profile:on('petaction', function(action)
      if action.Name:find('Breath') and sets.Breath then
        gFunc.EquipSet(sets.Breath)
      end
    end)
  end,
}
