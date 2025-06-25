local _ = require('kupocast/libs/luadash')
local EventEmitter = require('kupocast/libs/events')
local Display = require('kupocast/src/display')
local Injector = require('kupocast/src/injector')
local Input = require('kupocast/src/input')
local log = require('kupocast/src/logger')
local SetTable = require('kupocast/src/sets/table')
local Store = require('kupocast/src/store')
local utils = require('kupocast/src/utils')

local Profile = {}
setmetatable(Profile, { __index = EventEmitter })
Profile.__index = Profile

function Profile.new(config)
  config = config or {}

  local profile = EventEmitter.new()
  setmetatable(profile, Profile)

  profile.store = config.store or Store.new()
  profile.injector = Injector.new(profile.store)
  profile.Sets = SetTable.new(profile.injector)

  profile.OnLoad = _.bind(profile._onload, profile)
  profile.OnUnload = _.bind(profile._onunload, profile)
  profile.HandleCommand = _.bind(profile._oncommand, profile)
  profile.HandleDefault = _.bind(profile._ondefault, profile)
  profile.HandleAbility = _.bind(profile._onaction, profile, 'ability')
  profile.HandleWeaponskill = _.bind(profile._onaction, profile, 'weaponskill')
  profile.HandlePrecast = _.bind(profile._onaction, profile, 'precast')
  profile.HandleMidcast = _.bind(profile._onaction, profile, 'midcast')
  profile.HandleItem = _.bind(profile._onaction, profile, 'item')
  profile.HandlePreshot = _.bind(profile._onranged, profile, 'preshot')
  profile.HandleMidshot = _.bind(profile._onranged, profile, 'midshot')

  if not _.isEmpty(config.plugins) then
    profile:_installPlugins(config.plugins)
  end
  if config.lockStyle then
    profile:_setLockStyle(config.lockStyle)
  end
  if not _.isEmpty(config.macros) then
    profile:_setMacros(config.macros)
  end
  if not _.isEmpty(config.display) then
    profile:_createDisplay(config.display)
  end
  if not _.isEmpty(config.bind) then
    profile:_bindHotKeys(config.bind)
  end
  if not _.isEmpty(config.watch) then
    profile:_watch(config.watch)
  end

  return profile
end

function Profile:_bindHotKeys(options)
  local input = Input.new(options)
  self:once('load', _.bind(input.bindAll, input))
  self:once('unload', _.bind(input.unbindAll, input))
  self:on('command', _.bind(input.invoke, input))
end

function Profile:_createDisplay(options)
  local display = Display.new(self.store, options)
  self:once('load', _.bind(display.start, display))
  self:once('unload', _.bind(display.destroy, display))
end

function Profile:_installPlugins(plugins)
  _.forEach(plugins, function(plugin)
    local options
    if #plugin == 2 then
      plugin, options = plugin[1], plugin[2]
    end
    self:use(plugin, options)
  end)
end

function Profile:_onaction(event)
  local action = gData.GetAction()
  local target = gData.GetActionTarget()
  self.store.action = action
  self.store.target = target
  self:emit(event, action, target)
end

function Profile:_oncommand(args)
  local cmd = table.remove(args, 1)
  self:emit('command', cmd, args)
end

function Profile:_ondefault()
  local player = gData.GetPlayer()
  self.store.player = player
  self:emit('default', player)
end

function Profile:_onload()
  self:emit('load')
end

function Profile:_onranged(event)
  local target = gData.GetActionTarget()
  self.store.target = target
  self:emit(event, target)
end

function Profile:_onunload()
  self:emit('unload')
  self:removeAllListeners()
end

function Profile:_setLockStyle(set)
  self:once('load', function()
    ashita.tasks.once(2, function()
      if _.isNumber(set) then
        return utils.exec('/lockstyleset %d', set)
      end
      if _.isString(set) then
        set = self.Sets[set]
      end
      if not _.isTable(set) then
        return log.error('Unable to lock style with', type(set))
      end
      gFunc.LockStyle(set)
    end)
  end)
end

function Profile:_setMacros(options)
  self:once('load', function()
    if options.book then
      utils.exec('/macro book %d', options.book)
    end
    if options.set then
      utils.exec('/macro set %d', options.set)
    end
  end)
end

function Profile:_watch(watchers)
  _.forEach(watchers, function(watcher, key)
    self.store:watch(key, watcher)
  end)
end

function Profile:use(plugin, options)
  local success, result = pcall(plugin.install, self, options)
  if success then
    log.success(plugin.name, 'loaded')
    return result
  end
  log.error('Unable to install', plugin.name)
  log.error(result)
end

return Profile
