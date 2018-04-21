local class = require 'libs.middleclass.middleclass'

local map = class('map')

-- Constants
map.WATER_CELL = 0
map.LAND_CELL = 1
map.VOID_CELL = 2

-- This function validates if a number is a natural number
function validate_nat_number(n, pos, max)
  assert(n > 0, "bad argument #" .. pos .. ", must be greater than zero")
  if max then
    assert(n < max, "bad argument #" .. pos .. ", must be less that " .. max)
  end
end

-- This function validates if a variable is a valid cell value
function validate_cell_value(val, pos)
  assert(n == map.WATER_CELL or n == map.LAND_CELL or n == map.VOID_CELL, "bad argument #" .. pos .. ", must be a cell value (WATER_CELL, LAND_CELL, VOID_CELL)")
end

-- Creates a new map
function map:initialize(rows, cols)
  validate_nat_number(rows, 1)
  validate_nat_number(cols, 2)

  -- Creates a map
  self.rows = rows
  self.cols = cols
  self.data = {}

  -- Initialices with 0 all cells in the map
  for i = 1, rows do
    row = {}
    for j = 1, cols do
      table.insert(row, map.WATER_CELL)
    end
    table.insert(self.data, row)
  end
end

-- Get a table with the map
function map:getMap()
  return self.data
end

-- Changes the value of a cell in the map
function map:changeCell(row, col)
  validate_nat_number(row, 1, self.data.rows)
  validate_nat_number(col, 2, self.data.cols)

  -- Switch water to land
  if self.data[row][col] == map.WATER_CELL then
    self.data[row][col] = map.LAND_CELL
  -- Switch land to void value
  elseif self.data[row][col] == map.LAND_CELL then
    self.data[row][col] = map.VOID_CELL
  -- Switch void value to water
  elseif self.data[row][col] == map.VOID_CELL then
    self.data[row][col] = map.WATER_CELL
  end
end

function map:getCell(row, col)
  validate_nat_number(row, 1, self.data.rows)
  validate_nat_number(col, 2, self.data.cols)

  return self.data[row][col]
end

function map:setCell(row, col, value)
  validate_nat_number(row, 1, self.data.rows)
  validate_nat_number(col, 2, self.data.cols)
  validate_cell_value(value, 3)

  self.data[row][col] = value
end

return map
