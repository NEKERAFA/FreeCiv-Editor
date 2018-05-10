-- Rafael Alcalde Azpiazu - 9 May 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local Class = require "libs.hump.class"
local Validator = require "main.utilities.validator"

-- This class represents a matrix object
local Matrix = Class {
  -- Creates new matrix
  init = function(self, rows, cols, initial_value)
    Validator.isNaturalNumber(rows, 1)
    Validator.isNaturalNumber(cols, 2)
    initial_value = initial_value or 0

    -- Creates a matrix
    self.rows = rows
    self.cols = cols
    self._data = {}

    -- Initialices with 0 all cells in the matrix
    for i = 1, rows do
      row = {}
      for j = 1, cols do
        table.insert(row, initial_value)
      end
      table.insert(self._data, row)
    end
  end,

  -- Sets a value in a cell
  setCell = function(self, row, col, value)
    Validator.isNaturalNumber(row, 1, self.rows)
    Validator.isNaturalNumber(col, 2, self.cols)

    self._data[row][col] = value
  end,

  -- Gets the value in a cell
  getCell = function(self, row, col, value)
    Validator.isNaturalNumber(row, 1, self.rows)
    Validator.isNaturalNumber(col, 2, self.cols)

    return self._data[row][col]
  end,

  -- Access to the matrix like 1d array
  getPos = function(self, position)
    Validator.isPositiveInteger(position, 1, self.rows*self.cols)
    row = math.floor(position / self.cols) + 1
    col = (position % self.cols) + 1
    return self._data[row][col]
  end,

  -- Sets element to the matrix like 1d array
  setPos = function(self, position, value)
    Validator.isPositiveInteger(position, 1, self.rows*self.cols)
    row = math.floor(position / self.cols) + 1
    col = (position % self.cols) + 1
    self._data[row][col] = value
  end,

  getTable = function(self)
    return self._data
  end,

  -- Prints the matrix
  __tostring = function(self)
    str = "{"
    for i = 1, self.rows do
      str = str .. "{"
      for j = 1, self.cols do
        str = str .. self._data[i][j]
        if j < self.cols then
          str = str .. ", "
        end
      end
      str = str .. "}"
    end

    return str .. "}"
  end
}

return Matrix
