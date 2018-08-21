-- Rafael Alcalde Azpiazu - 20 Apr 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

-- This table defines all common constants.
local Constants = {
  -- Cell map types
  CellType = {
    SEA      = "sea",      -- Represents a sea bioma cell
    OCEAN    = "ocean",    -- Represents a ocean bioma cell
    GLACIER  = "glacier",  -- Represents a glacier bioma cell
    LAKE     = "lake",     -- Represents a lake bioma cell
    PLAIN    = "plain",    -- Represents a plain bioma cell
    GRASS    = "grass",    -- Represents a grass bioma cell
    FOREST   = "forest",   -- Represents a forest bioma cell
    JUNGLE   = "jungle",   -- Represents a jungle bioma cell
    TRUNDA   = "trunda",   -- Represents a trunda bioma cell
    SWAMP    = "swamp",    -- Represents a swamp bioma cell
    DESERT   = "desert",   -- Represents a desert bioma cell
    MOUNTAIN = "mountain", -- Represents a mountain bioma cell
    VOID     = "void"      -- Represents a void cell
  },

  -- Tile types
  TileType = {
    SELECTOR = "selector", -- Represents the selector image
    SEA      = "sea",      -- Represents a sea bioma tile
    OCEAN    = "ocean",    -- Represents a ocean bioma tile
    GLACIER  = "glacier",  -- Represents a glacier bioma tile
    LAKE     = "lake",     -- Represents a lake bioma tile
    PLAIN    = "plain",    -- Represents a plain bioma tile
    GRASS    = "grass",    -- Represents a grass bioma tile
    FOREST   = "forest",   -- Represents a forest bioma tile
    JUNGLE   = "jungle",   -- Represents a jungle bioma tile
    TRUNDA   = "trunda",   -- Represents a trunda bioma tile
    SWAMP    = "swamp",    -- Represents a swamp bioma tile
    MOUNTAIN = "mountain", -- Represents a mountain bioma tile
    VOID     = "void",     -- Represents a void tile
    BLANK    = "blank",   -- Represents a border tile (this is for set water cells)
    SPAWN    = "spawn"     -- Represents the spawn image
  },

  -- Tile position map
  TilePosition = {
    SINGLE             = "single",
    UPPER              = "upper",
    BOTTOM             = "bottom",
    LEFT               = "left",
    RIGHT              = "right",
    UPPER_LEFT         = "upper_left",
    UPPER_RIGHT        = "upper_right",
    UPPER_BOTTOM       = "upper_bottom",
    BOTTOM_RIGHT       = "bottom_right",
    BOTTOM_LEFT        = "bottom_left",
    LEFT_RIGHT         = "left_right",
    UPPER_LEFT_RIGHT   = "upper_left_right",
    UPPER_LEFT_BOTTOM  = "upper_left_bottom",
    UPPER_RIGHT_BOTTOM = "upper_right_bottom",
    BOTTOM_LEFT_RIGHT  = "bottom_left_right",
    SURROUNDED         = "surrounded"
  },

  -- Matrix types
  MatrixType = {
    NUMBER   = "number",
    STRING   = "string",
    BOOLEAN  = "boolean",
    FUNCTION = "function",
    TABLE    = "table",
    ALL      = "all"
  },

  -- Some regular expressions that the exporter uses to convert the scenario template
  -- into a valid Freeciv map
  TemplateRegex = {
    NAME        = "::NAME::",
    PLAYERS     = "::PLAYERS::",
    ROWS        = "::ROWS::",
    COLUMNS     = "::COLUMNS::",
    TERRAIN     = "::TERRAIN::",
    PLAYER_LIST = "::PLAYER_LIST::",
    LAYER_B     = "::LAYER_B::",
    LAYER_R     = "::LAYER_R::"
  }
}

return Constants
