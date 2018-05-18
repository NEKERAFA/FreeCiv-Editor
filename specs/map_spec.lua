describe("Map model tests.", function()
  local Map = require "main.model.map"
  local Constants = require "main.utilities.constants"

  it("Checks invalid row number on create map", function()
    local test_error = function()
      local instance = Map(0, 0)
    end

    assert.has.error(test_error, "bad argument #1 (must be greater than zero)")
  end)

  it("Checks invalid column number on create map", function()
    local test_error = function()
      local instance = Map(10, 0)
    end

    assert.has.error(test_error, "bad argument #2 (must be greater than zero)")
  end)

  it("Creates new map", function()
    local expected = {{Constants.CellType.WATER_CELL, Constants.CellType.WATER_CELL, Constants.CellType.WATER_CELL},
                      {Constants.CellType.WATER_CELL, Constants.CellType.WATER_CELL, Constants.CellType.WATER_CELL},
                      {Constants.CellType.WATER_CELL, Constants.CellType.WATER_CELL, Constants.CellType.WATER_CELL}}

    local instance = Map(3, 3)
    assert.are.same(instance:getMap(), expected)
  end)

  it("Checks invalid row number on changeCell", function()
    local test_error = function()
      local instance = Map(3, 4)
      instance:changeCell(4, 1)
    end

    assert.has.error(test_error, "bad argument #1 (must be less or equals that 3)")
  end)

  it("Checks invalid column number on changeCell", function()
    local test_error = function()
      local instance = Map(4, 3)
      instance:changeCell(1, 4)
    end

    assert.has.error(test_error, "bad argument #2 (must be less or equals that 3)")
  end)

  it("Checks if changeCell works", function()
    local instance = Map(3, 3)
    assert.are.equals(instance:getCell(2, 2), Constants.CellType.WATER_CELL)
    instance:changeCell(2, 2)
    assert.are.equals(instance:getCell(2, 2), Constants.CellType.LAND_CELL)
    instance:changeCell(2, 2)
    assert.are.equals(instance:getCell(2, 2), Constants.CellType.VOID_CELL)
    instance:changeCell(2, 2)
    assert.are.equals(instance:getCell(2, 2), Constants.CellType.WATER_CELL)
  end)

  it("Checks invalid type setCell", function()
    local test_error = function()
      local instance = Map(3, 3)
      instance:setCell(2, 2, {})
    end

    assert.has.error(test_error, "bad argument #3 (must be a cell value like WATER_CELL, LAND_CELL or VOID_CELL)")
  end)

  it("Checks if setCell works", function()
    local instance = Map(3, 3)
    instance:setCell(2, 2, Constants.CellType.LAND_CELL)
    assert.are.equals(instance:getCell(2, 2), Constants.CellType.LAND_CELL)
  end)

  it("Checks invalid value in setMap", function()
    local test_error = function()
      local instance = Map(4, 3)
      instance:setMap(4)
    end

    assert.has.error(test_error, "bad argument #1 (table expected, got number)")
  end)

  it("Checks invalid table in setMap", function()
    local test_error = function()
      local instance = Map(4, 3)
      instance:setMap({2, 3})
    end

    assert.has.error(test_error, "bad argument #1 (must be 2d table)")
  end)

  it("Checks invalid 2d-table in setMap", function()
    local test_error = function()
      local instance = Map(4, 3)
      instance:setMap({{1}, {1, 2}})
    end

    assert.has.error(test_error, "bad argument #1 (rows must be the same size)")
  end)

  it("Checks if setMap works", function()
    local expected = {{Constants.CellType.LAND_CELL, Constants.CellType.WATER_CELL, Constants.CellType.WATER_CELL},
                      {Constants.CellType.WATER_CELL, Constants.CellType.LAND_CELL, Constants.CellType.WATER_CELL},
                      {Constants.CellType.WATER_CELL, Constants.CellType.WATER_CELL, Constants.CellType.LAND_CELL}}

    local instance = Map(3, 3)
    instance:setMap(expected)
    assert.are.same(instance:getMap(), expected)
  end)
end)
