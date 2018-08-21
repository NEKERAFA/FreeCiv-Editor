-- Rafael Alcalde Azpiazu - 7 Aug 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local Class = require "libs.hump.class"
local Constants = require "main.utilities.constants"

--- This class defines a adapter class to connect the map model and the tilemap.
-- @classmod MapAdapter
local MapAdapter = Class {
  --- Creates new adapter object.
  -- @param self The new adapter object.
  -- @param map A map object. @see model/map.lua.
  -- @param quads_info A table with the quad representation of the tiles.
  -- @param tilemap A SpriteBatch LÖVE object that represents the tilemap to draw.
  -- @param background A SpriteBatch LÖVE object that represents the sea background.
  init = function (self, map, quads_info, tilemap, background)
    self._map = map
    self._quads_info = quads_info

    self._tilemap = {
      sb = tilemap,
      index = {}
    }

    self._background = {
      sb = background,
      index = {}
    }
  end,

  --- This function gets all the neighbours.
  -- @param self A adapter object.
  -- @param row A number that represents the row of the cell.
  -- @param col A number that represents the column of the cell.
  _getNeighbours = function(self, row, col)
    -- This list stores all neighbour position
    local list = {}

    -- Loops all 8-conected cell positions
    local neighbour_i = 1
    -- Center the neighbours if the cell is in the corner or in the upper of
    -- the map
    if row == 1 then
      neighbour_i = 2
    end
    for i = math.max(1, row-1), math.min(row+1, self._map.rows) do
      -- Center the neighbours if the cell is in the corner or in the left of
      -- the map
      local neighbour_j = 1
      if col == 1 then
        neighbour_j = 2
      end
      for j = math.max(1, col-1), math.min(col+1, self._map.cols) do
        -- Inserts only if the current position isn't the root cell
        if row ~= i or col ~= j then
          list[neighbour_j+(neighbour_i-1)*3] = {row = i, col = j}
        end
        neighbour_j = neighbour_j+1
      end
      neighbour_i = neighbour_i+1
    end

    return list
  end,

  _isSingleLand = function(self, neighbours, type)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    local function f(type)
      return ((not upper) or (self._map:getCell(upper.row, upper.col) ~= type)) and
             ((not left) or (self._map:getCell(left.row, left.col) ~= type)) and
             ((not right) or (self._map:getCell(right.row, right.col) ~= type)) and
             ((not bottom) or (self._map:getCell(bottom.row, bottom.col) ~= type))
    end

    if type == Constants.CellType.SEA or type == Constants.CellType.OCEAN then
      return f(Constants.CellType.SEA) or f(Constants.CellType.OCEAN)
    end

    return f(type)
  end,

  _isUpperLand = function(self, neighbours, type)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    local function f(type)
      return upper and (self._map:getCell(upper.row, upper.col) == type) and
             ((not left) or (self._map:getCell(left.row, left.col) ~= type)) and
             ((not right) or (self._map:getCell(right.row, right.col) ~= type)) and
             ((not bottom) or (self._map:getCell(bottom.row, bottom.col) ~= type))
    end

    if type == Constants.CellType.SEA or type == Constants.CellType.OCEAN then
      return f(Constants.CellType.SEA) or f(Constants.CellType.OCEAN)
    end

    return f(type)
  end,

  _isLeftLand = function(self, neighbours, type)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    local function f(type)
      return left and (self._map:getCell(left.row, left.col) == type) and
             ((not upper) or (self._map:getCell(upper.row, upper.col) ~= type)) and
             ((not right) or (self._map:getCell(right.row, right.col) ~= type)) and
             ((not bottom) or (self._map:getCell(bottom.row, bottom.col) ~= type))
    end

    if type == Constants.CellType.SEA or type == Constants.CellType.OCEAN then
      return f(Constants.CellType.SEA) or f(Constants.CellType.OCEAN)
    end

    return f(type)
  end,

  _isRightLand = function(self, neighbours, type)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    local function f(type)
      return right and (self._map:getCell(right.row, right.col) == type) and
             ((not left) or (self._map:getCell(left.row, left.col) ~= type)) and
             ((not upper) or (self._map:getCell(upper.row, upper.col) ~= type)) and
             ((not bottom) or (self._map:getCell(bottom.row, bottom.col) ~= type))
    end

    if type == Constants.CellType.SEA or type == Constants.CellType.OCEAN then
      return f(Constants.CellType.SEA) or f(Constants.CellType.OCEAN)
    end

    return f(type)
  end,

  _isBottomLand = function(self, neighbours, type)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    local function f(type)
      return bottom and (self._map:getCell(bottom.row, bottom.col) == type) and
             ((not left) or (self._map:getCell(left.row, left.col) ~= type)) and
             ((not right) or (self._map:getCell(right.row, right.col) ~= type)) and
             ((not upper) or (self._map:getCell(upper.row, upper.col) ~= type))
    end

    if type == Constants.CellType.SEA or type == Constants.CellType.OCEAN then
      return f(Constants.CellType.SEA) or f(Constants.CellType.OCEAN)
    end

    return f(type)
  end,

  _isUpperLeftLand = function(self, neighbours, type)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    local function f(type)
      return upper and (self._map:getCell(upper.row, upper.col) == type) and
             left and (self._map:getCell(left.row, left.col) == type) and
             ((not right) or (self._map:getCell(right.row, right.col) ~= type)) and
             ((not bottom) or (self._map:getCell(bottom.row, bottom.col) ~= type))
    end

    if type == Constants.CellType.SEA or type == Constants.CellType.OCEAN then
      return f(Constants.CellType.SEA) or f(Constants.CellType.OCEAN)
    end

    return f(type)
  end,

  _isUpperRightLand = function(self, neighbours, type)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    local function f(type)
      return upper and (self._map:getCell(upper.row, upper.col) == type) and
             right and (self._map:getCell(right.row, right.col) == type) and
             ((not left) or (self._map:getCell(left.row, left.col) ~= type)) and
             ((not bottom) or (self._map:getCell(bottom.row, bottom.col) ~= type))
    end

    if type == Constants.CellType.SEA or type == Constants.CellType.OCEAN then
      return f(Constants.CellType.SEA) or f(Constants.CellType.OCEAN)
    end

    return f(type)
  end,

  _isUpperBottomLand = function(self, neighbours, type)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    local function f(type)
      return upper and (self._map:getCell(upper.row, upper.col) == type) and
             bottom and (self._map:getCell(bottom.row, bottom.col) == type) and
             ((not left) or (self._map:getCell(left.row, left.col) ~= type)) and
             ((not right) or (self._map:getCell(right.row, right.col) ~= type))
    end

    if type == Constants.CellType.SEA or type == Constants.CellType.OCEAN then
      return f(Constants.CellType.SEA) or f(Constants.CellType.OCEAN)
    end

    return f(type)
  end,

  _isBottomLeftLand = function(self, neighbours, type)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    local function f(type)
      return bottom and (self._map:getCell(bottom.row, bottom.col) == type) and
             left and (self._map:getCell(left.row, left.col) == type) and
             ((not right) or (self._map:getCell(right.row, right.col) ~= type)) and
             ((not upper) or (self._map:getCell(upper.row, upper.col) ~= type))
    end

    if type == Constants.CellType.SEA or type == Constants.CellType.OCEAN then
      return f(Constants.CellType.SEA) or f(Constants.CellType.OCEAN)
    end

    return f(type)
  end,

  _isBottomRightLand = function(self, neighbours, type)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    local function f(type)
      return right and (self._map:getCell(right.row, right.col) == type) and
             bottom and (self._map:getCell(bottom.row, bottom.col) == type) and
             ((not upper) or (self._map:getCell(upper.row, upper.col) ~= type)) and
             ((not left) or (self._map:getCell(left.row, left.col) ~= type))
    end

    if type == Constants.CellType.SEA or type == Constants.CellType.OCEAN then
      return f(Constants.CellType.SEA) or f(Constants.CellType.OCEAN)
    end

    return f(type)
  end,

  _isLeftRightLand = function(self, neighbours, type)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    local function f(type)
      return left and (self._map:getCell(left.row, left.col) == type) and
             right and (self._map:getCell(right.row, right.col) == type) and
             ((not upper) or (self._map:getCell(upper.row, upper.col) ~= type)) and
             ((not bottom) or (self._map:getCell(bottom.row, bottom.col) ~= type))
    end

    if type == Constants.CellType.SEA or type == Constants.CellType.OCEAN then
      return f(Constants.CellType.SEA) and f(Constants.CellType.OCEAN)
    end

    return f(type)
  end,

  _isUpperLeftRightLand = function(self, neighbours, type)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    local function f(type)
      return upper and (self._map:getCell(upper.row, upper.col) == type) and
             left and (self._map:getCell(left.row, left.col) == type) and
             right and (self._map:getCell(right.row, right.col) == type) and
             ((not bottom) or (self._map:getCell(bottom.row, bottom.col) ~= type))
    end

    if type == Constants.CellType.SEA or type == Constants.CellType.OCEAN then
      return f(Constants.CellType.SEA) or f(Constants.CellType.OCEAN)
    end

    return f(type)
  end,

  _isUpperLeftBottomLand = function(self, neighbours, type)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    local function f(type)
      return upper and (self._map:getCell(upper.row, upper.col) == type) and
             left and (self._map:getCell(left.row, left.col) == type) and
             bottom and (self._map:getCell(bottom.row, bottom.col) == type) and
             ((not right) or (self._map:getCell(right.row, right.col) ~= type))
    end

    if type == Constants.CellType.SEA or type == Constants.CellType.OCEAN then
      return f(Constants.CellType.SEA) or f(Constants.CellType.OCEAN)
    end

    return f(type)
  end,

  _isUpperRightBottomLand = function(self, neighbours, type)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    local function f(type)
      return upper and (self._map:getCell(upper.row, upper.col) == type) and
             right and (self._map:getCell(right.row, right.col) == type) and
             bottom and (self._map:getCell(bottom.row, bottom.col) == type) and
             ((not left) or (self._map:getCell(left.row, left.col) ~= type))
    end

    if type == Constants.CellType.SEA or type == Constants.CellType.OCEAN then
      return f(Constants.CellType.SEA) or f(Constants.CellType.OCEAN)
    end

    return f(type)
  end,

  _isBottomLeftRightLand = function(self, neighbours, type)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    local function f(type)
      return bottom and (self._map:getCell(bottom.row, bottom.col) == type) and
             left and (self._map:getCell(left.row, left.col) == type) and
             right and (self._map:getCell(right.row, right.col) == type) and
             ((not upper) or (self._map:getCell(upper.row, upper.col) ~= type))
    end

    if type == Constants.CellType.SEA then
      return f(Constants.CellType.SEA) or f(Constants.CellType.OCEAN)
    end

    return f(type)
  end,

  _isSurroundedLand = function(self, neighbours, type)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    local function f(type)
      return upper and (self._map:getCell(upper.row, upper.col) == type) and
             left and (self._map:getCell(left.row, left.col) == type) and
             right and (self._map:getCell(right.row, right.col) == type) and
             bottom and (self._map:getCell(bottom.row, bottom.col) == type)
    end

    if type == Constants.CellType.SEA or type == Constants.CellType.OCEAN then
      return f(Constants.CellType.SEA) or f(Constants.CellType.OCEAN)
    end

    return f(type)
  end,

  -- This function adds a water cellGuionistas y/o directores to the tilemap
  _addWaterCell = function(self, row, col, neighbours, type)
    -- Calculates the position of the current tile
    local x = self._quads_info.size * (col-1)
    local y = self._quads_info.size * (row-1)
    local water_size = self._quads_info.size / 2
    local quads = self._quads_info.quads

    if type ~= Constants.CellType.OCEAN then
      type = Constants.CellType.SEA
    end

    -- Gets the water quad tiles
    local quad_upper_left = quads[type][Constants.TilePosition.UPPER_LEFT]
    local quad_upper_right = quads[type][Constants.TilePosition.UPPER_RIGHT]
    local quad_bottom_left = quads[type][Constants.TilePosition.BOTTOM_LEFT]
    local quad_bottom_right = quads[type][Constants.TilePosition.BOTTOM_RIGHT]

    -- Checks if exists a row index of the tilemap
    if not self._background.index[row*2] then
      self._background.index[row*2] = {}
    end

    if not self._background.index[row*2+1] then
      self._background.index[row*2+1] = {}
    end

    -- Checks if exists a column index of the tilemap
    if not self._background.index[row*2][col*2] then
      self._background.index[row*2][col*2] = self._background.sb:add(quad_upper_right, x, y)
    -- Update the tilemap index
    else
      self._background.sb:set(self._background.index[row*2][col*2], quad_upper_right, x, y)
    end

    -- Checks if exists a column index of the tilemap
    if not self._background.index[row*2][col*2+1] then
      self._background.index[row*2][col*2+1] = self._background.sb:add(quad_upper_left, x, y+water_size)
    -- Update the tilemap index
    else
      self._background.sb:set(self._background.index[row*2][col*2+1], quad_upper_left, x, y+water_size)
    end

    -- Checks if exists a column index of the tilemap
    if not self._background.index[row*2+1][col*2] then
      self._background.index[row*2+1][col*2] = self._background.sb:add(quad_bottom_right, x+water_size, y)
    -- Update the tilemap index
    else
      self._background.sb:set(self._background.index[row*2+1][col*2], quad_bottom_right, x+water_size, y)
    end

    -- Checks if exists a column index of the tilemap
    if not self._background.index[row*2+1][col*2+1] then
      self._background.index[row*2+1][col*2+1] = self._background.sb:add(quad_bottom_left, x+water_size, y+water_size)
    -- Update the tilemap index
    else
      self._background.sb:set(self._background.index[row*2+1][col*2+1], quad_bottom_left, x+water_size, y+water_size)
    end
  end,

  -- This function add a land cell to the tilemap
  _addLandCell = function(self, row, col, neighbours, type)
    -- Calculates position tile
    local x = self._quads_info.size * (col-1)
    local y = self._quads_info.size * (row-1)
    local quad = nil
    local quads = self._quads_info.quads

    -- Draws a grass or a void cell
    if type == Constants.CellType.GRASS or type == Constants.CellType.VOID or
       type == Constants.CellType.GLACIER or type == Constants.CellType.MOUNTAIN or
       type == Constants.CellType.FOREST or type == Constants.CellType.LAKE then
      quad = quads[type]
    -- Draws a plain, jungle, trunda, swamp or desert cell
    elseif type == Constants.CellType.PLAIN or type == Constants.CellType.JUNGLE or
           type == Constants.CellType.TRUNDA or type == Constants.CellType.SWAMP or
           type == Constants.CellType.DESERT then
      local pos = ""
      if self:_isSurroundedLand(neighbours, type) then
        pos = Constants.TilePosition.SURROUNDED
      elseif self:_isUpperLand(neighbours, type) then
        pos = Constants.TilePosition.BOTTOM_LEFT_RIGHT
      elseif self:_isLeftLand(neighbours, type) then
        pos = Constants.TilePosition.UPPER_RIGHT_BOTTOM
      elseif self:_isRightLand(neighbours, type) then
        pos = Constants.TilePosition.UPPER_LEFT_BOTTOM
      elseif self:_isBottomLand(neighbours, type) then
        pos = Constants.TilePosition.UPPER_LEFT_RIGHT
      elseif self:_isUpperLeftLand(neighbours, type) then
        pos = Constants.TilePosition.BOTTOM_RIGHT
      elseif self:_isUpperRightLand(neighbours, type) then
        pos = Constants.TilePosition.BOTTOM_LEFT
      elseif self:_isUpperBottomLand(neighbours, type) then
        pos = Constants.TilePosition.LEFT_RIGHT
      elseif self:_isLeftRightLand(neighbours, type) then
        pos = Constants.TilePosition.UPPER_BOTTOM
      elseif self:_isBottomLeftLand(neighbours, type) then
        pos = Constants.TilePosition.UPPER_RIGHT
      elseif self:_isBottomRightLand(neighbours, type) then
        pos = Constants.TilePosition.UPPER_LEFT
      elseif self:_isUpperLeftRightLand(neighbours, type) then
        pos = Constants.TilePosition.BOTTOM
      elseif self:_isUpperLeftBottomLand(neighbours, type) then
        pos = Constants.TilePosition.RIGHT
      elseif self:_isUpperRightBottomLand(neighbours, type) then
        pos = Constants.TilePosition.LEFT
      elseif self:_isBottomLeftRightLand(neighbours, type) then
        pos = Constants.TilePosition.UPPER
      elseif self:_isSingleLand(neighbours, type) then
        pos = Constants.TilePosition.SINGLE
      end

      quad = quads[type][pos]
    else
      quad = quads[Constants.TileType.BLANK]
    end

    -- Checks if exists a row index of the tilemap
    if not self._tilemap.index[row] then
      self._tilemap.index[row] = {}
    end

    -- Checks if exists a column index of the tilemap
    if not self._tilemap.index[row][col] then
      self._tilemap.index[row][col] = self._tilemap.sb:add(quad, x, y)
    -- Update the tilemap index
    else
      self._tilemap.sb:set(self._tilemap.index[row][col], quad, x, y)
    end
  end,

  --- Changes a cell in the map and/or in the tilemap
  setCell = function (self, row, col, type)
    -- Update the map
    self._map:setCell(row, col, type)

    -- Gets all the neighbours of the cell
    local neighbours = self:_getNeighbours(row, col)

    -- Update all the neighbours of the cell
    for i, neighbour in pairs(neighbours) do
      local type = self._map:getCell(neighbour.row, neighbour.col)
      local neighbours = self:_getNeighbours(neighbour.row, neighbour.col)
      self:_addWaterCell(neighbour.row, neighbour.col, neighbours, type)
      self:_addLandCell(neighbour.row, neighbour.col, neighbours, type)
    end

    -- Update the cell in the tilemap
    self:_addWaterCell(row, col, neighbours, type)
    self:_addLandCell(row, col, neighbours, type)
  end,

  -- Iterates all map an changes all the tilemap
  setTilemap = function (self)
    for row = 1, self._map.rows do
      for col = 1, self._map.cols do
        -- Gets a cell in the map
        local type = self._map:getCell(row, col)

        -- Gets all the neighbours of the cell
        local neighbours = self:_getNeighbours(row, col)

        -- Update the cell in the tilemap
        self:_addWaterCell(row, col, neighbours, type)
        self:_addLandCell(row, col, neighbours, type)
      end
    end
  end
}

return MapAdapter
