local kupo = require('kupocast/kupocast')
local AutoEquipPlugin = require('kupocast/plugins/autoequip')
local ConquestPlugin = require('kupocast/plugins/conquest')
local ObiPlugin = require('kupocast/plugins/obi')
local SpellTagsPlugin = require('kupocast/plugins/spelltags')

local store = kupo.Store({
  state = {
    playerName = AshitaCore:GetMemoryManager():GetParty():GetMemberName(0),
  },
  toggles = {
    magicBurst = false,
    sorcRing = false,
  },
  cycles = {
    accuracy = { 'Low', 'Medium', 'High' },
    mode = { 'Default', 'Enmity' },
  },
  getters = {
    isSelfCast = function(state)
      return state.target.Name == state.playerName
    end,
    shouldHpDown = function(state)
      return state.sorcRing and state.action.Skill == 'Elemental Magic'
    end,
    precast = function(state)
      return (state.shouldHpDown and 'HpDown') or 'Default'
    end,
  },
})

local profile = kupo.Profile({
  plugins = { AutoEquipPlugin, ConquestPlugin, ObiPlugin, SpellTagsPlugin },
  store = store,
  lockStyle = 'LockStyle',
  display = {
    mode = '[m] Mode',
    accuracy = '[c] Magic Accuracy',
    sorcRing = "[g] Sorcerer's Ring",
    magicBurst = '[b] Magic Burst',
  },
  bind = {
    m = store.cycleMode,
    c = store.cycleAccuracy,
    g = store.toggleSorcRing,
    b = store.toggleMagicBurst,
  },
})

local sets = profile.Sets

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

local Obi = function(action, hasObiBonus)
  return hasObiBonus and obis[action.Element]
end

local Staff = function(action)
  return staves[action.Element]
end

local FastCast = {
  Ear1 = 'Loquac. Earring',
  Feet = 'Rostrum Pumps',
  Back = function(player)
    return player.SubJob == 'RDM' and "Warlock's Mantle"
  end,
}

local Haste = {
  Body = 'Nashira Manteel',
  Waist = 'Swift Belt',
  Legs = 'Nashira Seraweels',
}

local INT = {
  Main = "Kirin's Pole",
  Ammo = 'Sweet Sachet',
  Head = 'Wzd. Petasos +1',
  Neck = 'Prudence Torque',
  Ear1 = 'Abyssal Earring',
  Ear2 = 'Morion Earring',
  Body = 'Errant Hpl.',
  Hands = 'Errant Cuffs',
  Ring1 = 'Tamas Ring',
  Ring2 = 'Snow Ring',
  Back = 'Prism Cape',
  Waist = "Sorcerer's Belt",
  Legs = 'Mahatma Slops',
  Feet = 'Src. Sabots +1',
}

local MND = {
  Main = "Kirin's Pole",
  Head = 'Errant Hat',
  Neck = 'Promise Badge',
  Ear1 = 'Geist Earring',
  Ear2 = 'Geist Earring',
  Body = 'Errant Hpl.',
  Hands = "Devotee's Mitts",
  Ring1 = 'Tamas Ring',
  Ring2 = 'Aqua Ring',
  Back = 'Prism Cape',
  Waist = "Penitent's Rope",
  Legs = 'Mahatma Slops',
  Feet = 'Errant Pigaches',
}

local MAB = {
  Ear2 = 'Moldavite Earring',
  Body = 'Igqira Weskit',
  Hands = 'Zenith Mitts',
  Neck = function(action)
    return action.MppAftercast < 51 and 'Uggalepih Pendant'
  end,
  Ring2 = function(player, sorcRing)
    return (sorcRing or player.HP < 641) and "Sorcerer's Ring"
  end,
}

local EnfeeblingSkill = {
  Main = Staff,
  Head = 'Igqira Tiara',
  Neck = 'Enfeebling Torque',
  Body = "Wizard's Coat",
  Waist = Obi,
  Legs = 'Genie Lappas',
  Hands = function(conquestOutOfControl)
    return conquestOutOfControl and 'Mst.Cst. Bracelets'
  end,
}

sets.LockStyle = {
  Main = "Diabolos's Pole",
  Head = 'Src. Petasos +1',
  Body = 'Nashira Manteel',
  Hands = 'Src. Gloves +1',
  Legs = "Sorcerer's Tonban",
  Feet = 'Src. Sabots +1',
}

