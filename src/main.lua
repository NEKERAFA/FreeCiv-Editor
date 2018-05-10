-- Rafael Alcalde Azpiazu - 22 Apr 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local Gamestate = require "libs.hump.gamestate"
local Config = require "main.client.config"

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(Config)
end

--[[
local Editor = require "main.client.editor"

-- This variable represents a UI map editor
local map_editor
local gui

-- Loads and sets elements
function love.load()
  -- Creamos la interfaz del editor
  map_editor = Editor({rows = 10, cols = 10, tiles_size = 30})
  -- Obtenemos el alto y ancho
  local width_map = map_editor:getWidth()
  local height_map = map_editor:getHeight()
  -- Cambiamos el tamaño de ventana
  love.window.setMode(width_map + 20, height_map + 20, {resizable = true, minwidth = width_map, minheight = height_map})
  love.graphics.setBackgroundColor(0.9, 0.9, 0.9)
end

-- Function for resize window
function love.resize(width, height)
  -- Gets the size of the map
  local width_map = map_editor:getWidth()
  local height_map = map_editor:getHeight()

  -- Calculates offset
  local x_offset = math.floor((width - width_map) / 2)
  local y_offset = math.floor((height - height_map) / 2)

  -- Sets offset in the editor
  map_editor.offset = {x = x_offset, y = y_offset}
end

-- Triggered when the mouse is moved
function love.mousemoved(x, y, dx, dy, istouch)
  map_editor:mousemoved(x, y, dx, dy, istouch)
end

-- Triggered when a button mouse is pressed
function love.mousepressed(x, y, button, istouch)
  map_editor:mousepressed(x, y, button, istouch)
end

-- Triggered when a button mouse is released
function love.mousereleased(x, y, button, istouch)
  map_editor:mousereleased(x, y, button, istouch)
end

-- Draw all elements in window
function love.draw()
  map_editor:draw()
end
]]
