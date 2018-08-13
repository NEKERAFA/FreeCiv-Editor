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
    local expected = {{Constants.CellType.VOID, Constants.CellType.VOID, Constants.CellType.VOID},
                      {Constants.CellType.VOID, Constants.CellType.VOID, Constants.CellType.VOID},
                      {Constants.CellType.VOID, Constants.CellType.VOID, Constants.CellType.VOID}}

    local instance = Map(3, 3)
    assert.are.same(instance:getMap(), expected)
  end)

  it("Checks invalid type setCell", function()
    local test_error = function()
      local instance = Map(3, 3)
      instance:setCell(2, 2, {})
    end

    assert.has.error(test_error, "bad argument #3 (must be a cell value like OCEAN, PLAIN, VOID, JUNGLE, SEA, MOUNTAIN, LAKE, SWAMP, GRASS, TRUNDA or FOREST)")
  end)

  it("Checks if setCell works", function()
    local instance = Map(3, 3)
    instance:setCell(2, 2, Constants.CellType.PLAIN)
    assert.are.equals(instance:getCell(2, 2), Constants.CellType.PLAIN)
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
    local expected = {{Constants.CellType.PLAIN, Constants.CellType.SEA, Constants.CellType.SEA},
                      {Constants.CellType.SEA, Constants.CellType.PLAIN, Constants.CellType.SEA},
                      {Constants.CellType.SEA, Constants.CellType.SEA, Constants.CellType.PLAIN}}

    local instance = Map(3, 3)
    instance:setMap(expected)
    assert.are.same(instance:getMap(), expected)
  end)
end)
