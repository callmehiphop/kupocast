local kupo = require('kupocast/kupocast')
local AutoEquipPlugin = require('kupocast/plugins/autoequip')
local ConquestPlugin = require('kupocast/plugins/conquest')
local TagsPlugin = require('kupocast/plugins/tags')

local store = kupo.Store({
  toggles = {
    jellyRing = false,
  },
  cycles = {
    mode = { 'Default', 'Accuracy', 'Tank', 'Zerg' },
    weapon = { 'Scythe', 'Great Sword', 'Great Axe', 'Club' },
  },
  getters = {
    dayElement = function()
      return gData.GetEnvironment().DayElement
    end,
    -- TODO: maybe these should go in a Time plugin?
    isDayTime = function(state)
      return state.time.hour > 5 and state.time.hour < 18
    end,
    time = function()
      return gData.GetTimestamp()
    end,
  },
})

local profile = kupo.Profile({
  plugins = { AutoEquipPlugin, ConquestPlugin, TagsPlugin },
  store = store,
  lockStyle = 'LockStyle',
  display = {
    weapon = '[q] Weapon',
    mode = '[m] Mode',
    jellyRing = '[j] Jelly Ring',
  },
  bind = {
    q = store.cycleWeapon,
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
}

local Haste = {
  Head = 'Homam Zucchetto',
  Hands = 'Homam Manopolas',
  Ring1 = 'Blitz Ring',
  Waist = 'Swift Belt',
  Legs = 'Homam Cosciales',
  Feet = 'Homam Gambieras',
  Ear2 = function(player)
    return player.SubJob == 'DRG' and 'Wyvern Earring'
  end,
}

local HP = {
  Ear1 = 'Morukaka Earring',
  Ring2 = 'Bomb Queen Ring',
  Back = 'Gigant Mantle',
  Ammo = function(isDayTime)
    if isDayTime then
      return "Fenrir's Stone"
    end
    return 'Happy Egg'
  end,
  Neck = function(conquestUnderControl)
    if conquestUnderControl then
      return 'Ajase Beads'
    end
    return 'Irn.Msk. Gorget'
  end,
}

local SIRD = {
  Ear2 = 'Magnetic Earring',
}

sets.LockStyle = {
  Main = 'Tredecim Scythe',
  Body = 'Vampire Cloak',
  Hands = 'Homam Manopolas',
  Legs = 'Homam Cosciales',
  Feet = 'Homam Gambieras',
}

sets.Resting = {
  Neck = 'Checkered Scarf',
  Ear1 = 'Magnetic Earring',
  Ear2 = 'Relaxing Earring',
  Waist = 'Hierarch belt',
  Legs = "Baron's Slops",
}

sets['Arcane Circle'] = {
  Feet = 'Chs. Sollerets +1',
}

sets.Weaponskill = {
  Head = 'Chs. Burgeonet +1',
  Neck = 'Peacock Amulet',
  Ear1 = 'Brutal Earring',
  Ear2 = "Waetoto's Earring",
  Body = 'Hauberk',
  Hands = "Pallas's Bracelets",
  Ring1 = 'Flame Ring',
  Ring2 = 'Flame Ring',
  Back = "Forager's Mantle",
  Waist = 'Warwolf Belt',
  Legs = 'Black Cuisses',
  Feet = 'Chs. Sollerets +1',
}

sets.Guillotine = kupo.combine(sets.Weaponskill, {
  Ear2 = 'Abyssal Earring',
})

local IceAffinity = kupo.combine(sets.Weaponskill, {
  Neck = 'Snow Gorget',
})

sets['Cross Reaper'] = IceAffinity
sets['Spiral Hell'] = IceAffinity
sets['Ground Strike'] = IceAffinity

local WindAffinity = kupo.combine(sets.Weaponskill, {
  Neck = 'Breeze Gorget',
})

sets['Spinning Slash'] = WindAffinity
sets['Savage Blade'] = WindAffinity

sets.Precast = FastCast
sets.Midcast = kupo.combine(FastCast, Haste)

sets.Dark = {
  Ammo = 'Sweet Sachet',
  Head = 'Chs. Burgeonet +1',
  Neck = 'Dark Torque',
  Ear1 = 'Abyssal earring',
  Ear2 = 'Dark earring',
  Hands = 'Crimson Fng. Gnt.',
  Ring1 = 'Tamas Ring',
  Back = 'Merciful Cape',
  Ring2 = function(action, dayElement, player)
    local threshold = (action.Name == 'Aspir' and 71) or 86
    if dayElement == 'Dark' and player.MPP < threshold then
      return "Diabolos's Ring"
    end
    return 'Snow Ring'
  end,
}

sets.Absorb = {
  Legs = 'Black Cuisses',
}

sets.Stun = sets.Recast

sets.InterimCast = sets:select('mode')
sets.InterimCast.Default = SIRD
sets.InterimCast.Tank = kupo.combine(DamageTaken, SIRD)

sets.Idle = sets:select('mode')
sets.Idle.Default = {
  Neck = 'Parade Gorget',
  Body = 'Vampire Cloak',
  Legs = 'Crimson Cuisses',
}
sets.Idle.Tank = kupo.combine(DamageTaken, {
  Neck = 'Parade Gorget',
  Legs = 'Crimson Cuisses',
})

sets.Engaged = sets:layer('weapon', 'mode')
sets.Engaged.Default = kupo.combine(Haste, {
  Ammo = 'Bomb Core',
  Neck = 'Peacock Amulet',
  Ear1 = 'Brutal Earring',
  Ear2 = "Merman's Earring",
  Body = 'Hauberk',
  Ring2 = "Toreador's Ring",
  Back = "Forager's Mantle",
})
sets.Engaged.Accuracy = kupo.combine(sets.Engaged.Default, {
  Ammo = 'Tiphia Sting',
  Head = 'Optical Hat',
  Ring1 = "Toreador's Ring",
})
-- Engaged Weapon sets
sets.Engaged.Scythe = {
  Main = 'Tredecim Scythe',
  Ear2 = function(mode, player)
    if player.SubJob == 'DRG' and mode ~= 'Accuracy' then
      return 'Wyvern Earring'
    end
    return 'Abyssal Earring'
  end,
}
sets.Engaged['Great Sword'] = kupo.combine(sets.Engaged.Scythe, {
  Main = 'Balmung',
  Neck = 'Prudence Torque',
})
sets.Engaged['Great Axe'] = {
  Main = 'Martial Bhuj',
}
sets.Engaged.Club = {
  Main = 'Octave Club',
  Ear1 = "Merman's Earring",
  Sub = function(player)
    if player.SubJob == 'DRG' then
      return 'Wyvern Targe'
    end
    return 'She-slime shield'
  end,
}
sets.Engaged.Tank = kupo.combine(sets.Engaged.Default, DamageTaken, {
  Ammo = 'Happy Egg',
  Neck = 'Parade Gorget',
  Back = 'Gigant Mantle',
  Waist = 'Warwolf Belt',
})
sets.Engaged.Zerg = kupo.combine(HP, Haste, {
  Body = 'Gloom Breastplate',
})

return profile
