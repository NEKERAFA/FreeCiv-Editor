describe("Matrix model tests.", function()
  local Matrix = require "main.model.matrix"
  local Constants = require "main.utilities.constants"

  it("Checks invalid row number on create matrix", function()
    local test_error = function()
      local instance = Matrix(0, 0)
    end

    assert.has.error(test_error, "bad argument #1 (must be greater than zero)")
  end)

  it("Checks invalid column number on create matrix", function()
    local test_error = function()
      local instance = Matrix(10, 0)
    end

    assert.has.error(test_error, "bad argument #2 (must be greater than zero)")
  end)

  it("Creates new matrix", function()
    local expected = {{0, 0, 0},
                      {0, 0, 0},
                      {0, 0, 0}}

    local instance = Matrix(3, 3)
    assert.are.same(instance:getTable(), expected)
  end)

  it("Creates new matrix with boolean elements", function()
    local expected = {{false, false, false},
                      {false, false, false},
                      {false, false, false}}

    local instance = Matrix(3, 3, Constants.MatrixType.BOOLEAN)
    assert.are.same(instance:getTable(), expected)
  end)

  it("Creates new matrix with string elements", function()
    local expected = {{"", "", ""},
                      {"", "", ""},
                      {"", "", ""}}

    local instance = Matrix(3, 3, Constants.MatrixType.STRING)
    assert.are.same(instance:getTable(), expected)
  end)

  it("Creates new matrix with table elements", function()
    local expected = {{{}, {}, {}},
                      {{}, {}, {}},
                      {{}, {}, {}}}

    local instance = Matrix(3, 3, Constants.MatrixType.TABLE)
    assert.are.same(instance:getTable(), expected)
  end)

  it("Creates new matrix with function elements", function()
    local instance = Matrix(3, 3, Constants.MatrixType.FUNCTION)
    local f = instance._data[1][1]
    local expected = {{f, f, f},
                      {f, f, f},
                      {f, f, f}}

    assert.are.same(instance:getTable(), expected)
  end)

  it("Creates new matrix with diferent initial value", function()
    local expected = {{2, 2, 2},
                      {2, 2, 2},
                      {2, 2, 2}}

    local instance = Matrix(3, 3, Constants.MatrixType.NUMBER, 2)
    assert.are.same(instance:getTable(), expected)
  end)

  it("Checks invalid value in a number matrix", function()
    local test_error = function()
      local instance = Matrix(3, 3, Constants.MatrixType.NUMBER)
      instance:setCell(1, 1, 'hi')
    end

    assert.has.error(test_error, "bad argument #3 (number expected, got string)")
  end)

  it("Checks invalid value in a string matrix", function()
    local test_error = function()
      local instance = Matrix(3, 3, Constants.MatrixType.STRING)
      instance:setCell(1, 1, 0)
    end

    assert.has.error(test_error, "bad argument #3 (string expected, got number)")
  end)

  it("Checks invalid value in a boolean matrix", function()
    local test_error = function()
      local instance = Matrix(3, 3, Constants.MatrixType.BOOLEAN)
      instance:setCell(1, 1, 0)
    end

    assert.has.error(test_error, "bad argument #3 (boolean expected, got number)")
  end)

  it("Checks invalid value in a function matrix", function()
    local test_error = function()
      local instance = Matrix(3, 3, Constants.MatrixType.FUNCTION)
      instance:setCell(1, 1, 0)
    end

    assert.has.error(test_error, "bad argument #3 (function expected, got number)")
  end)

  it("Checks invalid value in a table matrix", function()
    local test_error = function()
      local instance = Matrix(3, 3, Constants.MatrixType.TABLE)
      instance:setCell(1, 1, 0)
    end

    assert.has.error(test_error, "bad argument #3 (table expected, got number)")
  end)

  it("Checks if setCell works", function()
    local instance = Matrix(3, 3)
    instance:setCell(2, 2, 10)
    assert.are.equals(instance:getCell(2, 2), 10)
  end)

  it("Invalid greater position on getPos", function()
    local test_error = function()
      local instance = Matrix(3, 3)
      instance:getPos(12)
    end

    assert.has.error(test_error, "bad argument #1 (must be less or equals that 9)")
  end)

  it("Invalid negative position on getPos", function()
    local test_error = function()
      local instance = Matrix(3, 3)
      instance:getPos(-4)
    end

    assert.has.error(test_error, "bad argument #1 (must be greater than zero)")
  end)

  it("Checks if getPos works", function()
    local instance = Matrix(3, 3)
    instance:setCell(2, 2, 10)
    assert.are.equals(instance:getPos(4), 10)
  end)

  it("Checks if setPos works", function()
    local instance = Matrix(3, 3)
    instance:setPos(5, 10)
    assert.are.equals(instance:getPos(5), 10)
  end)

  it("Checks if tostring works", function()
    local instance = Matrix(3, 3)
    local result = "{{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}"
    assert.are.equals(tostring(instance), result)
  end)
end)
