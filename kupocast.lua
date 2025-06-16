local _ = require('kupocast/libs/luadash')
local equipment = require('kupocast/src/equipment')
local logger = require('kupocast/src/logger')
local Profile = require('kupocast/src/profile')
local Store = require('kupocast/src/store')
local utils = require('kupocast/src/utils')

return {
  Profile = Profile,
  Store = Store,
  log = logger,
  combine = equipment.combine,
  disable = _.bind(equipment.disabled, true),
  enable = _.bind(equipment.disabled, false),
  equip = equipment.equip,
  equipInterim = equipment.equipInterim,
  exec = utils.exec,
}
