describe("Map Model", function()
  local map = require "main.model.map"

  it("Checks invalid row number", function()
    local invalid_row = function()
      local obj = map:new(0, 0)
    end

    assert.has_error(invalid_row, "bad argument #1, must be greater than zero")
  end)

  it("Checks invalid column number", function()
    local invalid_row = function()
      local obj = map:new(10, 0)
    end

    assert.has_error(invalid_row, "bad argument #2, must be greater than zero")
  end)

  it("Checks create new map", function()
    local expected = {{0, 0, 0},
                      {0, 0, 0},
                      {0, 0, 0}}

    local obj = map:new(3, 3)

    assert.are.same(obj:getMap(), expected)
  end)
end)
