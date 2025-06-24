local kupo = require('kupocast/kupocast')
local AutoEquipPlugin = require('kupocast/plugins/autoequip')
local ConquestPlugin = require('kupocast/plugins/conquest')
local ObiPlugin = require('kupocast/plugins/obi')
local TagsPlugin = require('kupocast/plugins/tags')

---
--- Store Definition
---
local store = kupo.Store({
  state = {
    playerName = AshitaCore:GetMemoryManager():GetParty():GetMemberName(0),
  },
  toggles = {
    jellyRing = false,
    weaponLock = false,
  },
  cycles = {
    mode = { 'Default', 'Accuracy', 'Tank' },
    accuracy = { 'Low', 'Medium', 'High' },
    weapon = { 'Dagger', 'Dagger/Club', 'Sword' },
  },
  getters = {
    isSelfCast = function(state)
      return state.target.Name == state.playerName
    end,
  },
})

---
--- Profile Definition
---
local profile = kupo.Profile({
  plugins = { AutoEquipPlugin, ConquestPlugin, ObiPlugin, TagsPlugin },
  store = store,
  lockStyle = 'LockStyle',
  display = {
    accuracy = '[c] Magic Accuracy',
    mode = '[m] Mode',
    jellyRing = '[j] Jelly Ring',
    weapon = '[q] Weapon',
    weaponLock = '[l] Weapon Lock',
  },
  bind = {
    c = store.cycleAccuracy,
    m = store.cycleMode,
    j = store.toggleJellyRing,
    q = store.cycleWeapon,
    l = store.toggleWeaponLock,
  },
  watch = {
    weapon = kupo.debounce(250, function()
      if store.weaponLock then
        kupo.enable({ 'Main', 'Sub' })
        kupo.forceEquip('Engaged')
        kupo.disable({ 'Main', 'Sub' })
      end
    end),
    weaponLock = kupo.debounce(250, function(locked)
      if locked then
        kupo.forceEquip('Engaged')
        kupo.disable({ 'Main', 'Sub' })
      else
        kupo.enable({ 'Main', 'Sub' })
      end
    end),
  },
})

---
--- Set Definitions
---
local sets = profile.Sets

---
--- Helper Tables and Functions
---
local staves = {
  Dark = "Pluto's Staff",
  Earth = "Terra's Staff",
  Fire = "Vulcan's Staff",
  Ice = "Aquilo's Staff",
  Light = "Apollo's Staff",
  Thunder = "Jupiter's Staff",
  Water = "Neptune's Staff",
  Wind = "Auster's Staff",
}

local obis = {
  Dark = 'Anrin obi',
  Earth = 'Dorin obi',
  Fire = 'Karin obi',
  Ice = 'Hyorin obi',
  Light = 'Korin obi',
  Thunder = 'Rairin obi',
  Water = 'Suirin obi',
  Wind = 'Furin obi',
}

local function Obi(action, hasObiBonus)
  return hasObiBonus and obis[action.Element]
end

local function Staff(action)
  return staves[action.Element]
end

---
--- Core Equipment Sets (Reusable Components)
---
local DamageTaken = {
  Head = 'Darksteel Cap +1',
  Ear1 = "Merman's Earring",
  Ear2 = "Merman's Earring",
  Body = 'Dst. Harness +1',
  Hands = 'Dst. Mittens +1',
  Back = 'Umbra Cape',
  Legs = 'Dst. Subligar +1',
  Feet = 'Dst. Leggings +1',
  Ring2 = function(jellyRing)
    return jellyRing and 'Jelly Ring'
  end,
}

local ElementalSkillLow = { Main = Staff, Sub = '' }
local ElementalSkillMedium = kupo.combine(ElementalSkillLow, {
  Neck = 'Elemental Torque',
})
local ElementalSkillHigh = kupo.combine(ElementalSkillMedium, {
  Legs = "Duelist's Tights",
  Ear2 = function(player)
    return player.SubJob == 'BLM' and "Wizard's Earring"
  end,
})

local EnfeeblingSkillLow = {
  Main = Staff,
  Sub = '',
  Head = "Duelist's Chapeau",
}
local EnfeeblingSkillMedium = kupo.combine(EnfeeblingSkillLow, {
  Neck = 'Enfeebling Torque',
  Legs = 'Nashira Seraweels',
})
local EnfeeblingSkillHigh = kupo.combine(EnfeeblingSkillMedium, {
  Body = "Warlock's Tabard",
  Waist = Obi,
  Hands = function(conquestOutOfControl) -- Assumes `conquestOutOfControl` is a state variable.
    return conquestOutOfControl and 'Mst.Cst. Bracelets'
  end,
})

local EnhancingSkill = {
  Neck = 'Enhancing torque',
  Hands = 'Dls. gloves +1',
  Legs = "Warlock's tights",
}

