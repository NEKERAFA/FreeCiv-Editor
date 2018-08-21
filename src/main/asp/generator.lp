#script(lua)

local Json = require "libs.json.json"
local Matrix = require "main.model.matrix"
local Constants = require "main.utilities.constants"

-- CONSTANTES ------------------------------------------------------------------
DEBUG = 0

-- VARIABLES -------------------------------------------------------------------

local q_rows, q_cols, c_rows, c_cols, regions, m_size
local quadrants, cells, terrain

-- FUNCIONES -------------------------------------------------------------------

-- Imprime en la salida estandar un mensaje si estamos en modo debug.
function logger(...)
  if DEBUG ~= 0 then
    print(...)
  end
end

-- Comprueba si es un borde superior del cuadrante
function check_upper_border(row, col, region)
  local qrow = math.ceil(row / c_rows)
  local qcol = math.ceil(col / c_cols)

  if qrow > 1 then
    logger(row, qrow, (qrow-1) * c_rows + 1, region, quadrants:getCell(qrow-1, qcol))
  end

  return (row == ((qrow-1) * c_rows + 1)) and (qrow > 1) and
    (quadrants:getCell(qrow-1, qcol) ~= region)
end

-- Comprueba si es un borde inferior del cuadrante
function check_bottom_border(row, col, region)
  local qrow = math.ceil(row / c_rows)
  local qcol = math.ceil(col / c_cols)

  if (qrow < q_rows) then
    logger(row, qrow, qrow * c_rows, region, quadrants:getCell(qrow+1, qcol))
  end

  return (row == (qrow * c_rows)) and (qrow < q_rows) and
    (quadrants:getCell(qrow+1, qcol) ~= region)
end

-- Comprueba si es un borde izquierdo del cuadrante
function check_left_border(row, col, region)
  local qrow = math.ceil(row / c_rows)
  local qcol = math.ceil(col / c_cols)

  if qcol > 1 then
    logger(col, qcol, (qcol-1) * c_cols + 1, region, quadrants:getCell(qrow, qcol-1))
  end

  return (col == ((qcol-1) * c_cols + 1)) and (qcol > 1) and
    (quadrants:getCell(qrow, qcol-1) ~= region)
end

-- Comprueba si es un borde derecho del cuadrante
function check_right_border(row, col, region)
  local qrow = math.ceil(row / c_rows)
  local qcol = math.ceil(col / c_cols)

  if (qcol < q_cols) then
    logger(col, qcol, qcol * c_cols, region, quadrants:getCell(qcol, qcol+1))
  end

  return (col == (qcol * c_cols)) and (qcol < q_cols) and
    (quadrants:getCell(qrow, qcol+1) ~= region)
end

-- Comprueba las restricciones dada una celda
function check_restrictions(row, col, i)
  local pos = {}
  local restrictions = ""

  -- Restricción superior
  if check_upper_border(row, col, i) then
    local n_row, n_col = tostring(row-2), tostring(col-1)
    table.insert(pos, "p(" .. n_row .. "," .. n_col .. ")")
    logger("With p(" .. tostring(row-1) .. "," .. tostring(col-1) .. "), " ..
      "upper restriction on p(" .. tostring(n_row) .. "," .. tostring(n_col))
  end

  -- Restricción izquierda
  if check_left_border(row, col, i) then
    local n_row, n_col = tostring(row-1), tostring(col-2)
    table.insert(pos, "p(" .. n_row .. "," .. n_col .. ")")
    logger("With p(" .. tostring(row-1) .. "," .. tostring(col-1) .. "), " ..
      "left restriction on p(" .. tostring(n_row) .. "," .. tostring(n_col))
  end

  -- Restricción derecha
  if check_right_border(row, col, i) then
    local n_row, n_col = tostring(row-1), tostring(col)
    table.insert(pos, "p(" .. n_row .. "," .. n_col .. ")")
    logger("With p(" .. tostring(row-1) .. "," .. tostring(col-1) .. "), " ..
      "right restriction on p(" .. tostring(n_row) .. "," .. tostring(n_col))
  end

  -- Restricción inferior
  if check_bottom_border(row, col, i) then
    local n_row, n_col = tostring(row), tostring(col-1)
    table.insert(pos, "p(" .. n_row .. "," .. n_col .. ")")
    logger("With p(" .. tostring(row-1) .. "," .. tostring(col-1) .. "), " ..
      "botton restriction on p(" .. tostring(n_row) .. "," .. tostring(n_col))
  end

  -- Recorre las restricciones y las guarda como restricciones finales
  for k, pos in ipairs(pos) do
    restrictions = restrictions .. ":- reached(" .. pos ..").\n"
    restrictions = restrictions .. ":- rootcell(" .. pos .. ").\n"
  end

  return restrictions
end

-- FUNCION PRINCIPAL -----------------------------------------------------------

