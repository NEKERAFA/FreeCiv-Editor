-- Rafael Alcalde Azpiazu - 10 May 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

-- Este script llama al módulo de ASP y luego avisa a la interfaz de que ha acabado

local timer = require("love.timer")
local math = require("love.math")

-- Defines el valor máximo de dos números
local function max(a, b) if a > b then return a end return b end

-- Ponemos la semilla aleatoria con el tiempo que lleva LÖVE abierto
math.setRandomSeed(timer.getTime())

-- Obtenemos los canales de los threads
local to = love.thread.getChannel("toClingo")
local from = love.thread.getChannel("fromThread")

-- Obtengo las constantes
local debug           = to:demand()
local regions         = to:demand()
local q_rows          = to:demand()
local q_cols          = to:demand()
local c_rows          = to:demand()
local c_cols          = to:demand()
local land            = to:demand()
local terrain         = to:demand()
local size_mountains  = to:demand()
local width_mountains = to:demand()
from:push("ok")

-- Hago modificaciones aleatorias en las variables para generar mapas distintos
land = max(land + math.random(-30, 30), 10)
terrain = max(terrain + math.random(-30, 30), 10)
size_mountains = max(size_mountains + math.random(-2, 2), 2)
width_mountains = max(width_mountains + math.random(-2, 2), 1)

-- Llamo a clingo
cmd = "clingo -c regions=" .. regions ..  " -c q_rows=" .. q_rows ..
      " -c q_cols=" .. q_cols .. " -c c_rows=" .. c_rows ..
      " -c c_cols=" .. c_cols .. " -c land=" .. land ..
      " -c terrain=" .. terrain .. " -c size_mountains=" .. size_mountains ..
      " -c width_mountains=" .. width_mountains .. " "

if DEBUG then
  cmd = cmd .. "-c debug=1 "
end
cmd = cmd .. "main/asp/generator.lp"
print("> " .. cmd)
ret, msg, n = os.execute(cmd)

-- Una vez termina se lo comunico a la interfaz
if ret then
  from:push("finish")
else

  error(msg)
end
