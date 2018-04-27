-- Rafael Alcalde Azpiazu - 19 Apr 2018
-- Facultade de Informática da Coruña - Universidade da Coruña
--
-- This file define functions to validate parameters

local class = require 'libs.middleclass.middleclass'
local map = require "main.model.map"
local constants = require "main.utilities.constants"
local validator = require "main.utilities.validator"

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

local editor = class('editor')

-- Creates a new editor
function editor:initialize(flags)
  self.offset = validator.getFlag(flags, "offset", 1, {x = 10, y = 10})

  -- Create or save a new map
  rows = validator.getFlag(flags, "rows", 1, -1)
  cols = validator.getFlag(flags, "cols", 1, -1)

  if rows == -1 or cols == -1 then
    self._map = validator.getFlag(flags, "map", 1)
  else
    self._map = map:new(rows, cols)
  end

  -- Creates all the quads of tiles
  self._quads_info = {size = validator.getFlag(flags, "tiles_size", 1), quads = {}}

  -- Loads the tileset image
  self._tile_image = love.graphics.newImage("resources/tiles.png")
  self._tile_image:setFilter("nearest", "linear")

  self:_setQuads(self._tile_image:getWidth(), self._tile_image:getHeight())

  -- Create the tilemap and the background
  self._tilemap = love.graphics.newSpriteBatch(self._tile_image, self._map.rows * self._map.cols)
  self._background = love.graphics.newSpriteBatch(self._tile_image, self._map.rows * self._map.cols * 4)
  self:_updateTilemap()
  self._current_tile = -1
end

-- Gets tile size
function editor:getTileSize()
  return self._quads_info.size
end

-- Gets rows count
function editor:getRows()
  return self._map.rows
end

-- Gets height of map board
function editor:getHeight()
  return self._map.cols * self._quads_info.size
end

-- Gets columns count
function editor:getColumns()
  return self._map.cols
end

-- Gets width of map board
function editor:getWidth()
  return self._map.cols * self._quads_info.size
end

-- This function sets the quads for create the tilemap
function editor:_setQuads(tilesWidth, tilesHeight)
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
  quads[_LEFT_LAND_CELL] = love.graphics.newQuad(60, 300, 30, 30, tilesWidth, tilesHeight)
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
  quads[_SURROUNDED_LAND_CELL] = love.graphics.newQuad(300, 300, 30, 30, tilesWidth, tilesHeight)

  -- Quad for void
  quads[_VOID_CELL] = love.graphics.newQuad(90, 0, 30, 30, tilesWidth, tilesHeight)
end

-- This function gets all the neighbours
function editor:_getNeighbours(row, col)
  -- This list stores all neighbour position
  local list = {}

  -- Loops all 8-conected cell positions
  for i = math.max(1, row-1), math.min(row+1, self._map.rows) do
    for j = math.max(1, col-1), math.min(col+1, self._map.cols) do
      -- Inserts only if the current position isn't the root cell
      if row ~= i and col ~= j then
        list[i+(j-1)*3] = {x = i, y = j}
      end
    end
  end
end

-- Checks if are land only in the upper left corner
function editor:_isUpperLeftLand(map, neighbours)
  local is_land = false

  -- Corner
  if neighbours[1] then
    if map[neighbours[1].x][neighbours[1].y] == constants.LAND_CELL then
      -- Upper
      if not neighbours[2] then
        -- Left
        if not neighbour[4] then
          is_land = true
        elseif map[neighbours[4].x][neighbours[4].y] == constants.WATER_CELL then
          is_land = true
        end
      elseif map[neighbours[2].x][neighbours[2].y] == constants.WATER_CELL then
        -- Left
        if not neighbour[4] then
          is_land = true
        elseif map[neighbours[4].x][neighbours[4].y] == constants.WATER_CELL then
          is_land = true
        end
      end
    end
  end

  return is_land
end

-- Checks if are land only in the upper right corner
function editor:_isUpperRightLand(map, neighbours)
  local is_land = false

  -- Corner
  if neighbours[3] then
    if map[neighbours[3].x][neighbours[3].y] == constants.LAND_CELL then
      -- Upper
      if not neighbours[2] then
        -- Left
        if not neighbour[6] then
          is_land = true
        elseif map[neighbours[6].x][neighbours[6].y] == constants.WATER_CELL then
          is_land = true
        end
      elseif map[neighbours[2].x][neighbours[2].y] == constants.WATER_CELL then
        -- Left
        if not neighbour[6] then
          is_land = true
        elseif map[neighbours[6].x][neighbours[6].y] == constants.WATER_CELL then
          is_land = true
        end
      end
    end
  end

  return is_land
end

-- Checks if are land only in the bottom left corner
function editor:_isBottomLeftLand(map, neighbours)
  local is_land = false

  -- Corner
  if neighbours[7] then
    if map[neighbours[7].x][neighbours[7].y] == constants.LAND_CELL then
      -- Upper
      if not neighbours[8] then
        -- Left
        if not neighbour[4] then
          is_land = true
        elseif map[neighbours[4].x][neighbours[4].y] == constants.WATER_CELL then
          is_land = true
        end
      elseif map[neighbours[8].x][neighbours[8].y] == constants.WATER_CELL then
        -- Left
        if not neighbour[4] then
          is_land = true
        elseif map[neighbours[4].x][neighbours[4].y] == constants.WATER_CELL then
          is_land = true
        end
      end
    end
  end

  return is_land
end

