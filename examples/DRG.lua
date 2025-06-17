local kupo = require('kupocast')
local AutoEquipPlugin = require('kupocast/plugins/autoequip')
local PetPlugin = require('kupocast/plugins/pet')

local store = kupo.Store({
  toggles = {
    jellyRing = false,
  },
  cycles = {
    mode = { 'Default', 'Accuracy', 'Tank' },
  },
})

local profile = kupo.Profile({
  plugins = { PetPlugin, AutoEquipPlugin },
  store = store,
  lockStyle = 'LockStyle',
  display = {
    mode = '[m] Mode',
    jellyRing = '[j] Jelly Ring',
  },
  bind = {
    m = store.cycleMode,
    j = store.toggleJellyRing,
  },
})

local sets = profile.Sets

local DamageTaken = {
  Head = 'Darksteel Cap +1',
  Ear1 = "Merman's Earring",
  Ear2 = "Merman's Earring",
  Body = 'Dst. Harness +1',
  Hands = 'Dst. Mittens +1',
  Legs = 'Dst. Subligar +1',
  Feet = 'Dst. Leggings +1',
  Ring2 = function(jellyRing)
    return jellyRing and 'Jelly Ring'
  end,
}

local FastCast = {
  Ear1 = 'Loquac. Earring',
  Legs = 'Homam Cosciales',
  Back = function(player)
    return player.SubJob == 'RDM' and "Warlock's Mantle"
  end,
}

local Haste = {
  Head = 'Homam Zucchetto',
  Hands = 'Homam Manopolas',
  Ring2 = 'Blitz Ring',
  Waist = 'Swift Belt',
  Legs = 'Homam Cosciales',
  Feet = 'Homam Gambieras',
}

local Jump = {
  Legs = 'Barone Cosciales',
  Feet = 'Drachen Greaves',
}

local SIRD = {
  Ear2 = 'Magnetic Earring',
}

sets.LockStyle = {
  Main = 'Orichalcum Lance',
  Head = 'Wyrm Armet',
  Body = 'Scp. Harness +1',
  Hands = 'Homam Manopolas',
  Legs = 'Homam Cosciales',
  Feet = 'Homam Gambieras',
}

sets.Recast = kupo.combine(FastCast, Haste)
sets.Ninjutsu = sets.Recast

sets.Midcast = {
  Ammo = 'Happy Egg',
  Head = 'Drachen Armet',
  Neck = 'Ajase Beads',
  Ear2 = 'Morukaka Earring',
  Body = 'Scp. Harness +1',
  Hands = 'Homam Manopolas',
  Ring1 = 'Bomb Queen Ring',
  Ring2 = "Toreador's Ring",
  Back = 'Gigant Mantle',
  Waist = 'Swift Belt',
  Legs = 'Drachen Brais',
  Feet = 'Homam Gambieras',
}

sets.Jump = Jump
sets['High Jump'] = Jump

sets['Ancient Circle'] = {
  Legs = 'Drachen Brais',
}

sets.Breath = {
  Head = 'Wyrm Armet',
  Legs = 'Drachen Brais',
  Feet = 'Homam Gambieras',
}

sets.Weaponskill = {
  Ammo = 'Tiphia Sting',
  Head = 'Voyager Sallet',
  Ear1 = 'Brutal Earring',
  Ear2 = "Waetoto's Earring",
  Body = 'Assault Jerkin',
  Hands = "Pallas's Bracelets",
  Ring1 = 'Flame Ring',
  Ring2 = 'Flame Ring',
  Back = "Forager's Mantle",
  Waist = 'Warwolf Belt',
  Legs = 'Barone Cosciales',
  Feet = 'Wonder Clomps', -- lol
}

sets.Idle = sets:map('mode')
sets.Idle.Default = { Legs = 'Crimson Cuisses' }
sets.Idle.Tank = kupo.combine(DamageTaken, sets.Idle.Default)

sets.InterimCast = sets:map('mode')
sets.InterimCast.Default = SIRD
sets.InterimCast.Tank = kupo.combine(DamageTaken, SIRD)

sets.Engaged = sets:map('mode')
sets.Engaged.Default = kupo.combine(Haste, {
  Ammo = 'Tiphia Sting',
  Neck = 'Peacock Amulet',
  Ear1 = 'Brutal Earring',
  Ear2 = "Merman's Earring",
  Body = 'Assault Jerkin',
  Ring1 = "Toreador's Ring",
  Back = "Forager's Mantle",
})
sets.Engaged.Accuracy = kupo.combine(sets.Engaged.Default, {
  Head = 'Optical Hat',
  Body = 'Scp. Harness +1',
  Ring2 = "Toreador's Ring",
})
sets.Engaged.Tank = kupo.combine(sets.Engaged.Default, DamageTaken, {
  Ammo = 'Happy Egg',
  Back = 'Gigant Mantle',
  Waist = 'Warwolf Belt',
})

return profile
