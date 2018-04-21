local editor = require "main.client.editor"

function love.load()
  editor_screen = editor:new(10, 10, {x = 10, y = 10})
  local width_map = editor_screen.quads_info.size * editor_screen.map.cols
  local height_map = editor_screen.quads_info.size * editor_screen.map.rows
  love.window.setMode(width_map + 20, height_map + 20, {resizable = true, minwidth = width_map, minheight = height_map})
  love.graphics.setBackgroundColor(0.9, 0.9, 0.9)
end

function love.resize(width, height)
  -- Gets the size of the map
  local width_map = editor_screen.quads_info.size * editor_screen.map.cols
  local height_map = editor_screen.quads_info.size * editor_screen.map.rows
  -- Calculates offset
  local x_offset = math.floor((width - width_map) / 2)
  local y_offset = math.floor((height - height_map) / 2)
  -- Sets offset in the editor
  editor_screen.offset = {x = x_offset, y = y_offset}
end

function love.mousemoved(x, y, dx, dy, istouch)
  editor_screen:mousemoved(x, y, dx, dy, istouch)
end

function love.draw()
  editor_screen:draw()
end
