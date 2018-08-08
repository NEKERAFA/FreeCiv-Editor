-- Rafael Alcalde Azpiazu - 7 Aug 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local Class = require "libs.hump.class"
local Constants = require "main.utilities.constants"

-- CONSTANTS -------------------------------------------------------------------

--- Constant variables.
-- In this section I defined all the types of tiles and the position of the tile
-- that I need.
-- @section Constants
local TILE = {
  SELECTOR = "selector",                  -- Represents the selector image
  SEA      = Constants.CellType.SEA,      -- Represents a sea bioma tile
  OCEAN    = Constants.CellType.OCEAN,    -- Represents a ocean bioma tile
  LAKE     = Constants.CellType.LAKE,     -- Represents a lake bioma tile
  PLAIN    = Constants.CellType.PLAIN,    -- Represents a plain bioma tile
  GRASS    = Constants.CellType.GRASS,    -- Represents a grass bioma tile
  FOREST   = Constants.CellType.FOREST,   -- Represents a forest bioma tile
  JUNGLE   = Constants.CellType.JUNGLE,   -- Represents a jungle bioma tile
  TRUNDA   = Constants.CellType.TRUNDA,   -- Represents a trunda bioma tile
  SWAMP    = Constants.CellType.SWAMP,    -- Represents a swamp bioma tile
  MOUNTAIN = Constants.CellType.MOUNTAIN, -- Represents a mountain bioma tile
  VOID     = Constants.CellType.VOID,     -- Represents a void tile
  BLANK    = "blank",                     -- Represents a blank tile (this is for set water cells)
  SPAWN    = "spawn",                     -- Represents the spawn image

  UPPER = "upper",
  BOTTOM = "bottom",
  LEFT = "left",
  RIGHT = "right"
}

local _TILE_UPPER = "upper"
local _TILE_BOTTOM = "bottom"
local _TILE_LEFT = "left"
local _TILE_RIGHT = "right"
local _TILE_UPPER_LEFT = "upper_left"
local _TILE_UPPER_RIGHT = "upper_right"
local _TILE_UPPER_BOTTOM = "upper_bottom"
local _TILE_BOTTOM_RIGHT = "bottom_right"
local _TILE_BOTTOM_LEFT = "bottom_left"
local _TILE_LEFT_RIGHT = "left_right"
local _TILE_UPPER_LEFT_RIGHT = "upper_left_right"
local _TILE_UPPER_LEFT_BOTTOM = "upper_left_bottom"
local _TILE_UPPER_RIGHT_BOTTOM = "upper_right_bottom"
local _TILE_BOTTOM_LEFT_RIGHTD = "bottom_left_right"
local _TILE_SURROUNDED = "surrounded"

--- This class defines a adapter class to connect the map model and the tilemap.
-- @classmod MapAdapter
local MapAdapter = {
  --- Creates new adapter object.
  -- @param self The new adapter object.
  -- @param map A map object. @see model/map.lua.
  -- @param tilemap A SpriteBatch LÖVE object that represents the tilemap to draw.
  -- @param background A SpriteBatch LÖVE object that represents the sea background.
  init = function (self, map, tilemap, background)
    self._map = map
    self._tilemap = tilemap
    self._background = background
  end,

  setCell = function (row, col, map, tilemap, bg)
  end,


}

return MapAdapter
