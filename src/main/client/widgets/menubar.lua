local Suit = require "libs.suit"
local Resources = require "main.utilities.resources"

local MenuBar = {}
MenuBar.__index = MenuBar
MenuBar._save = Resources.loadResource("image", "icons/content-save")
MenuBar._export = Resources.loadResource("image", "icons/export")
MenuBar._add = Resources.loadResource("image", "icons/file-plus")
MenuBar._open = Resources.loadResource("image", "icons/folder-open")
MenuBar._build = Resources.loadResource("image", "icons/wrench")

--------------------------------------------------------------------------------

function MenuBar:new ()
  local obj = setmetatable({}, self)
  obj._gui = Suit.new()
  return obj
end

function MenuBar.drawButton (text, opt, x, y, w, h)
  local c = Suit.theme.getColorForState(opt)
	Suit.theme.drawBox(x, y, w, h, c, opt.cornerRadius)
  love.graphics.draw(opt.icon, x+w/2, y+h/2, 0, 1, 1, opt.icon:getWidth()/2, opt.icon:getHeight()/2)
end

function MenuBar:update (dt)
  option = 0

  self._gui.layout:reset(5, 5)
  self._gui.layout:padding(5, 5)

  if self._gui:Button("File", {icon = MenuBar._add, draw = MenuBar.drawButton}, self._gui.layout:col(30, 30)).hit then
    option = 1
  end

  if self._gui:Button("Open", {icon = MenuBar._open, draw = MenuBar.drawButton}, self._gui.layout:col(30, 30)).hit then
    if option == 0 then option = 2 end
  end

  if self._gui:Button("Save", {icon = MenuBar._save, draw = MenuBar.drawButton}, self._gui.layout:col(30, 30)).hit then
    if option == 0 then option = 3 end
  end

  if self._gui:Button("Export", {icon = MenuBar._export, draw = MenuBar.drawButton}, self._gui.layout:col(30, 30)).hot then
    if option == 0 then option = 4 end
  end

  if self._gui:Button("Build", {icon = MenuBar._build, draw = MenuBar.drawButton}, self._gui.layout:col(30, 30)).hit then
    if option == 0 then option = 5 end
  end

  return option
end

function MenuBar:draw ()
  self._gui:draw()

  local width, height = love.window.getMode()
  love.graphics.setColor(.75, .75, .75)
  love.graphics.setLineStyle("rough")
  love.graphics.setLineWidth(1)
  love.graphics.line(0, 40, width, 40)
end

return setmetatable(MenuBar, {__call = MenuBar.new})
