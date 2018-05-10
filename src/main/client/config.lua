-- Rafael Alcalde Azpiazu - 10 May 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local Suit = require "libs.suit"
local Json = require "libs.json.json"
local Gamestate = require "libs.hump.gamestate"
local Editor = require "main.client.editor"
local Map = require "main.model.map"

-- Este módulo crea una interfaz para configurar el generador
local Config = {
  -- Inicia el módulo
  enter = function(self, previous)
    -- Texto que sale en los inputs
    self._q_rows_text = {text = "3"}
    self._q_cols_text = {text = "3"}
    self._c_rows_text = {text = "2"}
    self._c_cols_text = {text = "2"}
  end,

  -- Actualiza la interfaz
  update = function(self, dt)
    -- Para comprobar si se introducen elementos que no son números
    local nan_input = false

    -- Mostramos los inputs del tamaño de la región
    Suit.layout:reset(80, 70)
    Suit.Label("Size of regions: ", {align = "left"}, Suit.layout:col(140, 20))
    if tonumber(self._q_rows_text.text) == nil then
      Suit.Input(self._q_rows_text, {color = {normal = {bg = {1, 0.25, 0.25}, fg = {1, 1, 1}}}}, Suit.layout:col(20, 20))
      nan_input = true
    else
      Suit.Input(self._q_rows_text, {color = {normal = {bg = {1, 1, 1}, fg = {0.25, 0.25, 0.25}}}}, Suit.layout:col(20, 20))
    end
    Suit.Label("x", Suit.layout:col(20, 20))
    if tonumber(self._q_cols_text.text) == nil then
      Suit.Input(self._q_cols_text, {color = {normal = {bg = {1, 0.25, 0.25}, fg = {1, 1, 1}}}}, Suit.layout:col(20, 20))
      nan_input = true
    else
      Suit.Input(self._q_cols_text, {color = {normal = {bg = {1, 1, 1}, fg = {0.25, 0.25, 0.25}}}}, Suit.layout:col(20, 20))
    end

    -- Mostramos los inputs del tamaño de los cuadrantes
    Suit.layout:push(80, 100)
    Suit.Label("Size of quadrants: ", {align = "left"}, Suit.layout:col(140, 20))
    if tonumber(self._c_rows_text.text) == nil then
      Suit.Input(self._c_rows_text, {color = {normal = {bg = {1, 0.25, 0.25}, fg = {1, 1, 1}}}}, Suit.layout:col(20, 20))
      nan_input = true
    else
      Suit.Input(self._c_rows_text, {color = {normal = {bg = {1, 1, 1}, fg = {0.25, 0.25, 0.25}}}}, Suit.layout:col(20, 20))
    end
    Suit.Label("x", Suit.layout:col(20, 20))
    if tonumber(self._c_cols_text.text) == nil then
      Suit.Input(self._c_cols_text, {color = {normal = {bg = {1, 0.25, 0.25}, fg = {1, 1, 1}}}}, Suit.layout:col(20, 20))
      nan_input = true
    else
      Suit.Input(self._c_cols_text, {color = {normal = {bg = {1, 1, 1}, fg = {0.25, 0.25, 0.25}}}}, Suit.layout:col(20, 20))
    end

    -- Comprobamos que se hayan introducido números en los campos de texto
    if nan_input then
      Suit.layout:push(80, 130)
      Suit.Label("Must be a number", {color = {normal  = {fg = {255, 0, 0}}}, align = "left"}, Suit.layout:row(150, 20))
    end

    -- Botón para generar el mundo
    Suit.layout:push(220, 130)
    if Suit.Button("Ok", Suit.layout:row(60, 20)).hit and not nan_input then
      self:callThread()
    end
  end,

  -- Llama al thread y espera a que se complete
  callThread = function(self)
    local thread = love.thread.newThread("main/client/generator.lua")
    local channel = love.thread.getChannel("generate")

    -- Iniciamos el thread
    thread:start()

    -- Le enviamos la información
    channel:supply(tonumber(self._q_rows_text.text))
    channel:supply(tonumber(self._q_cols_text.text))
    channel:supply(tonumber(self._c_rows_text.text))
    channel:supply(tonumber(self._c_rows_text.text))
    -- Limpiamos el canal
    channel:clear()

    -- Esperamos a una respuesta
    local ret = channel:demand()

    -- Si es un string, es que ha terminado bien y podemos cargar el editor
    if type(ret) == "string" then
      local serialize = love.filesystem.read("resources/map.json")
      local data = Json.decode(serialize)
      local map = Map(1, 1)
      map:setMap(data)
      love.window.setMode(map.rows*30+20, map.cols*30+20, {resizable = true, minwidth = map.rows*30, minheight = map.cols*30})
      Gamestate.switch(Editor, {map = map, tiles_size = 30})
    else
      error("Error to generate map: " .. ret[0] .. ": " .. ret[1])
    end
  end,

  -- Lee el texto introducido
  textinput = function(self, t)
      Suit.textinput(t)
  end,

  -- Lee la tecla pulsada
  keypressed = function(self, key)
      Suit.keypressed(key)
  end,

  -- Dibuja la interfaz
  draw = function(self)
    Suit.draw()
  end
}

return Config