function main(prog)
  local status = io.open("resources/status.txt", "w+")
  status:write("Generating regions")
  status:close()

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
  -- Obtiene el tamaño de las montanas
  m_size = prog:get_const("m_size").number
  -- Obtiene si estamos en modo debug
  debug_const = prog:get_const("debug")
  if debug_const then
    DEBUG = debug_const.number
  end

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
    tostring(c_cols) .. "). ratio(40, 80)."

  -- Inicializa una matriz para guardar las celdas
  cells = Matrix(q_rows*c_rows, q_cols*c_cols, Constants.MatrixType.STRING)
  -- Inicializa una matriz para guardar el tipo de terreno
  terrain = Matrix(q_rows*c_rows, q_cols*c_cols, Constants.MatrixType.STRING, Constants.CellType.GRASS)

  local restrictions = ""

  -- Genero las regiones
  for i = 0, regions-1 do
    logger("\n____ Region ", tostring(i+1), " ____")
    status = io.open("resources/status.txt", "w+")
    status:write("Filling region " .. tostring(i+1))
    status:close()

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
    local lands = ""
    for m in handle:iter() do
      model = tostring(m)
      logger(model)
      for row_str, col_str, contain in string.gmatch(model, "cell%(p%((%d+),(%d+)%),(%l+)%)") do
        local row, col = tonumber(row_str)+1, tonumber(col_str)+1

        -- Comprueba
        assert(cells:getCell(row, col) == "",
          "duplicate cell (position (" .. row_str ..", " .. col_str .. "), got " ..
          contain .. ", set " .. cells:getCell(row, col) .. ")")
        cells:setCell(row, col, contain)

        if contain == "l" then
          lands = lands .. " cell(p("..row_str..","..col_str.."), l)."
          restrictions = restrictions .. check_restrictions(row, col, i)
        end
      end

      df = io.open("resources/restrictions.lp", "w+")
      df:write(restrictions)
      df:flush()
      df:close()
    end

    -- Cierro la solución
    handle:close()

    logger("\n__ DETALING TERRAIN __")
    --logger(string.gsub(model, "%s", ". ") .. ".")
    status = io.open("resources/status.txt", "w+")
    status:write("Detaling terrain in region " .. tostring(i+1))
    status:close()

    -- Creo un controlador del programa nuevo
    local prog2 = clingo.Control()
    -- Cargo el segundo programa
    prog2:load("main/asp/detail_terrain.lp")
    local atoms = "dims(" .. tostring(q_rows*c_rows) .. "," ..
      tostring(q_cols*c_cols) .. "). " .. lands
    -- Añado los átomos obtenidos antes
    logger(atoms)
    prog2:add("base", {}, atoms)
    -- Hace grounding del programa lógico
    prog2:ground({{"base", {}}})
    -- Obtengo un manejador de la solución
    local handle = prog2:solve({yield=true})

    -- Recorre los modelos de la solución
    for model in handle:iter() do
      -- Convierto el modelo a string
      result = tostring(model)
      logger(result)
      for row_str, col_str, contain in string.gmatch(result, "land%(p%((%d+),(%d+)%),(%l+)%)") do
        local row, col = tonumber(row_str), tonumber(col_str)
        terrain:setCell(row+1, col+1, contain)
      end
    end

    -- Cierro la solución
    handle:close()

    logger("\n__ DETALING MOUNTAINS __")
    --logger(string.gsub(model, "%s", ". ") .. ".")
    status = io.open("resources/status.txt", "w+")
    status:write("Detaling mountains in region " .. tostring(i+1))
    status:close()

    -- Creo un controlador del programa nuevo
    local prog3 = clingo.Control()
    -- Cargo el segundo programa
    prog3:load("main/asp/detail_mountains.lp")
    local atoms = "dims(" .. tostring(q_rows*c_rows) .. "," ..
      tostring(q_cols*c_cols) .. "," .. tostring(m_size) .. "). " .. lands
    -- Añado los átomos obtenidos antes
    logger(atoms)
    prog3:add("base", {}, atoms)
    -- Hace grounding del programa lógico
    prog3:ground({{"base", {}}})
    -- Obtengo un manejador de la solución
    local handle = prog3:solve({yield=true})

    -- Recorre los modelos de la solución
    for model in handle:iter() do
      -- Convierto el modelo a string
      result = tostring(model)
      logger(result)
      for row_str, col_str in string.gmatch(result, "mountain%(p%((%d+),(%d+)%)") do
        local row, col = tonumber(row_str), tonumber(col_str)
        terrain:setCell(row+1, col+1, Constants.CellType.MOUNTAIN)
      end
    end

    -- Cierro la solución
    handle:close()
  end
  -- Se borra el archivo de restricciones
  os.remove("resources/restrictions.lp")

  logger("\n\n__ ADDING WATER __")
  status = io.open("resources/status.txt", "w+")
  status:write("Detaling water")
  status:close()

  -- Creo un controlador del programa nuevo
  local prog1 = clingo.Control()
  -- Cargo el segundo programa
  prog1:load("main/asp/detail_water.lp")

  -- Añade el terreno generado como átomos
  atoms = "dims(" .. tostring(q_rows*c_rows) .. "," ..
    tostring(q_cols*c_cols) .. "). "

  for row = 1, q_rows*c_rows do
    for col = 1, q_cols*c_cols do
      atoms = atoms .. "cell(p(" ..  tostring(row-1) .. "," .. tostring(col-1) ..
        ")," .. cells:getCell(row, col) .. "). "
    end
  end

  -- Añado los átomos obtenidos antes
  prog1:add("base", {}, atoms)
  -- Hace grounding del programa lógico
  prog1:ground({{"base", {}}})
  -- Obtengo un manejador de la solución
  local handle = prog1:solve({yield=true})
  -- Variable para guardar los atomos de la solución
  local atoms = ""

  -- Recorre los modelos de la solución
  for model in handle:iter() do
    -- Convierto el modelo a string
    result = tostring(model)
    logger(result)
    for row_str, col_str, contain in string.gmatch(result, "water%(p%((%d+),(%d+)%),(%l+)%)") do
      local row, col = tonumber(row_str), tonumber(col_str)
      terrain:setCell(row+1, col+1, contain)
    end
  end

  -- Cierro la solución
  handle:close()

  -- Serializo la matriz
  local result = {
    regions = quadrants:getTable(),
    terrain = terrain:getTable()
  }
  serialize = Json.encode(result)
  -- Escribo la matriz en un archivo de resultados
  tmp = io.open("resources/result.json", "w+")
  tmp:write(serialize)
  tmp:flush()
  tmp:close()

  os.remove("resources/status.txt")
end

#end.
