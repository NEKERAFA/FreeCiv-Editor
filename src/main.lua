-- Rafael Alcalde Azpiazu - 22 Apr 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local Gamestate = require "libs.hump.gamestate"
local Editor = require "main.client.editor"
local Menubar = require "main.client.widgets.menubar"
local FileChooser = require "main.client.widgets.filechooser"

-- This variable represents a UI map editor
local map_editor
local bar_editor
local dialog_editor

-- Loads and sets elements
function love.load()
  -- Creamos la interfaz del editor
  map_editor = Editor()
  bar_editor = Menubar()
  love.graphics.setBackgroundColor(0.9, 0.9, 0.9)
end

-- Function for resize window
function love.resize(width, height)
  map_editor:resize(width, height)
end

function love.update(dt)
  local option = bar_editor:update(dt)

  if dialog_editor then
    dialog_editor:update(dt)
  end

  if option == 2 then
    dialog_editor = FileChooser()
  elseif option == 3 then
    dialog_editor = FileChooser("save")
  end
end

function love.textinput(t)
  if dialog_editor then dialog_editor:textInput(t) end
end

function love.wheelmoved(x, y)
  if dialog_editor then dialog:wheelMoved(x, y) end
end

function love.keypressed(key)
  if dialog_editor then dialog:keyPressed(key) end
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
  bar_editor:draw()

  if dialog_editor then
    dialog_editor:draw()
  end
end
