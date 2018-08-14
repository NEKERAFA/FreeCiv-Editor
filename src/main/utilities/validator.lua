-- Rafael Alcalde Azpiazu - 22 Apr 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local Constants = require "main.utilities.constants"

--- This module defines functions to validate parameters.
-- @module Validator
local Validator = {
  --- Checks if a flag parameter exists or is valid.
  -- @param flags Table that represents a hashmap with all flags values.
  -- @param name Key of the flag to check.
  -- @param pos The position of the parameter in the function.
  -- @param[opt] default If default is not nil, if the flag do not exist, with return this value.
  getFlag = function(flags, name, pos, default)
    if flags then
      if flags[name] then
        return flags[name]
      elseif default then
        return default
      else
        error("bad argument #" .. pos .. " (flag " .. name .." must exist)")
      end
    end
  end,

  --- Checks if the number is natural.
  -- @param n The number to check.
  -- @param pos The position of the parameter in the function.
  -- @param[opt] max If max is not nil, checks if the number is less or equals that it.
  isNaturalNumber = function(n, pos, max)
    assert(n > 0, "bad argument #" .. pos .. " (must be greater than zero)")
    if max then
      assert(n <= max, "bad argument #" .. pos .. " (must be less or equals that " .. max .. ")")
    end
  end,

  --- Checks if the number is positive integer. Is like isNaturalNumber method, but includes the zero number.
  -- @param n The number to check.
  -- @param pos The position of the parameter in the function.
  -- @param[opt] max If max is not nil, checks if the number is less or equals that it.
  isPositiveInteger = function(n, pos, max)
    assert(n >= 0, "bad argument #" .. pos .. " (must be greater than zero)")
    if max then
      assert(n <= max, "bad argument #" .. pos .. " (must be less or equals that " .. max .. ")")
    end
  end,

  --- Checks if the value is a valid map cell value.
  -- @param value The value to checks.
  -- @param pos The position of the parameter in the function.
  isMapCellValue = function(value, pos)
    local result = false
    local err_msg = ""
    local n_value = 1

    -- Iterates all the types and checks if value is a valid type
    for _k_name, check_value in pairs(Constants.CellType) do
      result = result or value == check_value
      err_msg = err_msg .. _k_name
      if n_value < 11 then
        err_msg = err_msg .. ", "
      elseif n_value == 11 then
        err_msg = err_msg .. " or "
      end
      n_value = n_value + 1
    end

    assert(result, "bad argument #" .. pos .. " (must be a cell value like " .. err_msg ..")")
  end,

  --- Checks if the value is a 2D array.
  -- @param value The value to checks.
  -- @param pos The position of the parameter in the function.
  is2dArray = function(value, pos)
    assert(type(value) == "table", "bad argument #" .. pos .. " (table expected, got " .. type(value) .. ")")
    rows = #value
    assert(type(value[1]) == "table", "bad argument #" .. pos .. " (must be 2d table)")
    cols = #value[1]
    for i = 2, rows do
      assert(#value[rows] == cols, "bad argument #" .. pos .. " (rows must be the same size)")
    end
  end,

  -- Checks is the value is a valid matrix value
  -- @param value The value to checks.
  -- @param type_val The type to checks. @see Constants.
  -- @param pos The position of the parameter in the function
  isMatrixCellValue = function(value, type_val, pos)
    if type_val ~= "all" then
      result = (type(value) == type_val) or (((type_val == "function") or (type_val == "table")) and (type(value) == "nil"))
      assert(result, "bad argument #" .. pos .. " (" .. type_val .. " expected, got " .. type(value) .. ")")
    end
  end
}

return Validator