local FastCast = {
  Head = 'Wlk. Chapeau +1',
  Body = "Duelist's tabard",
  Ear1 = 'Loquac. earring',
}

local Haste = {
  Body = 'Nashira manteel',
  Hands = 'Dusk Gloves',
  Waist = 'Swift Belt',
  Legs = 'Nashira Seraweels',
  Feet = 'Dusk Ledelsens',
}

local INT = {
  Main = 'Mythic wand +1',
  Sub = 'Tortoise shield',
  Ammo = 'Sweet sachet',
  Head = 'Wlk. Chapeau +1',
  Neck = 'Prudence torque',
  Ear1 = 'Abyssal earring',
  Ear2 = 'Morion earring',
  Body = 'Errant hpl.',
  Hands = 'Errant cuffs',
  Ring1 = 'Tamas ring',
  Ring2 = 'Snow ring',
  Back = 'Prism cape',
  Waist = "Penitent's rope",
  Legs = 'Mahatma slops',
  Feet = 'Wise pigaches',
}

local MAB = {
  Ear2 = 'Moldavite Earring',
  Hands = 'Zenith Mitts',
  Feet = 'Dls. Boots +1',
  Neck = function(action)
    return action.MppAftercast < 51 and 'Uggalepih Pendant'
  end,
}

local MND = {
  Main = 'Mythic wand +1',
  Sub = 'Tortoise shield',
  Ammo = 'Hedgehog Bomb',
  Head = 'Errant hat',
  Neck = 'Promise Badge',
  Ear1 = 'Geist earring',
  Ear2 = 'Geist earring',
  Body = 'Errant hpl.',
  Hands = "Devotee's mitts",
  Ring1 = 'Tamas ring',
  Ring2 = 'Aqua ring',
  Back = 'Prism cape',
  Waist = "Penitent's rope",
  Legs = 'Mahatma slops',
  Feet = 'Errant pigaches',
}

local Movement = {
  Legs = 'Crimson Cuisses',
}

local Refresh = {
  Head = 'Dls. Chapeau +1',
}

local SIRD = {
  Ear2 = 'Magnetic Earring',
  Body = "Warlock's Tabard",
}

---
--- Main Equipment Sets
---
sets.LockStyle = {
  Main = staves.Earth,
  Head = 'Dls. chapeau +1',
  Body = 'Nashira manteel',
  Hands = 'Dls. gloves +1',
  Legs = 'Nashira seraweels',
  Feet = 'Dls. Boots +1',
}

sets.Resting = {
  Main = staves.Dark,
  Ammo = 'Hedgehog bomb',
  Head = 'Dls. chapeau +1',
  Neck = 'Checkered scarf',
  Ear1 = 'Magnetic earring',
  Ear2 = 'Relaxing earring',
  Body = 'Errant hpl.',
  Hands = 'Dls. gloves +1',
  Ring1 = 'Tamas Ring',
  Ring2 = 'Zoredonite ring',
  Waist = "Duelist's Belt",
  Legs = "Baron's slops",
  Feet = 'Dls. Boots +1',
  Back = function(player)
    if player.SubJob == 'BLM' then
      return "Wizard's Mantle"
    end
    return 'Merciful Cape'
  end,
}

sets.Convert = {
  Main = staves.Light,
  Sub = '',
  Ammo = 'Hedgehog bomb',
  Head = 'Wlk. Chapeau +1',
  Neck = 'Uggalepih Pendant',
  Ear1 = 'Loquac. earring',
  Ear2 = 'Magnetic earring',
  Body = "Duelist's tabard",
  Hands = 'Dls. gloves +1',
  Ring1 = 'Tamas ring',
  Ring2 = 'Zoredonite ring',
  Back = 'Merciful Cape',
  Waist = 'Hierarch belt',
  Legs = 'Crimson cuisses',
  Feet = 'Dls. Boots +1',
}

sets.Weaponskill = {
  Head = 'Optical Hat',
  Neck = 'Peacock Amulet',
  Ear1 = 'Brutal Earring',
  Ear2 = "Waetoto's Earring",
  Body = 'Assault Jerkin',
  Ring1 = 'Flame Ring',
  Ring2 = 'Flame Ring',
  Back = "Forager's Mantle",
  Waist = 'Warwolf Belt',
  Legs = "Duelist's Tights",
  Feet = 'Wonder Clomps',
}

sets.Precast = FastCast
sets.Recast = kupo.combine(Haste, FastCast)

sets.Cure = kupo.combine(MND, {
  Main = staves.Light,
  Waist = Obi,
})

