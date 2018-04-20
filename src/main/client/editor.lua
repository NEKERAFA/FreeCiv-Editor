local class = require 'libs.middleclass.middleclass'
local map = require "main.client.map"

local LAND_CELL = 1
local EMPTY_LAND_CELL = 2
local UPPER_LAND_CELL = 3
local BOTTOM_LAND_CELL = 4
local LEFT_LAND_CELL = 5
local RIGHT_LAND_CELL = 6
local UPPER_LEFT_LAND_CELL = 7
local UPPER_RIGHT_LAND_CELL = 8
local UPPER_BOTTOM_LAND_CELL = 9
local BOTTOM_RIGHT_LAND_CELL = 10
local BOTTOM_LEFT_LAND_CELL = 11
local LEFT_RIGHT_LAND_CELL = 12
local UPPER_LEFT_RIGHT_LAND_CELL = 13
local UPPER_LEFT_BOTTOM_LAND_CELL = 14
local UPPER_RIGHT_BOTTOM_LAND_CELL = 15
local BOTTOM_LEFT_RIGHT_LAND_CELL = 16
local SURROUNDED_LAND_CELL = 17
local VOID_CELL = 18
local WATER_UP_LEFT = 19
local WATER_UP_RIGHT = 20
local WATER_DOWN_LEFT = 21
local WATER_DOWN_RIGHT = 22
local WATER_LAND_UP_LEFT = 23
local WATER_LAND_UP_RIGHT = 24
local WATER_LAND_DOWN_LEFT = 25
local WATER_LAND_DOWN_RIGHT = 26

local editor = class('editor')

-- Creates a new editor
function editor:initialize(rows, cols, offset)
  self.offset = offset

  -- Create a new map
  self.map = map:new(rows, cols)

  -- Creates all the quads of tiles
  self.quads_info = {size = 30, quads = {}}

  -- Loads the tileset image
  local tileset = love.graphics.newImage("resources/tiles.png")
  tileset:setFilter("nearest", "linear")

  self:setQuads(tileset, tileset:getWidth(), tileset:getHeight())

  -- Create the tilemap and the background
  self.tilemap = love.graphics.newSpriteBatch(tileset, rows * cols)
  self.background = love.graphics.newSpriteBatch(tileset, rows * cols * 4)
  self:setTilemaps()
  self.currentTile = -1
end

