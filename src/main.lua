-- Rafael Alcalde Azpiazu - 22 Apr 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local Lfs = require "lfs"

local Json = require "libs.json.json"
local Class = require "libs.hump.class"

local Editor = require "main.client.editor"
local Menubar = require "main.client.widgets.menubar"
local FileChooser = require "main.client.widgets.filechooser"
local Newmap = require "main.client.widgets.newmap"
local GenerateMap = require "main.client.widgets.generatemap"
local WaitMessage = require "main.client.widgets.waitmessage"
local GenerateMessage = require "main.client.widgets.generatemessage"

local Resources = require "main.utilities.resources"
local Exporter = require "main.utilities.exporter"

--- Variable global para saber si estamos en debug o no
DEBUG = false

--------------------------------------------------------------------------------

--- El módulo principal inicia y controla toda la aplicación general
-- @module Main
local Main = {
  usage = "freeciv_gen.lua [options]:\n" ..
          " -d, --debug\t\tEnables debugging logs.\n" ..
          " -o, --open <file.json>\t\tOpens a map file and loads it.\n" ..
          " -n, --new <rows> <columns>\tCreates a empty map.\n" ..
          " -g, --generate <>\n" ..
          " -h, --help\t\tPrints this message.",

  mapEditor = Editor(),
  mapConf = {},
  barEditor = Menubar(false),
  dialogEditor = nil,
  _generated = false
}

--- Inicia el módulo Main.
-- @param args Lista de argumentos pasados al intérprete.
function Main.init(args)
  -- Ponemos la semilla aleatoria con el tiempo que lleva LÖVE abierto
  love.math.setRandomSeed(love.timer.getTime())

  -- Compruebo los argumentos
  if #args > 0 then
    local arg = 1

    while arg <= #args do
      if args[arg]:find("-d") or args[arg]:find("--debug") then
        DEBUG = true
        arg = arg+1
      elseif args[arg]:find("-o") or args[arg]:find("--open") and arg+2 <= #args then
        Main._openMap(args[1])
        arg = arg+2
      elseif args[arg]:find("-n") or args[arg]:find("--new") and arg+3 <= #args then
        Main._newMap(tonumber(args[arg+1]), tonumber(args[arg+2]))
        arg = arg+3
      elseif args[1]:find("-g") or args[1]:find("--generate") and arg+8 <= #args then
        Main._generateMap(tonumber(args[2]), tonumber(args[3]),
          tonumber(args[4]), tonumber(args[5]), tonumber(args[6]),
          tonumber(args[7]))
        arg = arg+7
      else
        print(Main.usage)
        os.exit(1)
      end
    end

    return
  end

  -- Compruebo si existe una configuración ya del programa
  if Resources.existConfiguration("editor") then
    local conf = Resources.loadResource("conf", "editor")
    Main._openMap(conf.lastOpened)
  end
end

--- Reinicia el tamaño del editor.
function Main._resetEditor()
  local w_min = math.max(Main.mapEditor:getWidth() + 20, 640)
  local h_min = math.max(40 + Main.mapEditor:getHeight() + 20, 400)
  Main.mapEditor:resize(w_min, h_min)
  love.window.setMode(w_min, h_min, {resizable = true, minwidth = w_min, minheight = h_min, centered = true})
  Main._generated = false
end

--- Cierra los diálogos pendientes.
function Main._closePop()
  Main.dialogEditor = nil
end

--- Crea un mapa vacío.
-- @param rows Número de filas del nuevo mapa.
-- @param cols Numero de columnas del nuevo mapa.
function Main._newMap(rows, cols)
  Main.mapEditor:newMap(rows, cols)
  Main.mapEditor:restartRestrictions()
  Main.mapEditor._regions = nil
  Main.mapEditor._startpos = nil
  Main.barEditor._fileopened = true
  Main.dialogEditor = nil
  Main.mapConf = {}
  Main._resetEditor()
  Main._closePop()
end

