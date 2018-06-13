package.cpath = "libs/?;" .. package.cpath
package.path = "libs/?;" .. package.path

function love.conf(t)
  t.title = "FreeCiv Editor"
  t.window.resizable = true
  t.window.width = 640
  t.window.height = 480
  t.window.minwidth = 640
  t.window.minheight = 480
end
