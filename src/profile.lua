local _ = require('kupocast/libs/luadash')
local EventEmitter = require('kupocast/libs/events')
local Display = gFunc.LoadFile('kupocast/src/display')
local Input = gFunc.LoadFile('kupocast/src/input')
local log = gFunc.LoadFile('kupocast/src/logger')
local Store = gFunc.LoadFile('kupocast/src/store')

local Profile = {}
Profile.__index = Profile

setmetatable(Profile, {
  __index = EventEmitter,
  __call = function(config)
    return Profile:new(config)
  end,
})

function Profile:new(config)
  config = config or {}

  local profile = EventEmitter:new()
  setmetatable(profile, self)

  profile.store = config.store or Store:new()
  profile.Sets = config.sets or {}

  profile.OnLoad = _.bind(profile.emit, profile, 'load')
  profile.OnUnload = _.bind(profile._onunload, profile)
  profile.HandleCommand = _.bind(profile._oncommand, profile)
  profile.HandleDefault = _.bind(profile._ondefault, profile)
  profile.HandleAbility = _.bind(profile._onaction, profile, 'ability')
  profile.HandleWeaponskill = _.bind(profile._onaction, profile, 'weaponskill')
  profile.HandlePrecast = _.bind(profile._onaction, profile, 'spell', 'precast')
  profile.HandleMidcast = _.bind(profile._onaction, profile, 'spell', 'midcast')
  profile.HandleItem = _.bind(profile._onaction, profile, 'item')
  profile.HandlePreshot = _.bind(profile._onranged, profile, 'preshot')
  profile.HandleMidshot = _.bind(profile._onranged, profile, 'midshot')

  if config.bind then
    profile:_bindHotKeys(config.bind)
  end
  if config.display then
    profile:_createDisplay(config.display)
  end
  if config.lockStyle then
    profile:_setLockStyle(config.lockStyle)
  end

  return profile
end

function Profile._bindHotKeys(options)
  local input = Input:new(options)
  self:once('load', _.bind(input.bindAll, input))
  self:once('unload', _.bind(input.unbindAll, input))
  self:on('command', _.bind(input.invoke, input))
end

function Profile:_createDisplay(options)
  local display = Display:new(self.store, options)
  self:once('load', _.bind(display.start, display))
  self:once('unload', _.bind(display.destroy, display))
end

function Profile:_onaction(type, event)
  local action = gData.GetAction()
  local target = gData.GetActionTarget()
  self.store:unpack(type, action)
  self.store:unpack('target', target)
  self:emit(event or type, action, target)
end

function Profile:_oncommand(args)
  local cmd = table.remove(args, 1)
  self:emit('command', cmd, args)
end

function Profile:_ondefault()
  local player = gData.GetPlayer()
  self.store:unpack(player)
  self:emit('default', player)
end

function Profile._onranged(event)
  local target = gData.GetActionTarget()
  self.store:unpack('target', target)
  self:emit(event, target)
end

function Profile._onunload()
  self:emit('unload')
  self:removeAllListeners()
end

function Profile:_setLockStyle(set)
  self:once('load', function()
    ashita.tasks.once(2, function()
      utils.lockStyle(set)
    end)
  end)
end

function Profile:use(plugin, options)
  local status, err = pcall(plugin.install, self, options)
  if err then
    log.error('Unable to install ' .. plugin.name)
    log.error(err)
  else
    log.success(plugin.name .. ' loaded')
  end
end

return Profile
