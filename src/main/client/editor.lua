-- Rafael Alcalde Azpiazu - 19 Apr 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local Class = require "libs.hump.class"
local Map = require "main.model.map"
local Constants = require "main.utilities.constants"
local Validator = require "main.utilities.validator"
local Resources = require "main.utilities.resources"

-- Constants
local _SELECTOR_CELL = "selector"
local _LAND_CELL = "land"
local _EMPTY_LAND_CELL = "empty"
local _UPPER_LAND_CELL = "upper_land"
local _BOTTOM_LAND_CELL = "bottom_land"
local _LEFT_LAND_CELL = "left_land"
local _RIGHT_LAND_CELL = "right_land"
local _UPPER_LEFT_LAND_CELL = "upper_left_land"
local _UPPER_RIGHT_LAND_CELL = "upper_right_land"
local _UPPER_BOTTOM_LAND_CELL = "upper_bottom_land"
local _BOTTOM_RIGHT_LAND_CELL = "bottom_right_land"
local _BOTTOM_LEFT_LAND_CELL = "bottom_left_land"
local _LEFT_RIGHT_LAND_CELL = "left_right_land"
local _UPPER_LEFT_RIGHT_LAND_CELL = "upper_left_right_land"
local _UPPER_LEFT_BOTTOM_LAND_CELL = "upper_left_bottom_land"
local _UPPER_RIGHT_BOTTOM_LAND_CELL = "upper_right_bottom_land"
local _BOTTOM_LEFT_RIGHT_LAND_CELL = "bottom_left_right_land"
local _SURROUNDED_LAND_CELL = "surrounded_land"
local _VOID_CELL = "void_land"
local _WATER_UPPER_LEFT_CELL = "water_upper_left"
local _WATER_UPPER_RIGHT_CELL = "water_upper_right"
local _WATER_BOTTOM_LEFT_CELL = "water_bottom_left"
local _WATER_BOTTOM_RIGHT_CELL = "water_bottom_right"
local _WATER_LAND_UPPER_LEFT_CELL = "water_land_upper_left"
local _WATER_LAND_UPPER_RIGHT_CELL = "water_land_upper_right"
local _WATER_LAND_BOTTOM_LEFT_CELL = "water_land_bottom_left"
local _WATER_LAND_BOTTOM_RIGHT_CELL = "water_land_bottom_right"

