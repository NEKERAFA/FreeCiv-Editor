describe("Map model tests.", function()
  local Map = require "main.model.map"
  local constants = require "main.utilities.constants"

  it("Checks invalid row number on create map", function()
    local test_error = function()
      local obj = Map(0, 0)
    end

    assert.has.error(test_error, "bad argument #1 (must be greater than zero)")
  end)

  it("Checks invalid column number on create map", function()
    local test_error = function()
      local obj = Map(10, 0)
    end

    assert.has.error(test_error, "bad argument #2 (must be greater than zero)")
  end)

  it("Creates new map", function()
    local expected = {{constants.WATER_CELL, constants.WATER_CELL, constants.WATER_CELL},
                      {constants.WATER_CELL, constants.WATER_CELL, constants.WATER_CELL},
                      {constants.WATER_CELL, constants.WATER_CELL, constants.WATER_CELL}}

    local obj = Map(3, 3)
    assert.are.same(obj:getMap(), expected)
  end)

  it("Checks invalid row number on changeCell", function()
    local test_error = function()
      local obj = Map(3, 4)
      obj:changeCell(4, 1)
    end

    assert.has.error(test_error, "bad argument #1 (must be less or equals that 3)")
  end)

  it("Checks invalid column number on changeCell", function()
    local test_error = function()
      local obj = Map(4, 3)
      obj:changeCell(1, 4)
    end

    assert.has.error(test_error, "bad argument #2 (must be less or equals that 3)")
  end)

  it("Checks if changeCell works", function()
    local obj = Map(3, 3)
    assert.are.equals(obj:getCell(2, 2), constants.WATER_CELL)
    obj:changeCell(2, 2)
    assert.are.equals(obj:getCell(2, 2), constants.LAND_CELL)
    obj:changeCell(2, 2)
    assert.are.equals(obj:getCell(2, 2), constants.VOID_CELL)
    obj:changeCell(2, 2)
    assert.are.equals(obj:getCell(2, 2), constants.WATER_CELL)
  end)

  it("Checks invalid type setCell", function()
    local test_error = function()
      local obj = Map(3, 3)
      obj:setCell(2, 2, {})
    end

    assert.has.error(test_error, "bad argument #3 (must be a cell value like WATER_CELL, LAND_CELL or VOID_CELL)")
  end)

  it("Checks if setCell works", function()
    local obj = Map(3, 3)
    obj:setCell(2, 2, constants.LAND_CELL)
    assert.are.equals(obj:getCell(2, 2), constants.LAND_CELL)
  end)

  it("Checks invalid value in setMap", function()
    local test_error = function()
      local obj = Map(4, 3)
      obj:setMap(4)
    end

    assert.has.error(test_error, "bad argument #1 (table expected, got number)")
  end)

  it("Checks invalid table in setMap", function()
    local test_error = function()
      local obj = Map(4, 3)
      obj:setMap({2, 3})
    end

    assert.has.error(test_error, "bad argument #1 (must be 2d table)")
  end)

  it("Checks invalid 2d-table in setMap", function()
    local test_error = function()
      local obj = Map(4, 3)
      obj:setMap({{1}, {1, 2}})
    end

    assert.has.error(test_error, "bad argument #1 (rows must be the same size)")
  end)

  it("Checks if setMap works", function()
    local expected = {{constants.LAND_CELL, constants.WATER_CELL, constants.WATER_CELL},
                      {constants.WATER_CELL, constants.LAND_CELL, constants.WATER_CELL},
                      {constants.WATER_CELL, constants.WATER_CELL, constants.LAND_CELL}}

    local obj = Map(3, 3)
    obj:setMap(expected)
    assert.are.same(obj:getMap(), expected)
  end)
end)
