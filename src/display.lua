local Fonts = require('fonts')
local _ = require('kupocast/libs/luadash')
local log = require('kupocast/src/logger')

local FONT_OPTIONS = {
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

function Display.green(text)
  return string.format('|cFF00FF00|%s|r', text)
end

function Display.red(text)
  return string.format('|cFFFF0000|%s|r', text)
end

function Display.new(store, fields)
  local display = setmetatable({}, Display)
  display.store = store
  display.fields = fields
  return display
end

function Display:destroy()
  ashita.events.unregister('d3d_present', 'kupo_display_cb')
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
  self.font = Fonts.new(FONT_OPTIONS)
  local update = _.bind(self.update, self)
  -- TODO: consider make cb name more dynamic?
  ashita.events.register('d3d_present', 'kupo_display_cb', update)
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
