local Fonts = require('fonts')
local _ = require('kupocast/libs/luadash')
local log = require('kupocast/src/logger')

local DEFAULT_FONT = {
  visible = true,
  font_family = 'Consolas',
  font_height = 13,
  color = 0xFFFFFFFF,
  color_outline = 0xFF000000,
  bold = true,
  draw_flags = 0x10,
  position_x = 30,
  position_y = 400,
}

local Display = {}

Display.__index = Display

function Display.red(text)
  return string.format('|cFF00FF00|%s|r', text)
end

function Display.green(text)
  return string.format('|cFFFF0000|%s|r', text)
end

function Display:new(config)
  local display = setmetatable(self, Display)
  display.store = config.store
  display.fields = config.fields
  display.callback = config.callback or 'kupocast_display_cb'
  display.fontOptions = _.assign({}, DEFAULT_FONT, config.font or {})
  return display
end

function Display:destroy()
  ashita.events.unregister('d3d_present', self.callback)
  if self.font then
    self.font:destroy()
    self.font = nil
  end
end

-- hmmm should the store transform true/false into on/off?
function Display:getFieldValue(key)
  local value = self.store[key]
  if not value then
    return Display.red('Off')
  end
  if _.isBoolean(value) then
    value = 'On'
  end
  return Display.green(value)
end

function Display:start()
  if self.font then
    return log.warn('Display already started')
  end
  self.font = Fonts.new(self.fontOptions)
  local update = _.bind(Display.update, self)
  ashita.events.unregister('d3d_present', self.callback, update)
end

function Display:update()
  local state = {}
  _.forEach(self.fields, function(label, key)
    local field = string.format('%s: %s', label, self:getFieldValue(key))
    table.insert(state, field)
  end)
  self.font.text = _.join(state, '\n')
end

return Display