-- This function sets the quads for create the tilemap
function editor:setQuads(tileset, tilesWidth, tilesHeight)
  local quads = self.quads_info.quads

  -- Quad for water
  quads[WATER_UP_LEFT] = love.graphics.newQuad(240, 210, 15, 15, tilesWidth, tilesHeight)
  quads[WATER_LAND_UP_LEFT] = love.graphics.newQuad(255, 210, 15, 15, tilesWidth, tilesHeight)
  quads[WATER_UP_RIGHT] = love.graphics.newQuad(270, 210, 15, 15, tilesWidth, tilesHeight)
  quads[WATER_LAND_UP_RIGHT] = love.graphics.newQuad(285, 210, 15, 15, tilesWidth, tilesHeight)
  quads[WATER_DOWN_LEFT] = love.graphics.newQuad(300, 210, 15, 15, tilesWidth, tilesHeight)
  quads[WATER_LAND_DOWN_LEFT] = love.graphics.newQuad(315, 210, 15, 15, tilesWidth, tilesHeight)
  quads[WATER_DOWN_RIGHT] = love.graphics.newQuad(330, 210, 15, 15, tilesWidth, tilesHeight)
  quads[WATER_LAND_DOWN_RIGHT] = love.graphics.newQuad(345, 210, 15, 15, tilesWidth, tilesHeight)

  -- Quads for land
  quads[EMPTY_LAND_CELL] = love.graphics.newQuad(0, 300, 30, 30, tilesWidth, tilesHeight)
  quads[UPPER_LAND_CELL] = love.graphics.newQuad(30, 300, 30, 30, tilesWidth, tilesHeight)
  quads[LEFT_LAND_CELL] = love.graphics.newQuad(60, 300, 30, 30, tilesWidth, tilesHeight)
  quads[UPPER_RIGHT_LAND_CELL] = love.graphics.newQuad(90, 300, 30, 30, tilesWidth, tilesHeight)
  quads[BOTTOM_LAND_CELL] = love.graphics.newQuad(120, 300, 30, 30, tilesWidth, tilesHeight)
  quads[UPPER_BOTTOM_LAND_CELL] = love.graphics.newQuad(150, 300, 30, 30, tilesWidth, tilesHeight)
  quads[BOTTOM_RIGHT_LAND_CELL] = love.graphics.newQuad(180, 300, 30, 30, tilesWidth, tilesHeight)
  quads[UPPER_RIGHT_BOTTOM_LAND_CELL] = love.graphics.newQuad(210, 300, 30, 30, tilesWidth, tilesHeight)
  quads[LEFT_LAND_CELL] = love.graphics.newQuad(240, 300, 30, 30, tilesWidth, tilesHeight)
  quads[UPPER_LEFT_LAND_CELL] = love.graphics.newQuad(270, 300, 30, 30, tilesWidth, tilesHeight)
  quads[LEFT_RIGHT_LAND_CELL] = love.graphics.newQuad(300, 300, 30, 30, tilesWidth, tilesHeight)
  quads[UPPER_LEFT_RIGHT_LAND_CELL] = love.graphics.newQuad(330, 300, 30, 30, tilesWidth, tilesHeight)
  quads[BOTTOM_LEFT_LAND_CELL] = love.graphics.newQuad(360, 300, 30, 30, tilesWidth, tilesHeight)
  quads[UPPER_LEFT_BOTTOM_LAND_CELL] = love.graphics.newQuad(390, 300, 30, 30, tilesWidth, tilesHeight)
  quads[BOTTOM_LEFT_RIGHT_LAND_CELL] = love.graphics.newQuad(420, 300, 30, 30, tilesWidth, tilesHeight)
  quads[SURROUNDED_LAND_CELL] = love.graphics.newQuad(300, 300, 30, 30, tilesWidth, tilesHeight)

  -- Quad for void
  quads[VOID_CELL] = love.graphics.newQuad(90, 0, 30, 30, tilesWidth, tilesHeight)
end

-- This function sets the tiles in the tilemap
function editor:setTilemaps()
  map = self.map:getMap()

  for i, row in ipairs(map) do
    for j, col in ipairs(row) do
      -- Gets the position in the map
      local x = self.quads_info.size * (i-1)
      local y = self.quads_info.size * (j-1)
      local water_size = self.quads_info.size/2

      -- Add the quad to the tilemap
      self.tilemap:add(self.quads_info.quads[EMPTY_LAND_CELL], x, y)
      -- Adds the background to the tilemap
      self.background:add(self.quads_info.quads[WATER_UP_LEFT], x, y)
      self.background:add(self.quads_info.quads[WATER_UP_RIGHT], x+water_size, y)
      self.background:add(self.quads_info.quads[WATER_DOWN_LEFT], x, y+water_size)
      self.background:add(self.quads_info.quads[WATER_DOWN_RIGHT], x+water_size, y+water_size)
    end
  end
end

-- Checks where the mouse is pressed
function editor:mousepressed(x, y, button, istouch)
  -- Sets the variables
  local posX, posY = x-self.offset.x, y-self.offset.y

  -- Gets the cell pressed
  local row = math.ceil(posX/self.cell_size)
  local col = math.ceil(posY/self.cell_size)

  -- Changes the rows

end

-- Checks where the mouse is moved
function editor:mousemoved(x, y, dx, dy, istouch)
  -- Sets the variables
  local posX, posY = x-self.offset.x, y-self.offset.y

  local row = math.floor(posX/self.quads_info.size)
  local col = math.floor(posY/self.quads_info.size)

  if row >= 0 and col >= 0 and row < self.map.rows and col < self.map.cols then
    self.currentTile = {row = row, col = col}
  else
    self.currentTile = -1
  end
end

-- Draw the map
function editor:draw()
  love.graphics.draw(self.tilemap, 0, 0)
  love.graphics.draw(self.background, 0, 0)

  if self.currentTile ~= -1 then
    local x = self.offset.x + self.currentTile.row * self.quads_info.size
    local y = self.offset.y + self.currentTile.col * self.quads_info.size
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.rectangle("fill", x, y, self.quads_info.size, self.quads_info.size)
    love.graphics.setColor(1, 1, 1, 1)
  end
end

return editor
