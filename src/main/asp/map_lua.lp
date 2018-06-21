#script(lua)

local Json = require "libs.json.json"
local Matrix = require "main.model.matrix"
local Parser = require "main.utilities.parser"
local Constants = require "main.utilities.constants"

-- Función principal
function main(prog)
  local r_rows, r_cols, q_rows, q_cols, regions
  local mat

  -- Carga el programa lógico
  prog:load("main/asp/create_regions.lp")

  -- Obtiene el ancho y el alto de los cuadrantes
  q_rows = prog:get_const("q_rows").number
  q_cols = prog:get_const("q_cols").number
  -- Obtiene el ancho y el alto de las celdas
  c_rows = prog:get_const("c_rows").number
  c_cols = prog:get_const("c_cols").number
  -- Obtiene el número de regiones
  regions = prog:get_const("regions").number

  -- Hace grounding del programa lógico
  prog:ground({{"base", {}}})
  -- Obtengo un manejador de la solución
  local handle = prog:solve({yield=true})
  -- Variable para guardar los atomos de la solución
  local atoms = ""

  -- Recorre los modelos de la solución
  for model in handle:iter() do
    -- Convierto el modelo a string
    atoms = string.gsub(tostring(model), "%s", ". ")
  end

  -- Cierro la solución
  handle:close()

  -- Completo con los átomos de dimensiones
  atoms = atoms .. ". dims(" .. tostring(q_rows*c_rows) .. ","  ..
    tostring(q_cols*c_cols) ..  "). q_dims(" .. tostring(q_rows) .. "," ..
    tostring(q_cols) .. "). c_dims(" .. tostring(c_rows) .. "," ..
    tostring(c_cols) .. ")."

  -- Inicializa una matriz
  mat = Matrix(q_rows*c_rows, q_cols*c_cols, Constants.MatrixType.STRING, Constants.CellType.WATER_CELL)

  -- Genero las regiones
  for i = 1, regions do
    io.write("\n____ Region ", tostring(i), " ____\n")

    -- Creo un controlador del programa nuevo
    local prog1 = clingo.Control()
    -- Cargo el segundo programa
    prog1:load("main/asp/fill_regions.lp")
    -- Añado los átomos obtenidos antes
    prog1:add("base", {}, atoms)
    -- Hago el grounding del programa lógico
    prog1:ground({{"base", {}}, {"generate", {i-1}}})

    -- Le digo que al resolver quiero iterar los modelos
    local handle = prog1:solve({yield=true})

    -- Itero los modelos imprimiendo el resultado
    for m in handle:iter() do
      print(m)
    end

    -- Cierro la solución
    handle:close()
  end
end

#end.

% -- Carga los programas lógicos
% prog:load("main/asp/regions.lp")
% prog:load("main/asp/quadrants.lp")
%
% -- Obtiene el ancho y el alto de los cuadrantes
% q_rows = prog:get_const("q_rows").number
% q_cols = prog:get_const("q_cols").number
% -- Obtiene el ancho y el alto de las celdas
% c_rows = prog:get_const("c_rows").number
% c_cols = prog:get_const("c_cols").number
% -- Obtiene el número de regiones
% regions = prog:get_const("regions").number
%
% -- Inicializa una matriz
% mat = Matrix(q_rows*c_rows, q_cols*c_cols, Constants.MatrixType.STRING, Constants.CellType.WATER_CELL)
%
% -- Recorremos las regiones
% for i = 0, regions do
%   io.write("____ Iteration " .. tostring(i) .. " ____\n")
%   local parts = {}
%
%   if i > 0 then
%     table.insert(parts, {"generate", {i}})
%     prog:cleanup()
%   else
%     table.insert(parts, {"base", {}})
%   end
%
%   -- Hace ground de la generación de regiones
%   prog:ground(parts)
%   -- Obtiene una solución para el programa lógico
%   local solve = prog:solve({yield=true})
%   -- Parsea la solución
%   Parser.parseCells(solve, mat)
%   -- Cierra la solución
%   solve:close()
% end
%
% -- Serializamos la matriz
% serialize = Json.encode(mat:getTable())
% -- Escribimos la matriz
% tmp = io.open("resources/map.json", "w+")
% tmp:write(serialize)
% tmp:flush()
% tmp:close()
