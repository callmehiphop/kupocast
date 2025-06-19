local _ = require('kupocast/libs/luadash')
local equipment = require('kupocast/src/equipment')
local logger = require('kupocast/src/logger')
local Profile = require('kupocast/src/profile')
local Store = require('kupocast/src/store')
local utils = require('kupocast/src/utils')

return {
  log = logger,
  combine = equipment.combine,
  disable = _.bind(equipment.disabled, true),
  enable = _.bind(equipment.disabled, false),
  equip = _.bind(equipment.equipWith, gFunc.Equip),
  forceEquip = _.bind(equipment.equipWith, gFunc.ForceEquip),
  interimEquip = _.bind(equipment.equipWith, gFunc.InterimEquip),
  exec = utils.exec,
  Profile = Profile.new,
  Store = Store.new,
}
