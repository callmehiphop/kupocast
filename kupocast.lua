local _ = require('kupocast/libs/luadash')
local logger = require('kupocast/src/logger')
local Profile = require('kupocast/src/profile')
local Store = require('kupocast/src/store')
local utils = require('kupocast/src/utils')

return {
  Profile = Profile,
  Store = Store,

  log = logger,
  bind = _.bind,
  combine = utils.combine,
  disable = _.bind(utils.disabled, true),
  enable = _.bind(utils.disabled, false),
  exec = utils.exec,
}