--- Abre un mapa en formato json guardado anteriormente por la aplicación.
-- @param path Ruta del archivo a abrir.
function Main._openMap(path)
  local map_file = Resources.loadResource("json", path)
  Main.mapConf = map_file.conf
  Main.mapEditor:setMap(map_file.map)
  Main.mapEditor:setRegions(map_file.regions, map_file.conf.q_rows, map_file.conf.q_cols)
  Main.mapEditor:setSpawns(map_file.startpos)
  Main.mapEditor:restartRestrictions()
  Main.barEditor._fileopened = true
  Resources.saveConfiguration("editor", {lastOpened = path})
  Main._resetEditor()
  Main._closePop()
end

--- Guarda el mapa actual en formato json para poder seguir editándolo luego.
-- @param path Ruta del archivo a guardar.
-- @param name Nombre del archivo.
function Main._saveMap(path, name)
  local map = {
    map = Main.mapEditor._map:getMap(),
    regions = Main.mapEditor._regions:getMap(),
    startpos = Main.mapEditor._startpos,
    conf = Main.mapConf
  }

  local fullpath = Resources.appendFolders(path, name .. ".json")

  df = io.open(fullpath, "w+")
  df:write(Json.encode(map))
  df:flush()
  df:close()
  Resources.saveConfiguration("editor", {lastOpened = fullpath})
  Main._closePop()
end

--- Exporta el mapa actual a un formato reconocible por FreeCiv.
-- @param path Ruta del archivo a guardar.
-- @param name Nombre del archivo.
function Main._exportMap(path, name)
  local rows = Main.mapEditor._map.rows
  local columns = Main.mapEditor._map.cols
  local terrain = Main.mapEditor._map:getMap()
  local startpos = Main.mapEditor._startpos
  local file = Resources.appendFolders(path, name .. ".txt")
  Exporter.export(file, name, rows, columns, terrain, startpos)
  Main._closePop()
end

--- Obtiene un resultado de la generación de clingo y la carga como mapa nuevo
function Main._loadClingoResult()
  local path = Resources.appendFolders("resources", "result.json")
  if Lfs.attributes(path) == nil then
    Main._closePop()
    Main.dialogEditor = GenerateMessage(Main._closePop)
  else
    local map = Resources.loadResource("json", path)
    Main.mapEditor:setMap(map.terrain)
    Main.mapEditor:setRegions(map.regions, Main.mapConf.c_rows, Main.mapConf.c_cols)
    Main.mapEditor:setSpawns(map.startpos)
    Resources.removeResource("json", path)
    os.remove(path)
    Main._closePop()
    Main._generated = true
  end
end

