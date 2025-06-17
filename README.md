# Kupocast

A declarative framework for LuAshitacast that simplifies min/maxing and equipment management.

## Overview

Kupocast takes the complexity out of writing gearswap scripts by providing a clean, declarative API for defining equipment sets and their variations. Instead of writing imperative code with lots of conditionals, you describe *what* gear you want to use and *when*, letting the framework handle the mechanics.

## Quick Start

Here's the basic structure of a Kupocast profile:

```lua
local kupo = require('kupocast')

-- 1. Define your configuration store
local store = kupo.Store({
  toggles = {
    jellyRing = false
  },
  cycles = {
    mode = { 'Default', 'Accuracy', 'Tank' }
  }
})

-- 2. Create your profile
local profile = kupo.Profile({
  store = store,
  display = { mode = '[m] Mode' },
  bind = { m = store.cycleMode }
})

-- 3. Define your gear sets
local sets = profile.Sets

sets.Idle = {
  Body = 'Vampire Cloak',
  Legs = 'Crimson Cuisses'
}

return profile
```

## Core Concepts

### Store Configuration

The `Store` is where you define all the dynamic state for your character:

```lua
local store = kupo.Store({
  -- Static pieces of state
  state = {
    me = 'Avesta',
  },

  -- Boolean toggles (On/Off)
  toggles = {
    jellyRing = false,
  },

  -- Cycling options (rotate through values)
  cycles = {
    mode = { 'Default', 'Accuracy', 'Tank', 'Zerg' },
    weapon = { 'Scythe', 'Great Sword', 'Great Axe', 'Club' },
  },

  -- Dynamic values from game state
  getters = {
    isSelfCast = function(state)
      return state.target.Name == state.me
    end,
  },
})
```

### Profile Setup

Connect your store to keybinds and display options:

```lua
local profile = kupo.Profile({
  store = store,
  display = {
    weapon = '[r] Weapon',        -- Shows current weapon in display
    mode = '[m] Mode',            -- Shows current mode
    jellyRing = '[j] Jelly Ring', -- Shows jelly ring state (On/Off)
  },
  bind = {
    r = store.cycleWeapon,     -- Press 'r' to cycle weapons
    m = store.cycleMode,       -- Press 'm' to cycle modes
    j = store.toggleJellyRing, -- Press 'j' to toggle jelly ring
  },
})
```

#### Events

You can subscribe to all of the LAC events by using the `:on` or `:once` methods:

```lua
profile:on('precast', function(action)
  kupo.log.info('Casting ' .. action.Name)
end)
```

These events essentially map to native LAC events/handlers

- `OnLoad` -> `profile:once('load', function() end)`
- `OnUnload` -> `profile:once('unload', function() end)`
- `HandleCommand` -> `profile:on('command', function(command, args) end)`
- `HandleDefault` -> `profile:on('default', function(player) end)`
- `HandleItem` -> `profile:on('item', function(item, target) end)`
- `HandleAbility` -> `profile:on('ability', function(ability, target) end)`
- `HandleWeaponskill` -> `profile:on('weaponskill', function(ws, target) end)`
- `HandlePrecast` -> `profile:on('precast', function(spell, target) end)`
- `HandleMidcast` -> `profile:on('midcast', function(spell, target) end)`
- `HandlePreshot` -> `profile:on('preshot', function(target), end)`
- `HandleMidshot` -> `profile:on('midshot', function(target), end)`


## Defining Gear Sets

### Basic Sets

Start with simple, static gear sets:

```lua
local sets = profile.Sets

sets.Resting = {
  Neck = 'Checkered Scarf',
  Ear1 = 'Magnetic Earring',
  Waist = 'Hierarch belt',
  Legs = "Baron's Slops",
}

sets.Weaponskill = {
  Head = 'Chs. Burgeonet +1',
  Neck = 'Peacock Amulet',
  Ear1 = 'Brutal Earring',
  Body = 'Hauberk',
}
```

