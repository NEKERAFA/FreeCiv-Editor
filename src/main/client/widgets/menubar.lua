--- This class defines the upper toolbar in the UI application.
-- @classmod Widget.MenuBar

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

--- Creates a new widget object.
-- @param fileopened True if a file is opened and false otherwise.
function MenuBar:new (fileopened)
  local obj = setmetatable({}, self)
  obj._gui = Suit.new()
  obj._gui.theme = setmetatable({}, {__index = Suit.theme})
  obj._gui.theme.Button = MenuBar.drawButton
  obj._fileopened = fileopened

  return obj
end

function MenuBar.drawButton (text, opt, x, y, w, h)
  local c
  if opt.state == "normal" then
    c = {bg = {0, 0, 0, 0}}
  elseif opt.state == "hovered" then
    c = {bg = {.8, .8, .8}}
  else
    c = Suit.theme.color.active
  end

  Suit.theme.drawBox(x, y, w, h, c, opt.cornerRadius)
  love.graphics.setColor(.2, .2, .2)
  love.graphics.draw(opt.icon, x+w/2, y+h/2, 0, 1, 1, opt.icon:getWidth()/2, opt.icon:getHeight()/2)
end

--- Updates the widget.
-- @param dt The time in seconds since the last update.
-- @param isHover True if another widget is hovered this widget.
function MenuBar:update (dt, isHover)
  local option = 0
  local status

  self._gui.layout:reset(5, 5)
  self._gui.layout:padding(5, 5)

  status = self._gui:Button("File", {icon = MenuBar._add, draw = MenuBar.drawButton}, self._gui.layout:col(30, 30))
  if status.hit and not isHover then
    option = 1
  end

  status = self._gui:Button("Open", {icon = MenuBar._open, draw = MenuBar.drawButton}, self._gui.layout:col(30, 30))
  if status.hit and not isHover then
    option = 2
  end

  if self._fileopened then
    status = self._gui:Button("Save", {icon = MenuBar._save, draw = MenuBar.drawButton}, self._gui.layout:col(30, 30))
    if status.hit and not isHover then
      option = 3
    end

    status = self._gui:Button("Export", {icon = MenuBar._export, draw = MenuBar.drawButton}, self._gui.layout:col(30, 30))
    if status.hit and not isHover then
      option = 4
    end

    status = self._gui:Button("Build", {icon = MenuBar._build, draw = MenuBar.drawButton}, self._gui.layout:col(30, 30))
    if status.hit and not isHover then
      option = 5
    end
  end

  return option
end

--- Draws the widget.
function MenuBar:draw ()
  self._gui:draw()

  local width, height = love.window.getMode()
  love.graphics.setColor(.75, .75, .75)
  love.graphics.setLineStyle("rough")
  love.graphics.setLineWidth(1)
  love.graphics.line(0, 40, width, 40)
end

return setmetatable(MenuBar, {__call = MenuBar.new})
