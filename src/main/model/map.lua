-- Rafael Alcalde Azpiazu - 19 Apr 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local Class = require "libs.hump.class"
local Constants = require "main.utilities.constants"
local Validator = require "main.utilities.validator"

-- This class represents a FreeCiv Map
local Map = Class {
  -- Creates new map
  init = function(self, rows, cols)
    -- Check parameters
    Validator.isNaturalNumber(rows, 1)
    Validator.isNaturalNumber(cols, 2)

    -- Creates a map
    self.rows = rows
    self.cols = cols
    self._data = {}

    -- Initialices with 0 all cells in the map
    for i = 1, rows do
      row = {}
      for j = 1, cols do
        table.insert(row, Constants.CellType.WATER_CELL)
      end
      table.insert(self._data, row)
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

  -- Changes the value of a cell in the map
  changeCell = function(self, row, col)
    -- Check parameters
    Validator.isNaturalNumber(row, 1, self.rows)
    Validator.isNaturalNumber(col, 2, self.cols)

    -- Switch water to land
    if self._data[row][col] == Constants.CellType.WATER_CELL then
      self._data[row][col] = Constants.CellType.LAND_CELL
    -- Switch land to void value
    elseif self._data[row][col] == Constants.CellType.LAND_CELL then
      self._data[row][col] = Constants.CellType.VOID_CELL
    -- Switch void value to water
    elseif self._data[row][col] == Constants.CellType.VOID_CELL then
      self._data[row][col] = Constants.CellType.WATER_CELL
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
