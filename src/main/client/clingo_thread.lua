-- Rafael Alcalde Azpiazu - 10 May 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

-- Este script llama al módulo de ASP y luego avisa a la interfaz de que ha acabado

local to = love.thread.getChannel("toClingo")
local from = love.thread.getChannel("fromThread")

-- Obtengo las constantes
local regions = to:demand()
local q_rows = to:demand()
local q_cols = to:demand()
local c_rows = to:demand()
local c_cols = to:demand()
from:push("ok")

-- Llamo a clingo
cmd = "clingo -c regions=" .. regions .. " -c q_rows=" .. q_rows ..
      " -c q_cols=" .. q_cols .. " -c c_rows=" .. c_rows .. " -c c_cols=" ..
      c_cols .. " main/asp/map_lua.lp"
print("> " .. cmd)
ret, msg, n = os.execute(cmd)

-- Una vez termina se lo comunico a la interfaz
if ret then
  from:push("finish")
else

  error(msg)
end
