-- Rafael Alcalde Azpiazu - 19 Apr 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local Class = require "libs.hump.class"
local Constants = require "main.utilities.constants"
local Validator = require "main.utilities.validator"

--- This class represents a FreeCiv Map
-- @classmod Map
local Map = Class {
  -- Creates new map
  init = function(self, ...)
    args = {...}

    if #args < 1 then
      error("too few arguments")
    elseif #args == 1 then
      -- Add a table like a map
      self:setMap(args[1])
    elseif #args == 2 then
      -- Check parameters
      Validator.isNaturalNumber(args[1], 1)
      Validator.isNaturalNumber(args[2], 2)

      -- Creates a map
      self.rows = args[1]
      self.cols = args[2]
      self._data = {}

      -- Initialices with 0 all cells in the map
      for i = 1, args[1] do
        row = {}
        for j = 1, args[2] do
          table.insert(row, Constants.CellType.VOID)
        end
        table.insert(self._data, row)
      end
    elseif #args > 2 then
      error("too many arguments")
    end
  end,

  -- Gets a table with the map
  getMap = function(self)
    return Class.clone(self._data)
  end,

  -- Set a new map
  setMap = function(self, map_table)
    Validator.is2dArray(map_table, 1)

    -- Gets the new dimensions
    self.rows = #map_table
    self.cols = #map_table[1]
    self._data = {}

    -- Save table
    for i = 1, self.rows do
      table.insert(self._data, {})
      local row = self._data[i]
      for j = 1, self.cols do
        table.insert(row, map_table[i][j])
      end
    end
  end,

  -- Gets the value in the cell
  getCell = function(self, row, col)
    -- Check parameters
    Validator.isNaturalNumber(row, 1, self.rows)
    Validator.isNaturalNumber(col, 2, self.cols)

    return self._data[row][col]
  end,

  -- Sets a new value in the cell
  setCell = function(self, row, col, value)
    -- Check parameters
    Validator.isNaturalNumber(row, 1, self.rows)
    Validator.isNaturalNumber(col, 2, self.cols)
    Validator.isMapCellValue(value, 3)

    self._data[row][col] = value
  end
}

return Map
