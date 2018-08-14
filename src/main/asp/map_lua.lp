#script(lua)

local Json = require "libs.json.json"
local Matrix = require "main.model.matrix"
local Constants = require "main.utilities.constants"

-- Función principal
function main(prog)
  local q_rows, q_cols, c_rows, c_cols, regions
  local quadrants, cells

  -- Comprueba si es un borde superior del cuadrante
  function check_upper_border(row, col, region)
    local qrow = math.ceil(row / c_rows)
    local qcol = math.ceil(col / c_cols)

    return row == (qrow-1) * c_rows + 1 and qrow > 1 and quadrants:getCell(qrow-1, qcol) ~= region
  end

  -- Comprueba si es un borde inferior del cuadrante
  function check_bottom_border(row, col, region)
    local qrow = math.ceil(row / c_rows)
    local qcol = math.ceil(col / c_cols)

    return row == qrow * c_rows and qrow < q_rows and quadrants:getCell(qrow+1, qcol) ~= region
  end

  -- Comprueba si es un borde izquierdo del cuadrante
  function check_left_border(row, col, region)
    local qrow = math.ceil(row / c_rows)
    local qcol = math.ceil(col / c_cols)

    return col == (qcol-1) * c_cols + 1 and qcol > 1 and quadrants:getCell(qrow, qcol-1) ~= region
  end

  -- Comprueba si es un borde derecho del cuadrante
  function check_right_border(row, col, region)
    local qrow = math.ceil(row / c_rows)
    local qcol = math.ceil(col / c_cols)

    return col == qcol * c_cols and qcol < q_cols and quadrants:getCell(qrow, qcol+1) ~= region
  end

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
  cells = Matrix(q_rows*c_rows, q_cols*c_cols, Constants.MatrixType.STRING, Constants.CellType.SEA)

  local restrictions = ""

  -- Genero las regiones
  for i = 0, regions-1 do
    io.write("\n____ Region ", tostring(i+1), " ____\n")

    -- Creo un controlador del programa nuevo
    local prog1 = clingo.Control()
    -- Cargo el segundo programa
    prog1:load("main/asp/fill_regions.lp")
    -- Añado los átomos obtenidos antes
    prog1:add("base", {}, atoms)

    -- Añado las restricciones
    if #restrictions ~= 0 then
      prog1:load("resources/restrictions.lp")
      os.remove("resources/restrictions.lp")
    end

    -- Hago el grounding del programa lógico
    prog1:ground({{"base", {}}, {"generate", {i}}})

    -- Le digo que al resolver quiero iterar los modelos
    local handle = prog1:solve({yield=true})

    -- Itero los modelos realizando una captura de los átomos "cell"
    for m in handle:iter() do
      model = tostring(m)
      print(model)
      for pos, contain in string.gmatch(model, "cell%((%d+),(%l+)%)") do
        pos = tonumber(pos)
        assert(cells:getPos(pos) == Constants.CellType.SEA,
          "duplicate cell (position " .. pos ..", got " .. contain .. ", set " .. cells:getPos(pos) .. ")")

        if contain == "l" then
          cells:setPos(pos, Constants.CellType.GRASS)

          local row = math.floor(pos / (q_cols*c_cols)) + 1
          local col = (pos % (q_cols*c_cols)) + 1
          local pos = {}

          if check_upper_border(row, col, i) then
            local row, col = tostring(row-2), tostring(col-1)
            table.insert(pos, "p(" .. row .. "," .. col .. ")")
            io.write("Upper restriction p(" .. row .. "," .. col .. ")\n")
          end

          if check_left_border(row, col, i) then
            local row, col = tostring(row-1), tostring(col-2)
            table.insert(pos, "p(" .. row .. "," .. col .. ")")
            io.write("Left restriction p(" .. row .. "," .. col .. ")\n")
          end

          if check_right_border(row, col, i) then
            local row, col = tostring(row-1), tostring(col)
            table.insert(pos, "p(" .. row .. "," .. col .. ")")
            io.write("Right restriction p(" .. row .. "," .. col .. ")\n")
          end

          if check_bottom_border(row, col, i) then
            local row, col = tostring(row), tostring(col-1)
            table.insert(pos, "p(" .. row .. "," .. col .. ")")
            io.write("Bottom restriction p(" .. row .. "," .. col .. ")\n")
          end

          for k, pos in ipairs(pos) do
            restrictions = restrictions .. ":- reached(" .. pos ..").\n"
            restrictions = restrictions .. ":- rootcell(" .. pos .. ").\n"
          end
        end
      end

      df = io.open("resources/restrictions.lp", "w+")
      df:write(restrictions)
      df:flush()
      df:close()
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
