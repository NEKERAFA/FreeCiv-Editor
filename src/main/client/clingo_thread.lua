-- Rafael Alcalde Azpiazu - 10 May 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

-- Este script llama al módulo de ASP y luego avisa a la interfaz de que ha acabado

local timer = require("love.timer")

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
local players         = to:demand()
from:push("ok")

-- Llamo a clingo
cmd = "clingo -c regions=" .. regions ..  " -c q_rows=" .. q_rows ..
      " -c q_cols=" .. q_cols .. " -c c_rows=" .. c_rows ..
      " -c c_cols=" .. c_cols .. " -c land=" .. land ..
      " -c terrain=" .. terrain .. " -c size_mountains=" .. size_mountains ..
      " -c width_mountains=" .. width_mountains .. " -c players=" .. players ..
      " "

if debug then
  cmd = cmd .. "-c debug=1 "
end
cmd = cmd .. "main/asp/generator.lp"
print("> " .. cmd)
os.execute(cmd)

-- Una vez termina se lo comunico a la interfaz
from:push("finish")
