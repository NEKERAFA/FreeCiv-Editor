-- Rafael Alcalde Azpiazu - 10 May 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

-- Este script llama al módulo de ASP y luego avisa a la interfaz de que ha acabado

local channel = love.thread.getChannel("generate")

-- Obtengo las constantes
local q_rows = channel:demand()
local q_cols = channel:demand()
local c_rows = channel:demand()
local c_cols = channel:demand()

-- Llamo a clingo
cmd = "cd src && clingo -c q_rows="..q_rows.." -c q_cols="..q_cols.." -c c_rows="..c_rows.." -c c_cols="..c_cols.." main/asp/generator_lua.lp"
print("> "..cmd)
ret, msg, n = os.execute(cmd)

if ret then
  channel:supply("finish")
end
