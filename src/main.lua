-- Rafael Alcalde Azpiazu - 22 Apr 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local Json = require "libs.json.json"
local Gamestate = require "libs.hump.gamestate"

local Editor = require "main.client.editor"
local Menubar = require "main.client.widgets.menubar"
local FileChooser = require "main.client.widgets.filechooser"
local Newmap = require "main.client.widgets.newmap"
local WaitMessage = require "main.client.widgets.waitmessage"

local Resources = require "main.utilities.resources"
local Exporter = require "main.utilities.exporter"

-- Variables of the UI
local map_editor,bar_editor,dialog_editor
local map_conf = {}

local function reset()
  local w_min = math.max(map_editor:getWidth() + 20, 640)
  local h_min = math.max(40 + map_editor:getHeight() + 20, 400)
  map_editor:resize(w_min, h_min)
  love.window.setMode(w_min, h_min, {resizable = true, minwidth = w_min, minheight = h_min, centered = true})
end

local function closepop()
  dialog_editor = nil
end

local function newmap(r, q_r, q_c, c_r, c_c)
  map_conf.regions = r
  map_conf.q_rows, map_conf.q_cols = q_r, q_c
  map_conf.c_rows, map_conf.c_cols = c_r, c_c
  map_editor:newMap(q_r*c_r, q_c*c_c)
  map_editor._regions = nil
  bar_editor.openfile = true
  dialog_editor = nil
  reset()
  closepop()
end

local function openmap(path)
  local map_file = Resources.loadResource("json", path)
  map_conf.regions = map_file.regions
  map_conf.q_rows = map_file.q_rows
  map_conf.q_cols = map_file.q_cols
  map_conf.c_rows = map_file.c_rows
  map_conf.c_cols = map_file.c_cols
  map_editor:setMap(map_file.map)
  bar_editor.openfile = true
  Resources.saveConfiguration("editor", {lastOpened = path})
  reset()
  closepop()
end

local function savemap(path, name)
  local map = {
    regions = map_conf.regions,
    q_rows = map_conf.q_rows,
    q_cols = map_conf.q_cols,
    c_rows = map_conf.c_rows,
    c_cols = map_conf.c_cols,
    map = map_editor._map:getMap()
  }

  local fullpath = Resources.appendFiles(path, name) .. ".json"

  df = io.open(fullpath, "w+")
  df:write(Json.encode(map))
  df:flush()
  df:close()
  Resources.saveConfiguration("editor", {lastOpened = fullpath})
  closepop()
end

local function exportmap(path, name)
  local rows = map_editor._map.rows
  local columns = map_editor._map.cols
  local terrain = map_editor._map:getMap()
  local startpos = {}
  local file = Resources.appendFiles(path, name) .. ".txt"
  Exporter.export(file, name, rows, columns, terrain, startpos)
  closepop()
end

local function loadclingoresult()
  local path = Resources.appendFiles("resources", "result.json")
  local map = Resources.loadResource("json", path)
  map_editor:setMap(map.cells)
  map_editor:setRegions(map.regions, map_conf.c_rows, map_conf.c_cols)
  Resources.removeResource("json", path)
  closepop()
end

local function generatemap()
  local thread = love.thread.newThread(Resources.appendFiles("main", "client", "clingo_thread.lua"))
  local to = love.thread.getChannel("toClingo")
  local from = love.thread.getChannel("fromThread")
  to:push(map_conf.regions)
  to:push(map_conf.q_rows)
  to:push(map_conf.q_cols)
  to:push(map_conf.c_rows)
  to:push(map_conf.c_cols)
  thread:start()

  local value = from:demand()
  if value == "ok" then
    to:release()
    dialog_editor = WaitMessage(from, loadclingoresult)
  end
end

-- Loads and sets elements
function love.load()
  -- Creamos la interfaz del editor
  map_editor = Editor()
  bar_editor = Menubar(map_editor._map ~= nil)
  love.graphics.setBackgroundColor(0.9, 0.9, 0.9)

  -- Compruebo si existe una configuración ya del programa
  if Resources.existConfiguration("editor") then
    local conf = Resources.loadResource("conf", "editor")
    openmap(conf.lastOpened)
  end
end

-- Function for resize window
function love.resize(width, height)
  map_editor:resize(width, height)
end

function love.update(dt)
  local option = bar_editor:update(dt, dialog_editor and dialog_editor.isMouseFocused and dialog_editor:isMouseFocused())

  if dialog_editor then
    dialog_editor:update(dt)
  end

  if option == 1 then
    dialog_editor = Newmap(newmap, closepop)
  elseif option == 2 then
    dialog_editor = FileChooser("open", openmap, closepop)
  elseif option == 3 then
    dialog_editor = FileChooser("save", "new map", savemap, closepop)
  elseif option == 4 then
    dialog_editor = FileChooser("save", "exported", exportmap, closepop)
  elseif option == 5 then
    generatemap()
  end
end

function love.textinput(t)
  if dialog_editor and dialog_editor.textInput then dialog_editor:textInput(t) end
end

function love.wheelmoved(x, y)
  if dialog_editor and dialog_editor.wheelMoved then dialog_editor:wheelMoved(x, y) end
end

function love.keypressed(key)
  if dialog_editor and dialog_editor.keyPressed then dialog_editor:keyPressed(key) end
end

-- Triggered when the mouse is moved
function love.mousemoved(x, y, dx, dy, istouch)
  if not (dialog_editor and dialog_editor.isMouseFocused and dialog_editor:isMouseFocused()) then
    map_editor:mousemoved(x, y, dx, dy, istouch)
  end
end

-- Triggered when a button mouse is pressed
function love.mousepressed(x, y, button, istouch)
  if not (dialog_editor and dialog_editor.isMouseFocused and dialog_editor:isMouseFocused()) then
    map_editor:mousepressed(x, y, button, istouch)
  end
end

-- Triggered when a button mouse is released
function love.mousereleased(x, y, button, istouch)
  if not (dialog_editor and dialog_editor.isMouseFocused and dialog_editor:isMouseFocused()) then
    map_editor:mousereleased(x, y, button, istouch)
  end
end

-- Draw all elements in window
function love.draw()
  map_editor:draw()
  bar_editor:draw()

  if dialog_editor and dialog_editor.draw then
    dialog_editor:draw()
  end
end
