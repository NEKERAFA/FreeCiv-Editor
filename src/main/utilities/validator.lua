-- Rafael Alcalde Azpiazu - 22 Apr 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local Constants = require "main.utilities.constants"

-- This module defines functions to validate parameters
local Validator = {
  -- Checks if a flag parameter exists
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

  -- Checks if the number is natural
  isNaturalNumber = function(n, pos, max)
    assert(n > 0, "bad argument #" .. pos .. " (must be greater than zero)")
    if max then
      assert(n <= max, "bad argument #" .. pos .. " (must be less or equals that " .. max .. ")")
    end
  end,

  -- Checks if the number is natural
  isPositiveInteger = function(n, pos, max)
    assert(n >= 0, "bad argument #" .. pos .. " (must be greater than zero)")
    if max then
      assert(n <= max, "bad argument #" .. pos .. " (must be less or equals that " .. max .. ")")
    end
  end,

  -- Checks if the value is a valid cell contain
  isCellValue = function(value, pos)
    result = value == Constants.CellType.WATER_CELL or value == Constants.LAND_CELL or value == Constants.VOID_CELL
    assert(result, "bad argument #" .. pos .. " (must be a cell value like WATER_CELL, LAND_CELL or VOID_CELL)")
  end,

  is2dArray = function(value, pos)
    assert(type(value) == "table", "bad argument #" .. pos .. " (table expected, got " .. type(value) .. ")")
    rows = #value
    assert(type(value[1]) == "table", "bad argument #" .. pos .. " (must be 2d table)")
    cols = #value[1]
    for i = 2, rows do
      assert(#value[rows] == cols, "bad argument #" .. pos .. " (rows must be the same size)")
    end
  end
}

return Validator
