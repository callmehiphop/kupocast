local _ = require('kupocast/libs/luadash')
local logger = gFunc.LoadFile('kupocast/src/logger')
local Profile = gFunc.LoadFile('kupocast/src/profile')
local Store = gFunc.LoadFile('kupocast/src/store')
local utils = gFunc.LoadFile('kupocast/src/utils')

return {
  Profile = Profile,
  Store = Store,

  log = logger,
  bind = _.bind,
  combine = utils.combine,
  equip = utils.equip,
  exec = utils.exec,

  enable = function(slots)
    return utils.disabled(slots, false)
  end,

  disable = function(slots)
    return utils.disabled(slots, true)
  end,
}
