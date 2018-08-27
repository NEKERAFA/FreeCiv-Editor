-- Rafael Alcalde Azpiazu - 19 Apr 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local Class = require "libs.hump.class"
local Map = require "main.model.map"
local Adapter = require "main.client.map_adapter"
local Constants = require "main.utilities.constants"
local Validator = require "main.utilities.validator"
local Resources = require "main.utilities.resources"

--- This class represents the controller of the interface of the map editor.
-- @classmod Editor
local Editor = Class {
  --- Creates a new map editor controller.
  -- @param self The new controller object.
  init = function(self)
    -- Position to put the map
    self.pos = {x = 0, y = 40}
    -- Offset of the map
    self.offset = {x = 10, y = 0}

    -- Loads the tileset image
    self._tile_image = Resources.loadResource("image", "tiles")

    -- Creates all the quads of tiles
    self._quads_info = {size = 30, quads = {}}
    self:_setQuads(self._tile_image:getWidth(), self._tile_image:getHeight())

    self._adapter = nil
    self._map = nil
    self._regions = nil
    self._startpos = nil
    self._current_tile = nil
    self._terrain = Constants.CellType.GRASS
  end,

  --- Gets the width of the map drawn.
  -- @param self A controller object.
  getWidth = function(self)
    if self._map == nil then
      return 0
    end

    return self._map.cols * self._quads_info.size
  end,

  --- Gets the height of the map drawn.
  -- @param self A controller object.
  getHeight = function(self)
    if self._map == nil then
      return 0
    end

    return self._map.rows * self._quads_info.size
  end,

  --- Clears the current map and loads a empty fresh map.
  -- @param self A controller object.
  -- @param rows Number of rows of the new map.
  -- @param cols Number of columns of the new map.
  newMap = function(self, rows, cols)
    self._map = Map(rows, cols)

    -- Creates the tilemap and the background
    self._tilemap = love.graphics.newSpriteBatch(self._tile_image, self._map.rows * self._map.cols)
    self._background = love.graphics.newSpriteBatch(self._tile_image, self._map.rows * self._map.cols * 4)

    self._adapter = Adapter(self._map, self._quads_info, self._tilemap, self._background)

    -- Sets all the tilemaps in the spritesbatches
    self._adapter:setTilemap()
  end,

  --- Clears the current map and add a loaded map.
  -- @param self A controller object.
  -- @param map The new map object to set to the editor.
  setMap = function(self, map)
    self._map = Map(map)

    -- Creates the tilemap and the background
    self._tilemap = love.graphics.newSpriteBatch(self._tile_image, self._map.rows * self._map.cols)
    self._background = love.graphics.newSpriteBatch(self._tile_image, self._map.rows * self._map.cols * 4)

    self._adapter = Adapter(self._map, self._quads_info, self._tilemap, self._background)

    -- Sets all the tilemaps in the spritesbatches
    self._adapter:setTilemap()
  end,

  --- Sets the mapping of regions. This function is for debugging purpose.
  -- @param self A controller object.
  -- @param regions A 2d array with the regions.
  -- @param c_rows The number of rows.
  -- @param c_cols The number of cols.
  setRegions = function(self, regions, c_rows, c_cols)
    self._regions = Map(regions)
    self._regions.width = c_rows
    self._regions.height = c_cols
  end,

  --- Sets the spawn points created in the generations
  setSpawns = function(self, spawns)
    self._startpos = spawns
  end,

  --- This function loads the quads for create the tilemap
  _setQuads = function(self, tilesWidth, tilesHeight)
    -- Load all the sprites on the tilemap
    df = io.open("resources/tilemap.lua", "r")
    conf = df:read("a")
    df:close()
    local quads = assert(load("return " .. conf))()

    -- Local function to iterate all the quads definitions
    _iter_quads = function (tbl)
      local quad = {}
      for k, v in pairs(tbl) do
        if type(v) == "table" then
          tbl[k] = _iter_quads(v)
        else
          quad[k] = v
        end
      end

      if #quad == 0 then
        return tbl
      end

      return love.graphics.newQuad(quad[1], quad[2], quad[3], quad[4], tilesWidth, tilesHeight)
    end

    self._quads_info.quads = _iter_quads(quads)

    -- Quad for void
    quads[Constants.TileType.VOID] = love.graphics.newQuad(90, 0, 30, 30, tilesWidth, tilesHeight)
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

  --- This function is called when the window is resized.
  resize = function(self, width, height)
    if self._map ~= nil then
      -- Gets the size of the map
      local width_map = self._map.cols * self._quads_info.size
      local height_map = self._map.rows * self._quads_info.size
      -- Calculates offset
      width = width - self.pos.x
      height = height - self.pos.y
      local x_offset = math.floor((width - width_map) / 2)
      local y_offset = math.floor((height - height_map) / 2)
      -- Sets offset in the editor
      self.offset = {x = x_offset, y = y_offset}
    end
  end,

  update = function(self, dt)
    if self._map ~= nil and love.mouse.isDown(1) then
      local x, y = love.mouse.getPosition()

      -- Sets the variables
      local posX = x-self.offset.x-self.pos.x
      local posY = y-self.offset.y-self.pos.y
      -- Gets the cell pressed
      local row = math.ceil(posY/self._quads_info.size)
      local col = math.ceil(posX/self._quads_info.size)

      if row > 0 and col > 0 and row <= self._map.rows and col <= self._map.cols then
        if self._map:getCell(row, col) ~= self._terrain then
          self._adapter:setCell(row, col, self._terrain)
        end
      end
    end
  end,

  -- Checks where the mouse is pressed
  mousepressed = function(self, x, y, button, istouch)
    if button == 2 then
      if self._terrain == Constants.CellType.GRASS then
        self._terrain = Constants.CellType.PLAIN
      elseif self._terrain == Constants.CellType.PLAIN then
        self._terrain = Constants.CellType.JUNGLE
      elseif self._terrain == Constants.CellType.JUNGLE then
        self._terrain = Constants.CellType.TRUNDA
      elseif self._terrain == Constants.CellType.TRUNDA then
        self._terrain = Constants.CellType.SWAMP
      elseif self._terrain == Constants.CellType.SWAMP then
        self._terrain = Constants.CellType.DESERT
      elseif self._terrain == Constants.CellType.DESERT then
        self._terrain = Constants.CellType.FOREST
      elseif self._terrain == Constants.CellType.FOREST then
        self._terrain = Constants.CellType.HILLS
      elseif self._terrain == Constants.CellType.HILLS then
        self._terrain = Constants.CellType.GLACIER
      elseif self._terrain == Constants.CellType.GLACIER then
        self._terrain = Constants.CellType.SEA
      elseif self._terrain == Constants.CellType.SEA then
        self._terrain = Constants.CellType.OCEAN
      elseif self._terrain == Constants.CellType.OCEAN then
        self._terrain = Constants.CellType.VOID
      elseif self._terrain == Constants.CellType.VOID then
        self._terrain = Constants.CellType.GRASS
      end
    end
  end,

  -- Checks where the mouse is moved
  mousemoved = function(self, x, y, dx, dy, istouch)
    if self._map ~= nil then
      -- Sets the variables
      local posX = x-self.offset.x-self.pos.x
      local posY = y-self.offset.y-self.pos.y
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

  _draw_regions = function(self, x, y)
    for i = 1, self._regions.rows do
      for j = 1, self._regions.cols do
        local width = self._quads_info.size*math.floor(self._map.rows/4)
        local height = self._quads_info.size*math.floor(self._map.cols/4)
        local x = (i-1)*width + self.offset.x + self.pos.x
        local y = (j-1)*height + self.offset.y + self.pos.y
        local region = self._regions:getCell(i, j)
        local font = love.graphics.getFont()
        local text = love.graphics.newText(font, region)
        local xtext = x+width/2-text:getWidth()/2
        local ytext = y+height/2-text:getHeight()/2
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", x, y, width, height)
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(text, xtext, ytext, 0, 2, 2)
      end
    end
  end,

  _draw_selection = function(self, x, y)
    local tile_x = x + self._current_tile.col * self._quads_info.size
    local tile_y = y + self._current_tile.row * self._quads_info.size
    local quads =  self._quads_info.quads
    local water_size = self._quads_info.size / 2

    -- Background
    love.graphics.setColor(1, 1, 1, 0.5)
    if self._terrain == Constants.CellType.GRASS or
       self._terrain == Constants.CellType.VOID or
       self._terrain == Constants.CellType.GLACIER or
       self._terrain == Constants.CellType.MOUNTAIN or
       self._terrain == Constants.CellType.FOREST or
       self._terrain == Constants.CellType.HILLS or
       self._terrain == Constants.CellType.LAKE then
      love.graphics.draw(self._tile_image, quads[self._terrain], tile_x, tile_y)
    elseif self._terrain == Constants.CellType.PLAIN or
           self._terrain == Constants.CellType.JUNGLE or
           self._terrain == Constants.CellType.TRUNDA or
           self._terrain == Constants.CellType.SWAMP or
           self._terrain == Constants.CellType.DESERT then
      love.graphics.draw(self._tile_image, quads[self._terrain][Constants.TilePosition.SINGLE], tile_x, tile_y)
    else
      local quad_upper_left = quads[self._terrain][Constants.TilePosition.UPPER_LEFT]
      local quad_upper_right = quads[self._terrain][Constants.TilePosition.UPPER_RIGHT]
      local quad_bottom_left = quads[self._terrain][Constants.TilePosition.BOTTOM_LEFT]
      local quad_bottom_right = quads[self._terrain][Constants.TilePosition.BOTTOM_RIGHT]
      love.graphics.draw(self._tile_image, quad_upper_left, tile_x, tile_y)
      love.graphics.draw(self._tile_image, quad_upper_right, tile_x+water_size, tile_y)
      love.graphics.draw(self._tile_image, quad_bottom_left, tile_x, tile_y+water_size)
      love.graphics.draw(self._tile_image, quad_bottom_right, tile_x+water_size, tile_y+water_size)
    end
    -- Tile
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self._tile_image, self._quads_info.quads[Constants.TileType.SELECTOR], tile_x, tile_y)
  end,

  _draw_spawns = function(self, x, y)
    local quads =  self._quads_info.quads
    for k, spawn in ipairs(self._startpos) do
      local tile_x = x + spawn.x * self._quads_info.size
      local tile_y = y + spawn.y * self._quads_info.size
      love.graphics.draw(self._tile_image, quads[Constants.TileType.SPAWN], tile_x, tile_y)
    end
  end,

  -- Draws the editor
  draw = function(self)
    -- Draws the map
    if self._map ~= nil then
      local x = self.offset.x + self.pos.x
      local y = self.offset.y + self.pos.y
      local width = self._quads_info.size * self._map.cols
      local height = self._quads_info.size * self._map.rows

      -- Draws background
      love.graphics.setColor(1, 1, 1)
      love.graphics.draw(self._background, x, y)
      -- Draws tilemap
      love.graphics.draw(self._tilemap, x, y)
      -- Draws the rectangle
      love.graphics.setColor(0.5, 0.5, 0.5)
      love.graphics.rectangle("line", x, y, width, height)
      love.graphics.setColor(1, 1, 1)

      -- Draws the spawn points
      if self._startpos ~= nil then
        self:_draw_spawns(x, y)
      end

      -- Draws the regions
      if self._regions ~= nil and DEBUG then
        self:_draw_regions(x, y)
      end

      -- If the mouse is in a tile, remarks this tile
      if self._current_tile then
        self:_draw_selection(x, y)
      end
    end
  end
}

return Editor
