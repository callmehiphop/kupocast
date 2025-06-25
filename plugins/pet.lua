local PetActionTags = {
  -- Wyvern Pet Actions
  ['Healing Breath'] = { 'WyvernBreath', 'HealingBreath' },
  ['Healing Breath II'] = { 'WyvernBreath', 'HealingBreath' },
  ['Healing Breath III'] = { 'WyvernBreath', 'HealingBreath' },
  ['Healing Breath IV'] = { 'WyvernBreath', 'HealingBreath' },
  ['Hydro Breath'] = { 'WyvernBreath', 'ElementalBreath', 'HydroBreath' },
  ['Lightning Breath'] = {
    'WyvernBreath',
    'ElementalBreath',
    'LightningBreath',
  },
  ['Sand Breath'] = { 'WyvernBreath', 'ElementalBreath', 'SandBreath' },
  ['Flame Breath'] = { 'WyvernBreath', 'ElementalBreath', 'FlameBreath' },
  ['Frost Breath'] = { 'WyvernBreath', 'ElementalBreath', 'FrostBreath' },
  ['Gust Breath'] = { 'WyvernBreath', 'ElementalBreath', 'GustBreath' },
}

return {
  name = 'Pet',
  install = function(profile)
    local store = profile.store

    profile:pon('default', function()
      local petAction = gData.GetPetAction()
      store.state.petAction = petAction
      if petAction then
        petAction.Tags = PetActionTags[petAction.Name]
        profile:emit('petaction', petAction)
      end
    end)
  end,
}
