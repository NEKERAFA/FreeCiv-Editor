local Suit = require "libs.suit"
local Class = require "libs.hump.class"
local Lfs = require "lfs"

local GenerateMessage = {}
GenerateMessage.__index = GenerateMessage

function GenerateMessage:new (...)
  local args = {...}
  local obj = setmetatable({}, self)
  obj._onClose = args[1] or args.onClose
  obj._gui = Suit.new()
  obj._gui.theme = setmetatable({}, {__index = Suit.theme})
  obj._closed = false
  return obj
end

function GenerateMessage:update (dt)
  if not self._closed then
    local width, height = love.window.getMode()
    local x, y = width/2-120, height/2-55/2

    local green_button = {
          color = {
              normal  = {bg = {0, .7, .0}, fg = {1, 1, 1}},
              hovered = {bg = {0, .9, .0}, fg = {1, 1, 1}},
              active  = {bg = {1, .6,  0}, fg = {1, 1, 1}}
          }
    }
    local white_center_text = {
          color = {normal = {fg = {1, 1, 1}}},
          align = "center"
    }

    self._gui.layout:reset(x+5, y+5)
    self._gui:Label("The map cannot be generated.", Class.clone(white_center_text), self._gui.layout:col(120*2-10, 20))

    self._gui.layout:push(x+5, y+30)
    -- Botón para aceptar
    if self._gui:Button("Ok", green_button, self._gui.layout:col(80, 20)).hit then
      if self._onClose then
        self._onClose()
      end
      self._closed = true
    end
  end
end

function GenerateMessage:isMouseFocused ()
  return not self._closed
end

function GenerateMessage:draw ()
  if not self._closed then
    local width, height = love.window.getMode()
    local x, y = width/2-120, height/2-55/2

    love.graphics.setColor(0, 0, 0, .5)
    love.graphics.rectangle("fill", x, y, 260, 55, 5, 5)

    love.graphics.setColor(1, 1, 1)
    self._gui:draw()
  end
end

return setmetatable(GenerateMessage, {__call = GenerateMessage.new})
