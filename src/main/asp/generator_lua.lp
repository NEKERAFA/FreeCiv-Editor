#script(lua)

local Json = require "libs.json.json"
local Matrix = require "main.model.matrix"
local Parser = require "main.utilities.parser"
local Constants = require "main.utilities.constants"

-- Función principal
function main(prog)
  local rows, cols, mat

  -- Carga los programas lógicos
  prog:load("main/asp/regions.lp")
  prog:load("main/asp/quadrants.lp")

  -- Obtiene el ancho y el alto de los cuadrantes
  q_rows = prog:get_const("q_rows").number
  q_cols = prog:get_const("q_cols").number
  -- Obtiene el ancho y el alto de las celdas
  c_rows = prog:get_const("c_rows").number
  c_cols = prog:get_const("c_cols").number
  -- Obtiene el número de regiones
  regions = prog:get_const("regions").number


  -- Inicializa una matriz
  mat = Matrix(q_rows*c_rows, q_cols*c_cols, Constants.MatrixType.STRING, Constants.CellType.WATER_CELL)

  -- Recorremos las regiones
  for i = 0, regions do
    io.write("____ Iteration " .. tostring(i) .. " ____\n")
    local parts = {}

    if i > 0 then
      prog:cleanup()
      table.insert(parts, {"generate", {i}})
    else
      table.insert(parts, {"base", {}})
    end

    -- Hace ground de la generación de regiones
    prog:ground(parts)
    -- Obtiene una solución para el programa lógico
    local solve = prog:solve({yield=true})
    -- Parsea la solución
    Parser.parseCells(solve, mat)
    -- Cierra la solución
    solve:close()
  end

  -- Serializamos la matriz
  serialize = Json.encode(mat:getTable())
  -- Escribimos la matriz
  tmp = io.open("resources/map.json", "w+")
  tmp:write(serialize)
  tmp:flush()
  tmp:close()
end

#end.
