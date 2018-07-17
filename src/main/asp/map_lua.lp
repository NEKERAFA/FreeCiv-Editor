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

  -- Inicializa una matriz
  quadrants = Matrix(q_rows, q_cols)

  -- Recorre los modelos de la solución
  for model in handle:iter() do
    -- Convierto el modelo a string
    atoms = string.gsub(tostring(model), "%s", ". ")
    for pos, quadrant in string.gmatch(atoms, "quadrant%((%d+),(%d+)%)") do
      pos, quadrant = tonumber(pos), tonumber(quadrant)
      quadrants:setPos(pos, quadrant)
    end
  end

  -- Cierro la solución
  handle:close()

  -- Completo con los átomos de dimensiones
  atoms = atoms .. ". dims(" .. tostring(q_rows*c_rows) .. ","  ..
    tostring(q_cols*c_cols) ..  "). q_dims(" .. tostring(q_rows) .. "," ..
    tostring(q_cols) .. "). c_dims(" .. tostring(c_rows) .. "," ..
    tostring(c_cols) .. ")."

  -- Inicializa una matriz
  cells = Matrix(q_rows*c_rows, q_cols*c_cols, Constants.MatrixType.STRING, Constants.CellType.WATER_CELL)

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

    -- Guardo las celdas creadas de tierras
    local lands = ""

    -- Itero los modelos realizando una captura de los átomos "cell"
    for m in handle:iter() do
      model = tostring(m)
      print(model)
      for pos, contain in string.gmatch(model, "cell%((%d+),(%l+)%)") do
        pos = tonumber(pos)
        assert(cells:getPos(pos) == Constants.CellType.WATER_CELL,
          "duplicate cell (position " .. pos ..", got " .. contain .. ", set " .. cells:getPos(pos) .. ")")

        if contain == "l" then
          cells:setPos(pos, Constants.CellType.LAND_CELL)

          local row = math.floor(pos / (q_cols*c_cols)) + 1
          local col = (pos % (q_cols*c_cols)) + 1

          lands = lands .. "land(" .. row .. ", " .. col .. "). "
        end
      end

      --atoms = atoms .. lands
    end

    -- Cierro la solución
    handle:close()
  end

  -- Serializo la matriz
  local result = {
    regions = quadrants:getTable(),
    cells = cells:getTable()
  }
  serialize = Json.encode(result)
  -- Escribo la matriz
  tmp = io.open("resources/result.json", "w+")
  tmp:write(serialize)
  tmp:flush()
  tmp:close()
end

#end.
