local kupo = require('kupocast/kupocast')
local AutoEquipPlugin = require('kupocast/plugins/autoequip')
local PetPlugin = require('kupocast/plugins/pet')
local PriorityPlugin = require('kupocast/plugins/priority')

local store = kupo.Store({
  toggles = {
    jellyRing = false,
  },
  cycles = {
    jugPet = { 'Sheep', 'Tiger' },
    mode = { 'Default', 'Accuracy', 'Tank' },
    weapon = { 'Axe/Club', 'Axe', 'Scythe' },
  },
})

local profile = kupo.Profile({
  plugins = { PetPlugin, PriorityPlugin, AutoEquipPlugin },
  store = store,
  lockStyle = 'LockStyle',
  display = {
    mode = '[m] Mode',
    weapon = '[q] Weapon',
    jugPet = '[p] Jug Pet',
    jellyRing = '[j] Jelly Ring',
  },
  bind = {
    m = store.cycleMode,
    q = store.cycleWeapon,
    p = store.cycleJugPet,
    j = store.toggleJellyRing,
  },
})

local sets = profile.Sets

local jugs = {
  Sheep = 'S. Herbal Broth',
  Tiger = 'W. Meat Broth',
}

local DamageTaken = {
  Head = 'Darksteel Cap +1',
  Ear1 = "Merman's Earring",
  Ear2 = "Merman's Earring",
  Body = 'Dst. Harness +1',
  Hands = 'Dst. Mittens +1',
  Legs = 'Dst. Subligar +1',
  Feet = 'Dst. Leggings +1',
}

local FastCast = {
  Ear1 = 'Loquac. Earring',
}

local Haste = {
  Head = "Patroclus's Helm",
  Hands = 'Dusk Gloves',
  Ring1 = 'Blitz Ring',
  Waist = 'Swift Belt',
  Feet = 'Dusk Ledelsens',
}

local SIRD = {
  Ear2 = 'Magnetic Earring',
}

sets.LockStyle = {
  Head = 'Optical Hat',
  Body = 'Hauberk',
  Hands = 'Dusk Gloves',
  Legs = 'Thick Breeches',
  Feet = 'Dusk Ledelsens',
}

sets.Precast = FastCast
sets.Midcast = kupo.combine(FastCast, Haste)

sets['Call Beast'] = {
  Ammo = function(jugPet)
    return jugs[jugPet]
  end,
}

sets.Charm = {
  Main = "Apollo's Staff",
  Head = 'Beast Helm',
  Body = 'Beast Jackcoat',
  Hands = 'Beast Gloves',
  Legs = 'Beast Trousers',
  Feet = 'Beast Gaiters',
}

sets.Reward_Priority = {
  Ammo = { 'Pet Food Zeta', 'Pet Fd. Epsilon', 'Pet Food Delta' },
  Neck = 'Promise Badge',
  Ear1 = 'Geist Earring',
  Ear2 = 'Geist Earring',
  Body = 'Beast Jackcoat',
  Ring1 = 'Tamas Ring',
  Ring2 = 'Aqua Ring',
  Legs = 'Wonder Braccae',
  Feet = 'Beast Gaiters',
}

sets.Weaponskill = {
  Head = 'Voyager Sallet',
  Neck = 'Peacock Amulet',
  Ear1 = "Waetoto's Earring",
  Ear2 = 'Brutal Earring',
  Body = 'Hauberk',
  Hands = "Pallas's Bracelets",
  Ring1 = 'Flame Ring',
  Ring2 = 'Flame Ring',
  Back = "Forager's Mantle",
  Waist = 'Warwolf Belt',
  Legs = 'Thick Breeches',
  Feet = 'Wonder Clomps', -- lol get something else
}

sets['Spiral Hell'] = kupo.combine(sets.Weaponskill, {
  Neck = 'Snow Gorget',
})

sets.InterimCast = sets:select('mode')
sets.InterimCast.Default = SIRD
sets.InterimCast.Tank = kupo.combine(DamageTaken, SIRD)

sets.Idle = sets:select('mode')
sets.Idle.Default = { Hands = 'remove', Feet = 'remove' }
sets.Idle.Tank = DamageTaken

sets.Engaged = sets:layer('weapon', 'mode')
sets.Engaged.Default = kupo.combine(Haste, {
  Ammo = 'Tiphia Sting',
  Neck = 'Peacock Amulet',
  Ear1 = 'Brutal Earring',
  Ear2 = "Merman's Earring",
  Body = 'Hauberk',
  Ring2 = "Toreador's Ring",
  Back = "Forager's Mantle",
  Legs = 'Thick Breeches',
})
sets.Engaged.Accuracy = kupo.combine(sets.Engaged.Default, {
  Head = 'Optical Hat',
  Ring1 = "Toreador's Ring",
})
sets.Engaged['Axe/Club'] = {
  Main = 'Maneater',
  Sub = 'Octave Club',
  Ear1 = 'Stealth Earring',
}
sets.Engaged.Axe = {
  Main = 'Maneater',
  Sub = '', -- TODO: Get a tatami shield :(
}
sets.Engaged.Scythe = {
  Main = "Suzaku's Scythe", -- spelling??
  Ear2 = 'Abyssal Earring',
}
sets.Engaged.Tank = kupo.combine(sets.Engaged.Default, DamageTaken, {
  Ammo = 'Happy Egg',
  Back = 'Gigant Mantle',
  Waist = 'Warwolf Belt',
})

return profile
