local class = require 'libs.middleclass.middleclass'

local map = class('map')

-- Constants
map.WATER_CELL = 0
map.LAND_CELL = 0
map.VOID_CELL = 0

-- Creates a new map
function map:initialize(rows, cols)
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
function map:changeCell(row, pos)
  -- Switch water to land
  if self.data[row][pos] == map.WATER_CELL then
    self.data[row][pos] = map.LAND_CELL
  -- Switch land to void value
  elseif self.data[row][pos] == map.LAND_CELL then
    self.data[row][pos] = map.VOID_CELL
  -- Switch void value to water
  elseif self.data[row][pos] == map.VOID_CELL then
    self.data[row][pos] = map.WATER_CELL
  end
end

return map
