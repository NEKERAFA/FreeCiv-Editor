-- Rafael Alcalde Azpiazu - 22 Apr 2018
-- Facultade de Informática da Coruña - Universidade da Coruña
--
-- Main program

local editor = require "main.client.editor"

-- Loads and sets elements
function love.load()
  editor_gui = editor:new({rows = 10, cols = 10, tiles_size = 30})
  local width_map = editor_gui:getWidth()
  local height_map = editor_gui:getHeight()
  love.window.setMode(width_map + 20, height_map + 20, {resizable = true, minwidth = width_map, minheight = height_map})
  love.graphics.setBackgroundColor(0.9, 0.9, 0.9)
end

-- Function for resize window
function love.resize(width, height)
  -- Gets the size of the map
  local width_map = editor_gui:getWidth()
  local height_map = editor_gui:getHeight()
  -- Calculates offset
  local x_offset = math.floor((width - width_map) / 2)
  local y_offset = math.floor((height - height_map) / 2)
  -- Sets offset in the editor
  editor_gui.offset = {x = x_offset, y = y_offset}
end

-- Function triggered when the mouse is moved
function love.mousemoved(x, y, dx, dy, istouch)
  editor_gui:mousemoved(x, y, dx, dy, istouch)
end

-- Function triggered when the mouse is pressed
function love.mousepressed(x, y, button, istouch)
  editor_gui:mousepressed(x, y, button, istouch)
end

-- Draw all elements in window
function love.draw()
  editor_gui:draw()
end