--- Llama al módulo de Clingo para generar un nuevo mapa.
-- @param regions Número de islas a generar.
-- @param land Porcentaje de tierra a generar.
-- @param terrain Porcentaje del tamaño de los biomas.
-- @param size_mountains Longitud de las coordilleras.
-- @param width_mountains Ancho de las coordilleras.
function Main._generateMap(regions, land, terrain, size_mountains, width_mountains, players)
  Main.mapEditor:setRestrictions()

  -- Primero obtengo las divisiones enteras
  local div_rows = math.floor(math.sqrt(Main.mapEditor._map.rows) - 1)
  local div_cols = math.floor(math.sqrt(Main.mapEditor._map.cols) - 1)

  while Main.mapEditor._map.rows % div_rows ~= 0 do
    div_rows = div_rows + 1
  end

  while Main.mapEditor._map.cols % div_cols ~= 0 do
    div_cols = div_cols + 1
  end

  local result_rows = math.floor(Main.mapEditor._map.rows / div_rows)
  local result_cols = math.floor(Main.mapEditor._map.cols / div_cols)

  -- Relleno con la información del pop-up
  Main.mapConf.regions = regions
  Main.mapConf.q_rows = math.min(div_rows, result_rows)
  Main.mapConf.q_cols = math.min(div_cols, result_cols)
  Main.mapConf.c_rows = math.max(div_rows, result_rows)
  Main.mapConf.c_cols = math.max(div_cols, result_cols)
  Main.mapConf.land = land
  Main.mapConf.terrain = terrain
  Main.mapConf.size_mountains = size_mountains
  Main.mapConf.width_mountains = width_mountains
  Main.mapConf.players = players

  -- Hago modificaciones aleatorias en las variables para generar mapas distintos
  if Main._generated and not Main.mapEditor._modified_map.update then
    Main.mapConf.land = math.max(Main.mapConf.land + love.math.random(-20, 20), 10)
    Main.mapConf.terrain = math.max(Main.mapConf.terrain + love.math.random(-20, 20), 10)
    Main.mapConf.size_mountains = math.max(Main.mapConf.size_mountains + love.math.random(-2, 2), 2)
    Main.mapConf.width_mountains = math.max(Main.mapConf.width_mountains + love.math.random(-2, 2), 1)
  end

  local thread = love.thread.newThread(Resources.appendFolders("main", "client", "clingo_thread.lua"))
  local to = love.thread.getChannel("toClingo")
  local from = love.thread.getChannel("fromThread")
  to:push(DEBUG)
  to:push(Main.mapConf.regions)
  to:push(Main.mapConf.q_rows)
  to:push(Main.mapConf.q_cols)
  to:push(Main.mapConf.c_rows)
  to:push(Main.mapConf.c_cols)
  to:push(Main.mapConf.land)
  to:push(Main.mapConf.terrain)
  to:push(Main.mapConf.size_mountains)
  to:push(Main.mapConf.width_mountains)
  to:push(Main.mapConf.players)
  thread:start()

  local value = from:demand()
  if value == "ok" then
    to:release()
    Main.dialogEditor = WaitMessage(from, Main._loadClingoResult)
  end
end

--- Función que se llama cada vez que se actualiza la interfaz.
-- @param dt Tiempo que ha pasado desde la última vez que se llamó al update.
function Main.update(dt)
  local on_dialog = false

  -- Si hay un pop-up, se actualiza
  if Main.dialogEditor then
    Main.dialogEditor:update(dt)

    if Main.dialogEditor and Main.dialogEditor.isMouseFocused then
      on_dialog = Main.dialogEditor:isMouseFocused()
    end
  end

  -- Actualizamos la barra de herramientas
  local option = Main.barEditor:update(dt, on_dialog)

  -- Comprobamos la opción pulsada en la barra de herramientas
  if Main.dialogEditor == nil then
    if option == 1 then
      Main.dialogEditor = Newmap(Main._newMap, Main._closePop)
    elseif option == 2 then
      Main.dialogEditor = FileChooser("open", Main._openMap, Main._closePop)
    elseif option == 3 then
      Main.dialogEditor = FileChooser("save", "new map", Main._saveMap, Main._closePop)
    elseif option == 4 then
      Main.dialogEditor = FileChooser("save", "exported", Main._exportMap, Main._closePop)
    elseif option == 5 then
      if not Main._generated then
        Main.dialogEditor = GenerateMap(Main._generateMap, Main._closePop)
      else
        Main._generateMap(Main.mapConf.regions, Main.mapConf.land,
          Main.mapConf.terrain, Main.mapConf.size_mountains,
          Main.mapConf.width_mountains, Main.mapConf.players)
      end
    end
  end

  -- Si no hay un diálogo delante, actualizamos el editor
  if not on_dialog then
    Main.mapEditor:update(dt)
  end
end

--- Dibuja la interfaz del programa principal.
function Main.draw()
  Main.mapEditor:draw()
  Main.barEditor:draw()

  if Main.dialogEditor and Main.dialogEditor.draw then
    Main.dialogEditor:draw()
  end
end

--- Función que se llama cada vez que hay una entrada de texto.
-- @param t Texto a añadir.
function Main.textInput(t)
  if Main.dialogEditor and Main.dialogEditor.textInput then
    Main.dialogEditor:textInput(t)
  end
end

