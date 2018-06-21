-- Rafael Alcalde Azpiazu - 31 Jan 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local QUADRANT_PATTERN = "(quadrant%(%d+,(%d+)%))"
local CELL_PATTERN = "cell%((%d+),(%l+)%)"

local Parser = {
  -- Parsea la solución de ASP para obtener las regiones
  parseRegions = function(handle)
    local regions = {}
    -- Recorre los modelos de la solución
    for model in handle:iter() do
      -- Busca la expresión regular en el modelo
      for atom, quadrant in string.gmatch(tostring(model), QUADRANT_PATTERN) do
        io.write(atom, "\n")
        -- Pasamos el cuadrante a número
        local i = tonumber(quadrant)
        -- Creamos la lista de átomos de las regiones
        if not regions[i] then
          regions[i] = {}
        end
        -- Añadimos el átomo a la lista
        table.insert(regions[i], atom)
      end
    end
    return regions
  end
}

return Parser
