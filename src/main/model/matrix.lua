-- Rafael Alcalde Azpiazu - 9 May 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local Class = require "libs.hump.class"
local Constants = require "main.utilities.constants"
local Validator = require "main.utilities.validator"

--- This class represents a matrix object.
-- @classmod Matrix
local Matrix = Class {
  --- Initializes a new matrix object.
  -- @param self The new matrix object.
  -- @param rows The number of rows in the matrix.
  -- @param cols The number of columns in the matrix.
  -- @param[opt] type_val The type of the values in the cell. By default accept all Lua type.
  -- @param[optchain] initial_value The initial value of the cells in the matrix.
  init = function(self, rows, cols, type_val, initial_value)
    Validator.isNaturalNumber(rows, 1)
    Validator.isNaturalNumber(cols, 2)

    -- Save the type of the matrix
    self.type = type_val or Constants.MatrixType.ALL

    if initial_value == nil then
      if self.type == Constants.MatrixType.BOOLEAN then
        initial_value = false
      elseif self.type == Constants.MatrixType.STRING then
        initial_value = ""
      elseif self.type == Constants.MatrixType.TABLE then
        initial_value = {}
      elseif self.type == Constants.MatrixType.FUNCTION then
        initial_value = function() end
      else
        initial_value = 0
      end
    else
      Validator.isMatrixCellValue(initial_value, type_val, 4)
    end

    -- Creates a matrix
    self.rows = rows
    self.cols = cols
    self._data = {}

    -- Initialices with the initial_value all cells in the matrix
    for i = 1, rows do
      row = {}
      for j = 1, cols do
        table.insert(row, initial_value)
      end
      table.insert(self._data, row)
    end
  end,

  --- Sets a value in the matrix.
  -- @param self The matrix object.
  -- @param row The row position in the matrix.
  -- @param col The column position in the matrix.
  -- @param value The new value of the cell.
  setCell = function(self, row, col, value)
    Validator.isNaturalNumber(row, 1, self.rows)
    Validator.isNaturalNumber(col, 2, self.cols)
    Validator.isMatrixCellValue(value, self.type, 3)

    self._data[row][col] = value
  end,

  --- Gets a value in the matrix.
  -- @param self The matrix object.
  -- @param row The row position in the matrix.
  -- @param col The column position in the matrix.
  getCell = function(self, row, col)
    Validator.isNaturalNumber(row, 1, self.rows)
    Validator.isNaturalNumber(col, 2, self.cols)

    return self._data[row][col]
  end,

  --- Access to the matrix like 1d array.
  -- @param self The matrix object.
  -- @param position The array position in the matrix. Starts in 0.
  getPos = function(self, position)
    Validator.isPositiveInteger(position, 1, self.rows*self.cols)

    row = math.floor(position / self.cols) + 1
    col = (position % self.cols) + 1

    return self._data[row][col]
  end,

  --- Access to the matrix like 1d array and set a value.
  -- @param self The matrix object.
  -- @param position The array position in the matrix. Starts in 0.
  -- @param value The new value of the cell.
  setPos = function(self, position, value)
    Validator.isPositiveInteger(position, 1, self.rows*self.cols)
    Validator.isMatrixCellValue(value, self.type, 3)

    row = math.floor(position / self.cols) + 1
    col = (position % self.cols) + 1

    self._data[row][col] = value
  end,

  getTable = function(self)
    return self._data
  end,

  --- Return a string representation of the matrix
  -- @param self The matrix object.
  __tostring = function(self)
    str = "{"
    for i = 1, self.rows do
      str = str .. " {"
      for j = 1, self.cols do
        str = str .. tostring(self._data[i][j])
        if j < self.cols then
          str = str .. ", "
        end
      end
      str = str .. "}"
      if i < self.rows then
        str = str .. ", "
      else
        str = str .. " "
      end
    end

    return str .. "}"
  end
}

return Matrix
