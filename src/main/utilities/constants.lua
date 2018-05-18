-- Rafael Alcalde Azpiazu - 20 Apr 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

--- This table defines all common constants.
-- @table Constans
local Constants = {
  -- @field CellType The cell types in the map.
  CellType = {
    WATER_CELL = "water",
    LAND_CELL = "land",
    VOID_CELL = "void"
  },

  -- @field MatrixType The types of a matrix.
  MatrixType = {
    NUMBER = "number",
    STRING = "string",
    BOOLEAN = "boolean",
    FUNCTION = "function",
    TABLE = "table",
    ALL = "all"
  }
}

return Constants