--- Función que se llama cada vez que se mueve la rueda del ratón.
-- @param dx Cantidad de movimiento en el eje x de la rueda.
-- @param dy Cantidad de movimiento en el eje y de la rueda.
function Main.wheelMoved(dx, dy)
  if Main.dialogEditor and Main.dialogEditor.wheelMoved then
    Main.dialogEditor:wheelMoved(dx, dy)
  end
end

--- Función que se llama cada vez que se presiona una tecla en el ratón.
-- @param key Tecla presionada.
function Main.keyPressed(key)
  if Main.dialogEditor and Main.dialogEditor.keyPressed then
    Main.dialogEditor:keyPressed(key)
  end
end

--- Función que se llama cada vez que se mueve el ratón.
-- @param x Posición del ratón en el eje x de la pantalla.
-- @param y posición del ratón en el eje y de la pantalla.
-- @param dx Cantidad de movimiento en el eje x del ratón.
-- @param dy Cantidad de movimiento en el eje y del raton.
-- @param istouch True si es un movimiento táctil.
function Main.mouseMoved(x, y, dx, dy, istouch)
  if not (Main.dialogEditor and Main.dialogEditor.isMouseFocused and Main.dialogEditor:isMouseFocused()) then
    Main.mapEditor:mousemoved(x, y, dx, dy, istouch)
  end
end

--- Función que se llama cada vez que se pulsa un botón en el ratón.
-- @param x Posición del ratón en el eje x de la pantalla.
-- @param y posición del ratón en el eje y de la pantalla.
-- @param buttom Botón pulsado en el ratón.
-- @param istouch True si es una pulsación táctil.
function Main.mousePressed(x, y, button, istouch)
  if not (Main.dialogEditor and Main.dialogEditor.isMouseFocused and Main.dialogEditor:isMouseFocused()) then
    Main.mapEditor:mousepressed(x, y, button, istouch)
  end
end

--------------------------------------------------------------------------------

--- En esta parte están las funciones propias del motor LÖVE.
-- @section Love2D

--- Carga las variables y assets usados por el programa principal.
function love.load(args)
  -- Seteamos el color de fondo
  love.graphics.setBackgroundColor(0.9, 0.9, 0.9)
  -- Cargamos el módulo principal
  Main.init(args)
end

--- Función que se llama al redimensionar una ventana.
function love.resize(width, height)
  Main.mapEditor:resize(width, height)
end

-- Función que se llama en cada actualización de frame.
-- @param dt Tiempo que ha pasado desde la última vez que se llamó al update.
function love.update(dt)
  Main.update(dt)
end

--- Función que se llama cada vez que hay una entrada de texto.
-- @param t Texto a añadir.
function love.textinput(t)
  Main.textInput(t)
end

--- Función que se llama cada vez que se mueve la rueda del ratón.
-- @param dx Cantidad de movimiento en el eje x de la rueda.
-- @param dy Cantidad de movimiento en el eje y de la rueda.
function love.wheelmoved(x, y)
  Main.wheelMoved(x, y)
end

--- Función que se llama cada vez que se presiona una tecla en el ratón.
-- @param key Tecla presionada.
function love.keypressed(key)
  Main.keyPressed(key)
end

--- Función que se llama cada vez que se mueve el ratón.
-- @param x Posición del ratón en el eje x de la pantalla.
-- @param y posición del ratón en el eje y de la pantalla.
-- @param dx Cantidad de movimiento en el eje x del ratón.
-- @param dy Cantidad de movimiento en el eje y del raton.
-- @param istouch True si es un movimiento táctil.
function love.mousemoved(x, y, dx, dy, istouch)
  Main.mouseMoved(x, y, dx, dy, istouch)
end

--- Función que se llama cada vez que se pulsa un botón en el ratón.
-- @param x Posición del ratón en el eje x de la pantalla.
-- @param y posición del ratón en el eje y de la pantalla.
-- @param buttom Botón pulsado en el ratón.
-- @param istouch True si es una pulsación táctil.
function love.mousepressed(x, y, button, istouch)
  Main.mousePressed(x, y, button, istouch)
end

--- Función que se llama en cada frame para dibujar en pantalla
function love.draw()
  Main.draw()
end
