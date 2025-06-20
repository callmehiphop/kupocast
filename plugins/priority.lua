local function getLevel()
  return AshitaCore:GetMemoryManager():GetPlayer():GetMainJobLevel()
end

return {
  name = 'Priority',
  install = function(profile)
    local store = profile.store

    store.playerLevel = getLevel()

    profile:once('load', function()
      gFunc.EvaluateLevels(profile.Sets, store.playerLevel)
    end)

    profile:pon('default', function()
      local level = getLevel()
      if store.playerLevel ~= level then
        store.playerLevel = level
        gFunc.EvaluateLevels(profile.Sets, level)
      end
    end)
  end,
}
