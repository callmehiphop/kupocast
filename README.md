# kupocast

kupocast is a small MVC(ish) library that sits on top of [LuAshitacast](https://github.com/ThornyFFXI/LuAshitacast)

You can read the API docs below or you can explore the the examples directory.

**NOTE:** kupocast is currently in alpha testing, so you should expect bugs and for things to change. It has only been tested against LSB (specifically Horizon fork), so use at your own risk.

## API

### Importing

```lua
local kupo = require('kupocast/kupocast')
-- or if you prefer
local kupo = gFunc.LoadFile('kupocast/kupocast')
```

### Store

A Store can be used for state management. It serves as a centralized store for all gear sets in a profile. By default kupocast will capture `player`, `action` and `target` objects for you

```lua
local store = kupo.Store()
```

#### State

For static state that you want to manually define/control, you can specify a `state` table

```lua
local store = kupo.Store({
  state = {
    foo = 'bar'
  }
})

print(store.foo) -- "bar"
```

You can mutate the store directly to update your state

```lua
store.foo = 'baz'
print(store.foo) -- "baz"
```

#### Getters

A store getter allows you to perform an action (comparison, mapping, etc.) to a piece of state and return a new value. You can think of these like shortcuts

```lua
local store = kupo.Store({
  state = {
    playerName = 'Avesta'
  },
  getters = {
    spell = function(state)
      return state.action.Name
    end,
    isSelfCast = function(state)
      return state.target.Name == state.playerName
    end
  }
})

profile:on('midcast', function()
  if store.spell == 'Sneak' and store.isSelfCast then
    gFunc.Equip('Feet', 'Dream Boots +1')
  end
end)
```

#### Toggles

A toggle is a piece of state that can only be `true` or `false`. When you define a toggle, a convience method is created for you to toggle the state

```lua
local store = kupo.Store({
  toggles = {
    jellyRing = false
  }
})

print(store.jellyRing) -- false
store.toggleJellyRing()
print(store.jellyRing) -- true
```

#### Cycles

A cycle is a piece of state that can be an list of predefined values. A convience method is created to help you cycle through the values.

```lua
local store = kupo.Store({
  cycles = {
    mode = {'Default', 'Accuracy', 'OhShi'}
  }
})

print(store.mode) -- "Default"
store.cycleMode()
print(store.mode) -- "Accuracy"
store.cycleMode()
print(store.mode) -- "OhShi"
store.cycleMode()
print(store.mode) -- "Default"
```

### Profile

A kupocast profile comes with some conveniences to simplify hot keys, visual feedback, lockstyle and more.

```lua
local profile = kupo.Profile({
  store = store,
})

return profile
```

#### Lockstyle

kupocast profiles allow you can specify a set to lockstyle by providing either a number (representing an equipset) or the name of the lua set you want to lock

```lua
local profile = kupo.Profile({
  lockStyle = 1, -- if you're using an in game equipset

  lockStyle = 'BigPimpin', -- name of the set in the profile.Sets table
})
```

#### Hotkeys

kupocast profiles attempt to simplify the process of creating hotkeys by allowing you to specify the hotkey and either a command or function to call

```lua
local profile = kupo.Profile({
  bind = {
    p = '//stoneskin', -- bind to an existing command
    j = store.toggleJellyRing, -- bind to a store toggle
    m = store.cycleMode, -- bind to a store cycle
    q = function() -- bind to a custom function
      print('You pressed q!')
    end,
  }
})
```

#### Display

Taking a lot of inspiratation from `varhelper`, kupocast profiles allow you to easily display store state on the screen. You just need to provide a table with a key to the state and a label to overlay in the game

```lua
local profile = kupo.Profile({
  store = store,
  display = {
    jellyRing = '[j] Jelly Ring',
    mode = '[m] Mode'
  }
})
```

#### Events

kupocast profiles double up as event emitters, so you can subscribe to and emit events on the profile. This is the preferred way of handling things like precast, midcast, etc.

```lua
local profile = kupo.Profile()

profile:on('default', function(player)
  -- profiles call gData.GetPlayer() for you and inject it into the callback
end)

profile:on('midcast', function(spell, target)
  -- spell maps to gData.GetAction()
  -- target maps to gData.GetActionTarget()
end)
```

### Sets

kupocast sets behave just like regular LAC sets but come with several conveniences

```lua
local profile = kupo.Profile()
local sets = profile.Sets

sets.LockStyle = {
  Head = 'Goblin coif'
}
```

#### Computed

One convenience a kupocast set offers is the ability to define dynamic slots with dependency injection

```lua
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

sets.Nuke = {
  Ammo = 'Sweet Sachet',
  Head = 'Wzd. Petasos +1',
  Neck = 'Prudence Torque',
  Ear1 = 'Abyssal Earring',
  Ear2 = 'Moldavite Earring',
  Body = 'Igqira Weskit',
  Hands = 'Zenith Mitts'
  Ring1 = 'Tamas Ring',
  Ring2 = 'Snow Ring',
  Back = 'Prism Cape',
  Waist = 'Sorcerer\'s Belt',
  Legs = 'Mahatma Slops',
  Feet = 'Src. Sabots +1',
  Computed = {
    Main = function(action)
      return staves[action.Element]
    end
  }
}
```

#### Effects

kupocast also aims to simplify equipping latent/hidden effects. This is done in a similar way to computed slots, but are conditionally applied

```lua
local UggyPendant = {
  Name = 'Uggalepih Pendant',
  When = function(action)
    return action.MppAftercast < 51
  end
}

sets.Nuke = {
  -- equipped by default
  Neck = 'Prudence Torque',
  Effects = {
    -- conditionally equipped
    Neck = UggyPendant,
  }
}
```

#### Maps

In some cases, you might want to equip completely different sets based on some state mapped sets can help here.

The following example uses a store with a `mode` cycle that has `Default` and `PDT` options

```lua
sets.Idle = sets:map('mode')

sets.Idle.Default = {
  Body = "Sorcerer's Coat"
}

sets.Idle.PDT = kupo.combine(sets.Idle.Default, {
  Main = "Terra's Staff",
  Back = 'Umbra Cape'
})

gFunc.EquipSet('Idle') -- equips "Default" set
store.cycleMode()
gFunc.EquipSet('Idle') -- equips "PDT" set

```

### Plugins

While kupocast attempts to simplify profiles, in some cases you can turbo charge things with plugins. It's also very simple to author/user your own plugins

#### AutoEquip

The AutoEquip plugin is an opinionated way to go about naming and equipping your sets. When used correctly, your profile becomes little more than your sets and optionally a store

**TODO:** document the event -> set hierarchy

#### Conquest

The Conquest plugin automatically updates the profile store with state you can use to determine if the current zone is in or out of control

```lua
local kupo = require('kupocast/kupocast')
local ConquestPlugin = require('kupocast/plugins/conquest')

local profile = kupo.Profile({
  plugins = { ConquestPlugin },
})

local sets = profile.Sets

local ResentmentCape = {
  Name = 'Resentment Cape',
  When = 'conquestOutOfControl'
}

sets.MDT = {
  Effects = {
    Back = ResentmentCape
  }
}
```

#### Obi

```lua
local kupo = require('kupocast/kupocast')
local ObiPlugin = require('kupocast/plugins/obi')

local profile = kupo.Profile({
  plugins = { ObiPlugin }
})

local sets = profile.Sets

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

sets.Nuke = {
  Computed = {
    Waist = function(action, hasObiBonus)
      if hasObiBonus then
        return obis[action.Element]
      end
      return "Sorcerer's Belt"
    end
  }
}
```

#### Pet

TODO

#### Plugin API

TODO
