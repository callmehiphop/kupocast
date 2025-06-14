return {
  name = 'Pet',
  install = function(profile)
    local store = profile.store

    profile:on('default', function()
      local petAction = gData.GetPetAction()
      store.state.petAction = petAction
      if petAction then
        profile:emit('petaction', petAction)
      end
    end)
  end,
}