-- Checks if are land only in the bottom right corner
function editor:_isBottomRightLand(map, neighbours)
  local is_land = false

  -- Corner
  if neighbours[9] then
    if map[neighbours[9].x][neighbours[9].y] == constants.LAND_CELL then
      -- Upper
      if not neighbours[8] then
        -- Left
        if not neighbour[6] then
          is_land = true
        elseif map[neighbours[6].x][neighbours[6].y] == constants.WATER_CELL then
          is_land = true
        end
      elseif map[neighbours[8].x][neighbours[8].y] == constants.WATER_CELL then
        -- Left
        if not neighbour[6] then
          is_land = true
        elseif map[neighbours[6].x][neighbours[6].y] == constants.WATER_CELL then
          is_land = true
        end
      end
    end
  end

  return is_land
end

-- This function adds a water cell to the tilemap
function editor:_addWaterCell(row, col, land, water_size, map, neighbours)
  -- Calculates position tile
  local x = self._quads_info.size * (i-1)
  local y = self._quads_info.size * (j-1)

  -- Gets water tiles
  local quad_upper_left = self._quads_info.quads[_WATER_UPPER_LEFT_CELL]
  local quad_upper_right = self._quads_info.quads[_WATER_UPPER_RIGHT_CELL]
  local quad_bottom_left = self._quads_info.quads[_WATER_BOTTOM_LEFT_CELL]
  local quad_bottom_right = self._quads_info.quads[_WATER_BOTTOM_RIGHT_CELL]

  -- Gets cornet quads with land
  if not land then
    -- Checks if a corner has land
    if self:_isUpperLeftLand(map, neighbours) then
      quad_upper_left = self._quads_info.quads[_WATER_LAND_UPPER_LEFT_CELL]
    end

    if self:_isUpperRightLand(map, neighbours) then
      quad_upper_right = self._quads_info.quads[_WATER_LAND_UPPER_RIGHT_CELL]
    end

    if self:_isBottomLeftLand(map, neighbours) then
      quad_bottom_left = self._quads_info.quads[_WATER_LAND_BOTTOM_LEFT_CELL]
    end

    if self:_isBottomRightLand(map, neighbours) then
      quad_bottom_right = self._quads_info.quads[_WATER_LAND_BOTTOM_RIGHT_CELL]
    end
  end

  -- Sets water
  self._background:add(quad_upper_left, x, y)
  self._background:add(quad_upper_right, x+water_size, y)
  self._background:add(quad_bottom_left, x, y+water_size)
  self._background:add(quad_bottom_right, x+water_size, y+water_size)
end

-- This function add a land cell to the tilemap
function editor:_addLandCell(row, col, land, neighbours)

end

-- This function update all tiles in the map
--[[
function editor:_updateTilemap()
  self._tilemap:clear()
  self._background:clear()

  local map_data = self._map:getMap()
  local water_size = self._quads_info.size/2

  for i, row in ipairs(map_data) do
    for j, col in ipairs(row) do
      -- Gets neighbours
      local neighbours = self:_getNeighbours(i, j)
      -- Add water cell
      self:_addWaterCell(row, col, map_data[i][j] == constants.LAND_CELL, water_size, map_data, neighbours)
    end
  end
end
]]

function editor:_updateTilemap()
  self._tilemap:clear()
  self._background:clear()

  local map_data = self._map:getMap()
  local water_size = self._quads_info.size/2

  for i, row in ipairs(map_data) do
    for j, col in ipairs(row) do
      -- Calculates position tile
      local x = self._quads_info.size * (i-1)
      local y = self._quads_info.size * (j-1)

      -- Add terrain
      if map_data[i][j] == constants.WATER_CELL then
        self._tilemap:add(self._quads_info.quads[_EMPTY_LAND_CELL], x, y)
      elseif map_data[i][j] == constants.LAND_CELL then
        self._tilemap:add(self._quads_info.quads[_LAND_CELL], x, y)
      else
        self._tilemap:add(self._quads_info.quads[_VOID_CELL], x, y)
      end

      -- Add water cell
      self._background:add(self._quads_info.quads[_WATER_UPPER_LEFT_CELL], x, y)
      self._background:add(self._quads_info.quads[_WATER_UPPER_RIGHT_CELL], x+water_size, y)
      self._background:add(self._quads_info.quads[_WATER_BOTTOM_LEFT_CELL], x, y+water_size)
      self._background:add(self._quads_info.quads[_WATER_BOTTOM_LEFT_CELL], x+water_size, y+water_size)
    end
  end
end

-- Checks where the mouse is pressed
function editor:mousepressed(x, y, button, istouch)
  if button == 1 then
    -- Sets the variables
    local posX, posY = x-self.offset.x, y-self.offset.y
    -- Gets the cell pressed
    local row = math.ceil(posX/self._quads_info.size)
    local col = math.ceil(posY/self._quads_info.size)

    -- Changes the rows
    self._map:changeCell(row, col)
    self:_updateTilemap()
  end
end

-- Checks where the mouse is moved
function editor:mousemoved(x, y, dx, dy, istouch)
  -- Sets the variables
  local posX, posY = x-self.offset.x, y-self.offset.y
  -- Gets the cell selected
  local row = math.floor(posX/self._quads_info.size)
  local col = math.floor(posY/self._quads_info.size)

  if row >= 0 and col >= 0 and row < self._map.rows and col < self._map.cols then
    self._current_tile = {row = row, col = col}
  else
    self._current_tile = -1
  end
end

-- Draw the map
function editor:draw()
  -- Draw background
  love.graphics.draw(self._background, self.offset.x, self.offset.y)
  -- Draw tilemap
  love.graphics.draw(self._tilemap, self.offset.x, self.offset.y)

  -- If the mouse is in a tile, remarks this tile
  if self._current_tile ~= -1 then
    local x = self.offset.x + self._current_tile.row * self._quads_info.size
    local y = self.offset.y + self._current_tile.col * self._quads_info.size
    love.graphics.draw(self._tile_image, self._quads_info.quads[_SELECTOR_CELL], x, y)
  end
end

return editor
