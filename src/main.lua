local editor = require "main.client.editor"

function love.load()
  editor_screen = editor:new(10, 10, {x = 0, y = 0})
  love.window.setMode(10*30, 10*30)
  love.graphics.setBackgroundColor(0.9, 0.9, 0.9)
end

function love.mousemoved(x, y, dx, dy, istouch)
  editor_screen:mousemoved(x, y, dx, dy, istouch)
end

function love.draw()
  editor_screen:draw()
end
