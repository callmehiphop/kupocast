local kupo = require('kupocast/kupocast')

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
  return kupo.reduce(set, function(total, gear)
    return total + (fastCastGearValues[gear] or 0)
  end, 0)
end

local getCastDelay = function(player, action, set)
  local traitFC = getFastCastTraitValue(player)
  local gearFC = getFastCastGearValue(set)
  local fastCast = math.min(traitFC + gearFC, 0.80)
  local minBuffer = 0.1
  return ((action.CastTime * (1 - fastCast)) / 1000) - minBuffer
end

local hasPacketFlow = function()
  return AshitaCore:GetPluginManager():Get('PacketFlow')
end

return {
  name = 'AutoEquip',
  install = function(profile)
    local sets = profile.Sets
    local store = profile.store

    profile:on('default', function(player)
      if sets[player.Status] then
        kupo.equip(sets[player.Status])
      end
    end)

    profile:on('precast', function(action)
      local set = sets.Precast and kupo.build(sets.Precast)
      local castDelay = getCastDelay(store.player, action, set)
      local packetDelay = (hasPacketFlow() and 0.25) or 0.4

      if set then
        kupo.equip(set)
      end
      if castDelay >= packetDelay then
        gFunc.SetMidDelay(castDelay)
      end
    end)

    profile:on('midcast', function(action)
      if sets.InterimCast then
        kupo.interimEquip(sets.InterimCast)
      end

      local layers = { 'Midcast', action.Skill }

      if action.Tags then
        layers = kupo.concat(layers, action.Tags)
      end

      table.insert(layers, action.Name)

      kupo.forEach(layers, function(layer)
        if sets[layer] then
          kupo.equip(sets[layer])
        end
      end)
    end)

    profile:on('ability', function(action)
      if sets.Ability then
        kupo.equip(sets.Ability)
      end
      if sets[action.Name] then
        kupo.equip(sets[action.Name])
      end
    end)

    profile:on('weaponskill', function(action)
      if sets.Weaponskill then
        kupo.equip(sets.Weaponskill)
      end
      if sets[action.Name] then
        kupo.equip(sets[action.Name])
      end
    end)

    profile:on('preshot', function()
      if sets.Preshot then
        kupo.equip(sets.Preshot)
      end
    end)

    -- TODO: learn more about this? This is probably a naive implementation
    -- Needs to figure out how to computed ranged delay :X
    profile:on('midshot', function()
      if sets.InterimShot then
        kupo.interimEquip(sets.InterimShot)
      end
      if sets.Midshot then
        kupo.equip(sets.Midshot)
      end
    end)

    -- this will only fire if the pet plugin is loaded
    profile:on('petaction', function(action)
      local layers = { 'Pet' .. action.ActionType }

      if action.Tags then
        layers = kupo.concat(layers, action.Tags)
      end

      table.insert(layers, action.Name)

      kupo.forEach(layers, function(layer)
        if sets[layer] then
          kupo.equip(sets[layer])
        end
      end)
    end)
  end,
}
