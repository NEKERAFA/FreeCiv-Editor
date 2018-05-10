-- Rafael Alcalde Azpiazu - 31 Jan 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local Constants = require "main.utilities.constants"

local QUADRANT_PATTERN = "quadrant%((%d+),(%d+)%)"
local CELL_PATTERN = "cell%((%d+),(%l+)%)"

local Parser = {
  -- Parsea una solución de ASP para obtener cuadrantes
  parseQuadrants = function(solve, quadrants)
    -- Recorre los modelos de la solución
    for model in solve:iter() do
      -- Busca la expresión regular en el modelo
      for pos, region in string.gmatch(tostring(model), QUADRANT_PATTERN) do
        local i = tonumber(pos)
        local value = tonumber(region)
        -- Añade la region del cuadrante
        quadrants:setPos(i, value)
      end
    end
  end,

  -- Parsea una solución de APS pata obtener celdas
  parseCells = function(solve, cells)
    -- Recorre los modelos de la solución
    for model in solve:iter() do
      -- Busca la expresión regular en el modelo
      for pos, terrain in string.gmatch(tostring(model), CELL_PATTERN) do
        local i = tonumber(pos)
        -- Añade la region del cuadrante
        if terrain == "l" then
          cells:setPos(i, Constants.CellType.LAND_CELL)
        end
      end
    end
  end
}

return Parser
