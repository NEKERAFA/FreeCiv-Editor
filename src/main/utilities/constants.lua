-- Rafael Alcalde Azpiazu - 20 Apr 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

-- This table defines all common constants.
local Constants = {
  -- Cell map types
  CellType = {
    SEA      = "sea",      -- Represents a sea bioma cell
    OCEAN    = "ocean",    -- Represents a ocean bioma cell
    LAKE     = "lake",     -- Represents a lake bioma cell
    PLAIN    = "plain",    -- Represents a plain bioma cell
    GRASS    = "grass",    -- Represents a grass bioma cell
    FOREST   = "forest",   -- Represents a forest bioma cell
    JUNGLE   = "jungle",   -- Represents a jungle bioma cell
    TRUNDA   = "trunda",   -- Represents a trunda bioma cell
    SWAMP    = "swamp",    -- Represents a swamp bioma cell
    MOUNTAIN = "mountain", -- Represents a mountain bioma cell
    VOID     = "void"      -- Represents a void cell
  },

  -- Matrix types
  MatrixType = {
    NUMBER   = "number",
    STRING   = "string",
    BOOLEAN  = "boolean",
    FUNCTION = "function",
    TABLE    = "table",
    ALL      = "all"
  }
}

return Constants