sets.Idle = {
  Main = staves.Earth,
  Body = "Sorcerer's Coat",
  Back = 'Umbra Cape',
}

sets.Resting = {
  Main = "Pluto's staff",
  Ammo = 'Hedgehog bomb',
  Head = 'Wzd. Petasos +1',
  Neck = 'Checkered scarf',
  Ear1 = 'Magnetic earring',
  Ear2 = 'Relaxing earring',
  Body = 'Errant hpl.',
  Ring2 = 'Zoredonite ring',
  Back = 'Merciful Cape',
  Waist = 'Hierarch Belt',
  Legs = "Baron's slops",
}

sets.InterimCast = {
  Ear1 = 'Magnetic Earring',
}

sets.Recast = kupo.combine(FastCast, Haste)

sets.BlackEnfeebling = kupo.combine(INT, EnfeeblingSkill)
sets.WhiteEnfeebling = kupo.combine(MND, EnfeeblingSkill)

sets.Dark = kupo.combine(INT, {
  Main = Staff,
  Neck = 'Dark Torque',
  Ear2 = 'Dark Earring',
  Body = 'Nashira Manteel',
  Hands = 'Src. Gloves +1',
  Back = 'Merciful Cape',
  Legs = "Wizard's Tonban",
  Ring2 = function(action, environment, player)
    local threshold = (action.Name == 'Aspir' and 71) or 86
    if environment.DayElement == 'Dark' and player.MPP < threshold then
      return "Diabolos's Ring"
    end
  end,
})

sets.AbsorbPoints = kupo.combine(sets.Dark, {
  Main = function(environment)
    return environment.WeatherElement == 'Dark' and "Diabolos's Pole"
  end,
})

sets.BarSpell = {
  Neck = 'Enhancing Torque',
  Back = 'Merciful Cape',
}

sets.Cure = kupo.combine(MND, {
  Main = Staff,
  Waist = Obi,
})

sets.Dia = kupo.combine(MAB, {
  Waist = Obi,
})

sets.Spikes = kupo.combine(INT, MAB)

sets.Stoneskin = kupo.combine(MND, {
  Neck = 'Stone Gorget',
})

sets.Sneak = {
  Feet = function(isSelfCast)
    return isSelfCast and 'Dream Boots +1'
  end,
}

sets.Invisible = {
  Hands = function(isSelfCast)
    return isSelfCast and 'Dream Mittens +1'
  end,
}

sets.Precast = sets:select('precast')
sets.Precast.Default = FastCast
sets.Precast.HpDown = kupo.combine(FastCast, {
  Head = 'Zenith crown',
  Neck = 'Checkered scarf',
  Hands = 'Zenith mitts',
  Waist = "Penitent's rope",
  Legs = 'Zenith slacks',
})

sets.Elemental = sets:select('accuracy')
sets.Elemental.Low = kupo.combine(INT, { Main = Staff })
sets.Elemental.Medium = kupo.combine(sets.Elemental.Low, {
  Head = 'Src. Petasos +1',
  Back = 'Merciful Cape',
})
sets.Elemental.High = kupo.combine(sets.Elemental.Medium, {
  Neck = 'Elemental Torque',
  Hands = "Wizard's Gloves",
})

sets.Nuke = sets:weave('accuracy', 'mode')
sets.Nuke.Low = kupo.combine(INT, MAB, {
  Main = Staff,
  Waist = Obi,
  Hands = function(magicBurst)
    return magicBurst and 'Src. Gloves +1'
  end,
  Legs = function(action, environment)
    return action.Element == environment.DayElement and "Sorcerer's Tonban"
  end,
})
sets.Nuke.Medium = kupo.combine(sets.Nuke.Low, {
  Head = 'Src. Petasos +1',
  Back = 'Merciful Cape',
})
sets.Nuke.High = kupo.combine(sets.Nuke.Medium, {
  Neck = 'Elemental Torque',
  Hands = "Wizard's Gloves",
  Legs = 'Mahatma Slops',
})
sets.Nuke.Enmity = kupo.combine(INT, {
  Ammo = 'Hedgehog Bomb',
  Waist = "Penitent's Rope",
})

return profile