sets.Dark = kupo.combine(INT, {
  Main = Staff,
  Sub = '',
  Neck = 'Dark Torque',
  Ear2 = 'Dark Earring',
  Body = 'Nashira Manteel',
  Hands = 'Crimson Fng. Gnt.',
  Back = 'Merciful Cape',
  Ring2 = function(action, environment, player)
    local threshold = (action.Name == 'Aspir' and 71) or 86
    if environment.DayElement == 'Dark' and player.MPP < threshold then
      return "Diabolos's Ring"
    end
  end,
})

sets.Dia = kupo.combine(MAB, {
  Waist = Obi,
})

sets.BarSpell = EnhancingSkill
sets.EnSpell = EnhancingSkill

sets.Spikes = kupo.combine(sets.INT, sets.MAB)

sets.Stoneskin = kupo.combine(MND, {
  Neck = 'Stone Gorget',
})

sets.Stun = kupo.combine(sets.Dark, FastCast)

sets.Invisible = {
  Hands = function(isSelfCast)
    return isSelfCast and 'Dream Mittens +1'
  end,
}

sets.Sneak = {
  Feet = function(isSelfCast)
    return isSelfCast and 'Dream Boots +1'
  end,
}

sets.InterimCast = sets:select('mode')
sets.InterimCast.Default = SIRD
sets.InterimCast.Tank = kupo.combine(DamageTaken, SIRD)

sets.Elemental = sets:select('accuracy')
sets.Elemental.Low = kupo.combine(INT, ElementalSkillLow)
sets.Elemental.Medium = kupo.combine(INT, ElementalSkillMedium)
sets.Elemental.High = kupo.combine(INT, ElementalSkillHigh)

sets.Nuke = sets:select('accuracy')
sets.Nuke.Low = kupo.combine(INT, MAB, ElementalSkillLow, { Waist = Obi })
sets.Nuke.Medium = kupo.combine(sets.Nuke.Low, ElementalSkillMedium)
sets.Nuke.High = kupo.combine(sets.Nuke.Low, ElementalSkillHigh)

sets.BlackEnfeebling = sets:select('accuracy')
sets.BlackEnfeebling.Low = kupo.combine(INT, EnfeeblingSkillLow)
sets.BlackEnfeebling.Medium = kupo.combine(INT, EnfeeblingSkillMedium)
sets.BlackEnfeebling.High = kupo.combine(INT, EnfeeblingSkillHigh)

sets.WhiteEnfeebling = sets:select('accuracy')
sets.WhiteEnfeebling.Low = kupo.combine(MND, EnfeeblingSkillLow)
sets.WhiteEnfeebling.Medium = kupo.combine(MND, EnfeeblingSkillMedium)
sets.WhiteEnfeebling.High = kupo.combine(MND, EnfeeblingSkillHigh)

sets.Idle = sets:select('mode')
sets.Idle.Default = kupo.combine(Refresh, Movement, {
  Main = staves.Earth,
  Ammo = 'Hedgehog Bomb',
  Neck = 'Stone Gorget',
  Ear1 = 'Loquac. Earring',
  Ear2 = 'Magnetic Earring',
  Body = 'Nashira Manteel',
  Hands = 'Dls. Gloves +1',
  Ring1 = 'Tamas Ring',
  Ring2 = 'Aqua Ring',
  Back = 'Umbra Cape',
  Waist = "Duelist's Belt",
  Feet = 'Dls. Boots +1',
})
sets.Idle.Tank = kupo.combine(DamageTaken, Refresh, Movement, {
  Main = staves.Earth,
})

sets.Engaged = sets:layer('weapon', 'mode')
sets.Engaged.Default = kupo.combine(Haste, Refresh, {
  Ammo = 'Tiphia Sting',
  Neck = 'Peacock Amulet',
  Ear1 = 'Brutal Earring',
  Ear2 = "Merman's Earring",
  Ring1 = "Toreador's Ring",
  Ring2 = "Toreador's Ring",
  Back = "Forager's Mantle",
})
sets.Engaged.Accuracy = kupo.combine(sets.Engaged.Default, {
  Body = 'Scp. Harness +1',
})
sets.Engaged.Dagger = {
  Main = 'Blau Dolch',
  Sub = "Genbu's Shield",
}
sets.Engaged['Dagger/Club'] = kupo.combine(sets.Engaged.Dagger, {
  Sub = 'Octave Club',
  Ear1 = 'Stealth Earring',
})
sets.Engaged.Sword = {
  Main = 'Joyeuse',
  Sub = "Genbu's Shield",
}
sets.Engaged.Tank = kupo.combine(DamageTaken, Refresh, {
  Ammo = 'Happy Egg',
  Waist = 'Warwolf Belt',
})

---
--- Event Handlers
---
profile:on('ability', function(ability)
  if ability.Name == 'Convert' then
    -- Locks the Convert set for 10 seconds for cures
    gFunc.LockSet(sets.Convert, 10)
  end
end)

---
--- Export Profile
---
return profile
