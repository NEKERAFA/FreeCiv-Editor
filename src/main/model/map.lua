-- Rafael Alcalde Azpiazu - 19 Apr 2018
-- Facultade de Informática da Coruña - Universidade da Coruña
--
-- This file define functions to validate parameters

local class = require "libs.middleclass.middleclass"
local constants = require "main.utilities.constants"
local validator = require "main.utilities.validator"

local map = class('map')

-- Creates a new map
function map:initialize(rows, cols)
  -- Check parameters
  validator.isNaturalNumber(rows, 1)
  validator.isNaturalNumber(cols, 2)

  -- Creates a map
  self.rows = rows
  self.cols = cols
  self._data = {}

  -- Initialices with 0 all cells in the map
  for i = 1, rows do
    row = {}
    for j = 1, cols do
      table.insert(row, constants.WATER_CELL)
    end
    table.insert(self._data, row)
  end
end

-- Get a table with the map
function map:getMap()
  return self._data
end

-- Set a new map
function map:setMap(map_table)
  validator.is2dArray(map_table, 1)

  -- Gets the new dimensions
  self.rows = #map_table
  self.cols = #map_table[1]
  self._data = {}

  -- Save table
  for i = 1, self.rows do
    table.insert(self._data, {})
    for j = 1, self.cols do
      map:setCell(i, j, map_table[i][j])
    end
  end
end

-- Changes the value of a cell in the map
function map:changeCell(row, col)
  -- Check parameters
  validator.isNaturalNumber(row, 1, self.rows)
  validator.isNaturalNumber(col, 2, self.cols)

  -- Switch water to land
  if self._data[row][col] == constants.WATER_CELL then
    self._data[row][col] = constants.LAND_CELL
  -- Switch land to void value
  elseif self._data[row][col] == constants.LAND_CELL then
    self._data[row][col] = constants.VOID_CELL
  -- Switch void value to water
  elseif self._data[row][col] == constants.VOID_CELL then
    self._data[row][col] = constants.WATER_CELL
  end
end

-- Gets the value in the cell
function map:getCell(row, col)
  -- Check parameters
  validator.isNaturalNumber(row, 1, self.rows)
  validator.isNaturalNumber(col, 2, self.cols)

  return self._data[row][col]
end

-- Sets a new value in the cell
function map:setCell(row, col, value)
  -- Check parameters
  validator.isNaturalNumber(row, 1, self.rows)
  validator.isNaturalNumber(col, 2, self.cols)
  validator.isCellValue(value, 3)

  self._data[row][col] = value
end

return map