### Combining Sets

Use `kupo.combine()` to build sets from other sets:

```lua
-- Define reusable components
local Haste = {
  Head = 'Homam Zucchetto',
  Hands = 'Homam Manopolas',
  Ring1 = 'Blitz Ring',
}

local DamageTaken = {
  Head = 'Darksteel Cap +1',
  Body = 'Dst. Harness +1',
  Hands = 'Dst. Mittens +1',
}

-- Combine them for specialized sets
sets.Engaged = kupo.combine(Haste, {
  Ammo = 'Bomb Core',
  Body = 'Hauberk',
  Back = "Forager's Mantle",
})

sets.Tank = kupo.combine(sets.Engaged, DamageTaken, {
  Neck = 'Parade Gorget',
  Waist = 'Warwolf Belt',
})
```

### Set Variations

Create multiple variations of sets using `map()` and `coalesce()`:

```lua
-- Create variations based on a single cycle
sets.Idle = sets:map('mode')
sets.Idle.Default = { Body = 'Vampire Cloak' }
sets.Idle.Tank = kupo.combine(DamageTaken, sets.Idle.Default)

-- Create variations based on multiple cycles (weapon × mode)
sets.Engaged = sets:coalesce('weapon', 'mode')

-- Define weapon variations
sets.Engaged.Scythe = { Main = 'Tredecim Scythe' }
sets.Engaged['Great Sword'] = { Main = 'Balmung' }

-- Define mode variations
sets.Engaged.Default = kupo.combine(Haste, { Body = 'Hauberk' })
sets.Engaged.Accuracy = kupo.combine(sets.Engaged.Default, {
  Head = 'Optical Hat',
  Ammo = 'Tiphia Sting',
})
```

### Gear Functions

Gear functions automatically receive the dependencies they need based on parameter names:

```lua
sets.Dark = {
  Ring2 = function(action, dayElement, player)
    local threshold = (action.Name == 'Aspir' and 71) or 86
    if dayElement == 'Dark' and player.MPP < threshold then
      return "Diabolos's Ring"
    end
    return 'Snow Ring'
  end,
}
```

**How it works**: The framework analyzes your function's parameter names and automatically injects the corresponding values. You only need to declare the dependencies you actually use - if you only need `player`, just use `function(player)`. This keeps your code clean and explicit about what data each piece of gear logic depends on.

Available dependencies include:
- `player` - Current player state
- `action` - Current action being performed
- `target` - Current target action is being performed on
- And any other values defined in your store `state`, `toggles`, `cycles` and `getters`

### Plugins

Extend functionality with plugins:

```lua
local AutoEquipPlugin = require('kupocast/plugins/autoequip')
local ConquestPlugin = require('kupocast/plugins/conquest')

local profile = kupo.Profile({
  plugins = { ConquestPlugin, AutoEquipPlugin },
  -- ... rest of config
})
```

### LockStyle Integration

Define your visual appearance separately from functional gear:

```lua
local profile = kupo.Profile({
  lockStyle = 'LockStyle',
  -- ... rest of config
})

sets.LockStyle = {
  Main = 'Tredecim Scythe',
  Body = 'Vampire Cloak',
  Hands = 'Homam Manopolas',
}
```

## Benefits

- **Less Code**: Declarative approach reduces boilerplate
- **More Readable**: Clear separation of concerns and intent
- **Maintainable**: Easy to modify and extend existing sets
- **Reusable**: Component-based design encourages code reuse
- **Flexible**: Handles simple static sets to complex conditional logic

## Getting Started

1. Install Kupocast in your Ashita addons directory
2. Copy one of the scripts from the examples directory as a starting point
3. Define your basic gear sets
4. Add variations using `map()` and `coalesce()`
5. Enhance with conditional logic where needed

The framework grows with you - start simple and add complexity only where you need it.