--- This class represents a UI Map Editor for FreeCiv
local Editor = Class {
  -- Creates a new editor
  init = function(self)
    -- Offset of the map UI
    self.offset = {x = 10, y = 34}

    -- Loads the tileset image
    self._tile_image = Resources.loadResource("image", "tiles")

    -- Creates all the quads of tiles
    self._quads_info = {size = 30, quads = {}}
    self:_setQuads(self._tile_image:getWidth(), self._tile_image:getHeight())

    -- Checks if editor has a configuration
    if Resources.existConfiguration("editor") then
      -- Loads last map opened
      local conf = Resources.loadConfiguration("editor")
      local map = Resources.loadResource("map", conf.lastOpened)

      self._map = Map(map)

      -- Creates the tilemap and the background
      self._tilemap = love.graphics.newSpriteBatch(self._tile_image, self._map.rows * self._map.cols)
      self._background = love.graphics.newSpriteBatch(self._tile_image, self._map.rows * self._map.cols * 4)

      -- Sets all the tilemaps in the spritesbatches
      self:_updateTilemap()
    else
      self._map = nil
    end

    self._current_tile = nil
    self._pressed = nil
  end,

  getWidth = function(self)
    if self._map == nil then
      return 0
    end

    return self._map.cols * self._quads_info.size
  end,

  getHeight = function(self)
    if self._map == nil then
      return 0
    end

    return self._map.rows * self._quads_info.size
  end,

  newMap = function(self, rows, cols)
    self._map = Map(rows, cols)

    -- Creates the tilemap and the background
    self._tilemap = love.graphics.newSpriteBatch(self._tile_image, self._map.rows * self._map.cols)
    self._background = love.graphics.newSpriteBatch(self._tile_image, self._map.rows * self._map.cols * 4)

    -- Sets all the tilemaps in the spritesbatches
    self:_updateTilemap()
  end,

  setMap = function(self, map)
    self._map = Map(map)

    -- Creates the tilemap and the background
    self._tilemap = love.graphics.newSpriteBatch(self._tile_image, self._map.rows * self._map.cols)
    self._background = love.graphics.newSpriteBatch(self._tile_image, self._map.rows * self._map.cols * 4)

    -- Sets all the tilemaps in the spritesbatches
    self:_updateTilemap()
  end,

  -- This function sets the quads for create the tilemap
  _setQuads = function(self, tilesWidth, tilesHeight)
    local quads = self._quads_info.quads

    -- Quad for tile selector
    quads[_SELECTOR_CELL] = love.graphics.newQuad(330, 480, 30, 30, tilesWidth, tilesHeight)

    -- Quad for water
    quads[_WATER_UPPER_LEFT_CELL] = love.graphics.newQuad(240, 210, 15, 15, tilesWidth, tilesHeight)
    quads[_WATER_LAND_UPPER_LEFT_CELL] = love.graphics.newQuad(255, 210, 15, 15, tilesWidth, tilesHeight)
    quads[_WATER_UPPER_RIGHT_CELL] = love.graphics.newQuad(270, 210, 15, 15, tilesWidth, tilesHeight)
    quads[_WATER_LAND_UPPER_RIGHT_CELL] = love.graphics.newQuad(285, 210, 15, 15, tilesWidth, tilesHeight)
    quads[_WATER_BOTTOM_LEFT_CELL] = love.graphics.newQuad(300, 210, 15, 15, tilesWidth, tilesHeight)
    quads[_WATER_LAND_BOTTOM_LEFT_CELL] = love.graphics.newQuad(315, 210, 15, 15, tilesWidth, tilesHeight)
    quads[_WATER_BOTTOM_RIGHT_CELL] = love.graphics.newQuad(330, 210, 15, 15, tilesWidth, tilesHeight)
    quads[_WATER_LAND_BOTTOM_RIGHT_CELL] = love.graphics.newQuad(345, 210, 15, 15, tilesWidth, tilesHeight)

    -- Quads for land
    quads[_LAND_CELL] = love.graphics.newQuad(60, 0, 30, 30, tilesWidth, tilesHeight)
    quads[_EMPTY_LAND_CELL] = love.graphics.newQuad(0, 300, 30, 30, tilesWidth, tilesHeight)
    quads[_UPPER_LAND_CELL] = love.graphics.newQuad(30, 300, 30, 30, tilesWidth, tilesHeight)
    quads[_RIGHT_LAND_CELL] = love.graphics.newQuad(60, 300, 30, 30, tilesWidth, tilesHeight)
    quads[_UPPER_RIGHT_LAND_CELL] = love.graphics.newQuad(90, 300, 30, 30, tilesWidth, tilesHeight)
    quads[_BOTTOM_LAND_CELL] = love.graphics.newQuad(120, 300, 30, 30, tilesWidth, tilesHeight)
    quads[_UPPER_BOTTOM_LAND_CELL] = love.graphics.newQuad(150, 300, 30, 30, tilesWidth, tilesHeight)
    quads[_BOTTOM_RIGHT_LAND_CELL] = love.graphics.newQuad(180, 300, 30, 30, tilesWidth, tilesHeight)
    quads[_UPPER_RIGHT_BOTTOM_LAND_CELL] = love.graphics.newQuad(210, 300, 30, 30, tilesWidth, tilesHeight)
    quads[_LEFT_LAND_CELL] = love.graphics.newQuad(240, 300, 30, 30, tilesWidth, tilesHeight)
    quads[_UPPER_LEFT_LAND_CELL] = love.graphics.newQuad(270, 300, 30, 30, tilesWidth, tilesHeight)
    quads[_LEFT_RIGHT_LAND_CELL] = love.graphics.newQuad(300, 300, 30, 30, tilesWidth, tilesHeight)
    quads[_UPPER_LEFT_RIGHT_LAND_CELL] = love.graphics.newQuad(330, 300, 30, 30, tilesWidth, tilesHeight)
    quads[_BOTTOM_LEFT_LAND_CELL] = love.graphics.newQuad(360, 300, 30, 30, tilesWidth, tilesHeight)
    quads[_UPPER_LEFT_BOTTOM_LAND_CELL] = love.graphics.newQuad(390, 300, 30, 30, tilesWidth, tilesHeight)
    quads[_BOTTOM_LEFT_RIGHT_LAND_CELL] = love.graphics.newQuad(420, 300, 30, 30, tilesWidth, tilesHeight)
    quads[_SURROUNDED_LAND_CELL] = love.graphics.newQuad(450, 300, 30, 30, tilesWidth, tilesHeight)

    -- Quad for void
    quads[_VOID_CELL] = love.graphics.newQuad(90, 0, 30, 30, tilesWidth, tilesHeight)
  end,

  -- This function gets all the neighbours
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

  _isUpperLeftLand = function(self, neighbours)
    local corner = neighbours[1]
    local upper = neighbours[2]
    local left = neighbours[4]

    return corner and (self._map:getCell(corner.row, corner.col) == Constants.CellType.LAND_CELL) and
           ((not left) or (self._map:getCell(left.row, left.col) ~= Constants.CellType.LAND_CELL)) and
           ((not upper) or (self._map:getCell(upper.row, upper.col) ~= Constants.CellType.LAND_CELL))
  end,

  _isUpperRightLand = function(self, neighbours)
    local corner = neighbours[3]
    local upper = neighbours[2]
    local right = neighbours[6]

    return corner and (self._map:getCell(corner.row, corner.col) == Constants.CellType.LAND_CELL) and
           ((not right) or (self._map:getCell(right.row, right.col) ~= Constants.CellType.LAND_CELL)) and
           ((not upper) or (self._map:getCell(upper.row, upper.col) ~= Constants.CellType.LAND_CELL))
  end,

  _isBottomLeftLand = function(self, neighbours)
    local corner = neighbours[7]
    local bottom = neighbours[8]
    local left = neighbours[4]

    return corner and (self._map:getCell(corner.row, corner.col) == Constants.CellType.LAND_CELL) and
           ((not left) or (self._map:getCell(left.row, left.col) ~= Constants.CellType.LAND_CELL)) and
           ((not upper) or (self._map:getCell(bottom.row, bottom.col) ~= Constants.CellType.LAND_CELL))
  end,

  _isBottomRightLand = function(self, neighbours)
    local corner = neighbours[9]
    local bottom = neighbours[8]
    local right = neighbours[6]

    return corner and (self._map:getCell(corner.row, corner.col) == Constants.CellType.LAND_CELL) and
           ((not right) or (self._map:getCell(right.row, right.col) ~= Constants.CellType.LAND_CELL)) and
           ((not bottom) or (self._map:getCell(bottom.row, bottom.col) ~= Constants.CellType.LAND_CELL))
  end,

  -- This function adds a water cell to the tilemap
  _addWaterCell = function(self, row, col, water_size, neighbours)
    -- Calculates the position of the current tile
    local x = self._quads_info.size * (col-1)
    local y = self._quads_info.size * (row-1)

    -- Gets the water quad tiles
    local quad_upper_left = self._quads_info.quads[_WATER_UPPER_LEFT_CELL]
    local quad_upper_right = self._quads_info.quads[_WATER_UPPER_RIGHT_CELL]
    local quad_bottom_left = self._quads_info.quads[_WATER_BOTTOM_LEFT_CELL]
    local quad_bottom_right = self._quads_info.quads[_WATER_BOTTOM_RIGHT_CELL]

    -- Checks if one of the corners has land
    if self._map:getCell(row, col) ~= Constants.CellType.LAND_CELL then
      if self:_isUpperLeftLand(neighbours) then
        quad_upper_left = self._quads_info.quads[_WATER_LAND_UPPER_LEFT_CELL]
      end

      if self:_isUpperRightLand(neighbours) then
        quad_upper_right = self._quads_info.quads[_WATER_LAND_UPPER_RIGHT_CELL]
      end

      if self:_isBottomLeftLand(neighbours) then
        quad_bottom_left = self._quads_info.quads[_WATER_LAND_BOTTOM_LEFT_CELL]
      end

      if self:_isBottomRightLand(neighbours) then
        quad_bottom_right = self._quads_info.quads[_WATER_LAND_BOTTOM_RIGHT_CELL]
      end
    end

    -- Sets water
    self._background:add(quad_upper_left, x, y)
    self._background:add(quad_upper_right, x+water_size, y)
    self._background:add(quad_bottom_left, x, y+water_size)
    self._background:add(quad_bottom_right, x+water_size, y+water_size)
  end,

  _isWaterUpperLand = function(self, neighbours)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    return upper and (self._map:getCell(upper.row, upper.col) == Constants.CellType.LAND_CELL) and
           ((not left) or (self._map:getCell(left.row, left.col) ~= Constants.CellType.LAND_CELL)) and
           ((not right) or (self._map:getCell(right.row, right.col) ~= Constants.CellType.LAND_CELL)) and
           ((not bottom) or (self._map:getCell(bottom.row, bottom.col) ~= Constants.CellType.LAND_CELL))
  end,

  _isWaterLeftLand = function(self, neighbours)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    return left and (self._map:getCell(left.row, left.col) == Constants.CellType.LAND_CELL) and
           ((not upper) or (self._map:getCell(upper.row, upper.col) ~= Constants.CellType.LAND_CELL)) and
           ((not right) or (self._map:getCell(right.row, right.col) ~= Constants.CellType.LAND_CELL)) and
           ((not bottom) or (self._map:getCell(bottom.row, bottom.col) ~= Constants.CellType.LAND_CELL))
  end,

  _isWaterRightLand = function(self, neighbours)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    return right and (self._map:getCell(right.row, right.col) == Constants.CellType.LAND_CELL) and
           ((not left) or (self._map:getCell(left.row, left.col) ~= Constants.CellType.LAND_CELL)) and
           ((not upper) or (self._map:getCell(upper.row, upper.col) ~= Constants.CellType.LAND_CELL)) and
           ((not bottom) or (self._map:getCell(bottom.row, bottom.col) ~= Constants.CellType.LAND_CELL))
  end,

  _isWaterBottomLand = function(self, neighbours)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    return bottom and (self._map:getCell(bottom.row, bottom.col) == Constants.CellType.LAND_CELL) and
           ((not left) or (self._map:getCell(left.row, left.col) ~= Constants.CellType.LAND_CELL)) and
           ((not right) or (self._map:getCell(right.row, right.col) ~= Constants.CellType.LAND_CELL)) and
           ((not upper) or (self._map:getCell(upper.row, upper.col) ~= Constants.CellType.LAND_CELL))
  end,

  _isWaterUpperLeftLand = function(self, neighbours)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    return upper and (self._map:getCell(upper.row, upper.col) == Constants.CellType.LAND_CELL) and
           left and (self._map:getCell(left.row, left.col) == Constants.CellType.LAND_CELL) and
           ((not right) or (self._map:getCell(right.row, right.col) ~= Constants.CellType.LAND_CELL)) and
           ((not bottom) or (self._map:getCell(bottom.row, bottom.col) ~= Constants.CellType.LAND_CELL))
  end,

  _isWaterUpperRightLand = function(self, neighbours)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    return upper and (self._map:getCell(upper.row, upper.col) == Constants.CellType.LAND_CELL) and
           right and (self._map:getCell(right.row, right.col) == Constants.CellType.LAND_CELL) and
           ((not left) or (self._map:getCell(left.row, left.col) ~= Constants.CellType.LAND_CELL)) and
           ((not bottom) or (self._map:getCell(bottom.row, bottom.col) ~= Constants.CellType.LAND_CELL))
  end,

  _isWaterUpperBottomLand = function(self, neighbours)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    return upper and (self._map:getCell(upper.row, upper.col) == Constants.CellType.LAND_CELL) and
           bottom and (self._map:getCell(bottom.row, bottom.col) == Constants.CellType.LAND_CELL) and
           ((not left) or (self._map:getCell(left.row, left.col) ~= Constants.CellType.LAND_CELL)) and
           ((not right) or (self._map:getCell(right.row, right.col) ~= Constants.CellType.LAND_CELL))
  end,

  _isWaterBottomLeftLand = function(self, neighbours)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    return bottom and (self._map:getCell(bottom.row, bottom.col) == Constants.CellType.LAND_CELL) and
           left and (self._map:getCell(left.row, left.col) == Constants.CellType.LAND_CELL) and
           ((not right) or (self._map:getCell(right.row, right.col) ~= Constants.CellType.LAND_CELL)) and
           ((not upper) or (self._map:getCell(upper.row, upper.col) ~= Constants.CellType.LAND_CELL))
  end,

  _isWaterBottomRightLand = function(self, neighbours)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    return right and (self._map:getCell(right.row, right.col) == Constants.CellType.LAND_CELL) and
           bottom and (self._map:getCell(bottom.row, bottom.col) == Constants.CellType.LAND_CELL) and
           ((not upper) or (self._map:getCell(upper.row, upper.col) ~= Constants.CellType.LAND_CELL)) and
           ((not left) or (self._map:getCell(left.row, left.col) ~= Constants.CellType.LAND_CELL))
  end,

  _isWaterLeftRightLand = function(self, neighbours)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    return left and (self._map:getCell(left.row, left.col) == Constants.CellType.LAND_CELL) and
           right and (self._map:getCell(right.row, right.col) == Constants.CellType.LAND_CELL) and
           ((not upper) or (self._map:getCell(upper.row, upper.col) ~= Constants.CellType.LAND_CELL)) and
           ((not bottom) or (self._map:getCell(bottom.row, bottom.col) ~= Constants.CellType.LAND_CELL))
  end,

  _isWaterUpperLeftRightLand = function(self, neighbours)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    return upper and (self._map:getCell(upper.row, upper.col) == Constants.CellType.LAND_CELL) and
           left and (self._map:getCell(left.row, left.col) == Constants.CellType.LAND_CELL) and
           right and (self._map:getCell(right.row, right.col) == Constants.CellType.LAND_CELL) and
           ((not bottom) or (self._map:getCell(bottom.row, bottom.col) ~= Constants.CellType.LAND_CELL))
  end,

  _isWaterUpperLeftBottomLand = function(self, neighbours)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    return upper and (self._map:getCell(upper.row, upper.col) == Constants.CellType.LAND_CELL) and
           left and (self._map:getCell(left.row, left.col) == Constants.CellType.LAND_CELL) and
           bottom and (self._map:getCell(bottom.row, bottom.col) == Constants.CellType.LAND_CELL) and
           ((not right) or (self._map:getCell(right.row, right.col) ~= Constants.CellType.LAND_CELL))
  end,

  _isWaterUpperRightBottomLand = function(self, neighbours)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    return upper and (self._map:getCell(upper.row, upper.col) == Constants.CellType.LAND_CELL) and
           right and (self._map:getCell(right.row, right.col) == Constants.CellType.LAND_CELL) and
           bottom and (self._map:getCell(bottom.row, bottom.col) == Constants.CellType.LAND_CELL) and
           ((not left) or (self._map:getCell(left.row, left.col) ~= Constants.CellType.LAND_CELL))
  end,

  _isWaterBottomLeftRightLand = function(self, neighbours)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    return bottom and (self._map:getCell(bottom.row, bottom.col) == Constants.CellType.LAND_CELL) and
           left and (self._map:getCell(left.row, left.col) == Constants.CellType.LAND_CELL) and
           right and (self._map:getCell(right.row, right.col) == Constants.CellType.LAND_CELL) and
           ((not upper) or (self._map:getCell(upper.row, upper.col) ~= Constants.CellType.LAND_CELL))
  end,

  _isWaterSurroundedLand = function(self, neighbours)
    local upper = neighbours[2]
    local left = neighbours[4]
    local right = neighbours[6]
    local bottom = neighbours[8]

    return upper and (self._map:getCell(upper.row, upper.col) == Constants.CellType.LAND_CELL) and
           left and (self._map:getCell(left.row, left.col) == Constants.CellType.LAND_CELL) and
           right and (self._map:getCell(right.row, right.col) == Constants.CellType.LAND_CELL) and
           bottom and (self._map:getCell(bottom.row, bottom.col) == Constants.CellType.LAND_CELL)
  end,

  -- This function add a land cell to the tilemap
  _addLandCell = function(self, row, col, neighbours)
    -- Calculates position tile
    local x = self._quads_info.size * (col-1)
    local y = self._quads_info.size * (row-1)
    local quad = ""

    -- Draws land cell
    if self._map:getCell(row, col) == Constants.CellType.LAND_CELL then
      quad = self._quads_info.quads[_LAND_CELL]
    -- Draws void cell
    elseif self._map:getCell(row, col) == Constants.CellType.VOID_CELL then
      quad = self._quads_info.quads[_VOID_CELL]
    else
      if self:_isWaterUpperLand(neighbours) then
        quad = self._quads_info.quads[_UPPER_LAND_CELL]
      elseif self:_isWaterLeftLand(neighbours) then
        quad = self._quads_info.quads[_LEFT_LAND_CELL]
      elseif self:_isWaterRightLand(neighbours) then
        quad = self._quads_info.quads[_RIGHT_LAND_CELL]
      elseif self:_isWaterBottomLand(neighbours) then
        quad = self._quads_info.quads[_BOTTOM_LAND_CELL]
      elseif self:_isWaterUpperLeftLand(neighbours) then
        quad = self._quads_info.quads[_UPPER_LEFT_LAND_CELL]
      elseif self:_isWaterUpperRightLand(neighbours) then
        quad = self._quads_info.quads[_UPPER_RIGHT_LAND_CELL]
      elseif self:_isWaterUpperBottomLand(neighbours) then
        quad = self._quads_info.quads[_UPPER_BOTTOM_LAND_CELL]
      elseif self:_isWaterLeftRightLand(neighbours) then
        quad = self._quads_info.quads[_LEFT_RIGHT_LAND_CELL]
      elseif self:_isWaterBottomLeftLand(neighbours) then
        quad = self._quads_info.quads[_BOTTOM_LEFT_LAND_CELL]
      elseif self:_isWaterBottomRightLand(neighbours) then
        quad = self._quads_info.quads[_BOTTOM_RIGHT_LAND_CELL]
      elseif self:_isWaterUpperLeftRightLand(neighbours) then
        quad = self._quads_info.quads[_UPPER_LEFT_RIGHT_LAND_CELL]
      elseif self:_isWaterUpperLeftBottomLand(neighbours) then
        quad = self._quads_info.quads[_UPPER_LEFT_BOTTOM_LAND_CELL]
      elseif self:_isWaterUpperRightBottomLand(neighbours) then
        quad = self._quads_info.quads[_UPPER_RIGHT_BOTTOM_LAND_CELL]
      elseif self:_isWaterBottomLeftRightLand(neighbours) then
        quad = self._quads_info.quads[_BOTTOM_LEFT_RIGHT_LAND_CELL]
      elseif self:_isWaterSurroundedLand(neighbours) then
        quad = self._quads_info.quads[_SURROUNDED_LAND_CELL]
      else
        quad = self._quads_info.quads[_EMPTY_LAND_CELL]
      end
    end

    self._tilemap:add(quad, x, y)
  end,

  -- This function update all tiles in the map
  _updateTilemap = function(self)
    -- Clear al the spritebatches
    self._tilemap:clear()
    self._background:clear()

    -- Gets the water size
    local water_size = self._quads_info.size/2

    -- Iterates al the map
    for i = 1, self._map.rows do
      for j = 1, self._map.cols do
        -- Gets neighbours
        local neighbours = self:_getNeighbours(i, j)
        -- Adds the water cells
        self:_addWaterCell(i, j, water_size, neighbours)
        -- Adds the land cells
        self:_addLandCell(i, j, neighbours)
      end
    end
  end,

  resize = function(self, width, height)
    if self._map ~= nil then
      -- Gets the size of the map
      local width_map = self._map.cols * self._quads_info.size
      local height_map = self._map.rows * self._quads_info.size
      -- Calculates offset
      local x_offset = math.floor((width - width_map) / 2)
      local y_offset = math.floor((height - height_map) / 2)
      -- Sets offset in the editor
      self.offset = {x = x_offset, y = y_offset}
    end
  end,

  -- Checks where the mouse is pressed
  mousepressed = function(self, x, y, button, istouch)
    if self._map ~= nil and button == 1 then
      -- Sets the variables
      local posX, posY = x-self.offset.x, y-self.offset.y
      -- Gets the cell pressed
      local row = math.ceil(posY/self._quads_info.size)
      local col = math.ceil(posX/self._quads_info.size)

      self._pressed = {row = row, col = col}
    end
  end,

  -- Checks where the mouse is release
  mousereleased = function(self, x, y, button, istouch)
    if self._map ~= nil and button == 1 then
      -- Sets the variables
      local posX, posY = x-self.offset.x, y-self.offset.y
      -- Gets the cell pressed
      local row = math.ceil(posY/self._quads_info.size)
      local col = math.ceil(posX/self._quads_info.size)

      if self._pressed and self._pressed.row == row and self._pressed.col == col then
        -- Set pressed to nil
        self._pressed = nil
        -- Changes the rows
        self._map:changeCell(row, col)
        self:_updateTilemap()
      end
    end
  end,

  -- Checks where the mouse is moved
  mousemoved = function(self, x, y, dx, dy, istouch)
    if self._map ~= nil then
      -- Sets the variables
      local posX, posY = x-self.offset.x, y-self.offset.y
      -- Gets the cell selected
      local row = math.floor(posY/self._quads_info.size)
      local col = math.floor(posX/self._quads_info.size)

      if row >= 0 and col >= 0 and row < self._map.rows and col < self._map.cols then
        self._current_tile = {row = row, col = col}
      else
        self._current_tile = nil
      end
    end
  end,

  -- Draws the editor
  draw = function(self)
    -- Clears the window
    --love.graphics.clear(0.8, 0.8, 0.8)

    -- Draws the map
    if self._map ~= nil then
      local width = self._quads_info.size * self._map.cols
      local height = self._quads_info.size * self._map.rows

      -- Draws background
      love.graphics.draw(self._background, self.offset.x, self.offset.y)
      -- Draws tilemap
      love.graphics.draw(self._tilemap, self.offset.x, self.offset.y)
      -- Draws the rectangle
      love.graphics.setColor(0.5, 0.5, 0.5)
      love.graphics.rectangle("line", self.offset.x, self.offset.y, width, height)
      love.graphics.setColor(1, 1, 1)

      -- If the mouse is in a tile, remarks this tile
      if self._current_tile then
        local x = self.offset.x + self._current_tile.col * self._quads_info.size
        local y = self.offset.y + self._current_tile.row * self._quads_info.size
        -- Background
        love.graphics.setColor(1, 1, 1, 0.25)
        love.graphics.rectangle("fill", x, y, self._quads_info.size, self._quads_info.size)
        -- Tile
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self._tile_image, self._quads_info.quads[_SELECTOR_CELL], x, y)
      end
    end
  end
}

return Editor
