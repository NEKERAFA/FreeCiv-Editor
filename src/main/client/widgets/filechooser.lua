local Suit = require "libs.suit"
local Lfs = require "lfs"
local Resources = require "main.utilities.resources"

local FileChooser = {}
FileChooser.__index = FileChooser

function FileChooser:_getFolders ()
  local systemFont = love.graphics.getFont()

  local folders = {size = 0, top = 1, width = 0}
  for folder in string.gmatch(self._path, "([^\\/]+)") do
    table.insert(folders, {
        name = folder,
        render = love.graphics.newText(systemFont, folder)
      })
    folders.size = folders.size + 1
    folders.width = folders.width + folders[folders.size].render:getWidth() + 30
  end

  if love.system.getOS() ~= "Windows" then
    table.insert(folders, 1, {
        name = "/",
        render = love.graphics.newText(systemFont, "/")
      })
    folders.size = folders.size + 1
    folders.width = folders.width + folders[folders.size].render:getWidth() + 30
  end

  return folders
end

function FileChooser._append (...)
  local args = {...}
  local nargs = #args
  local path = ""

  for i, folder in ipairs(args) do
    path = path .. folder

    if i < nargs then
      if love.system.getOS() == "Windows" then
        path = path .. "\\"
      else
        path = path .. "/"
      end
    end
  end

  return path
end

function FileChooser._sortByName (item1, item2)
  if item1.mode == "directory" then
    if item2.mode ~= "directory" then
      return true
    end

    return item1.name < item2.name
  end

  if item2.mode == "directory" then
    return false
  end

  return item1.name < item2.name
end

function FileChooser:_updateFiles ()
  self._items = {}

  for name in lfs.dir(self._path) do
    if not string.match(name, "^%..*") then
      fullpath = FileChooser._append(self._path, name)
      file = Lfs.attributes(fullpath)
      file.name = name
      table.insert(self._items, file)
    end
  end

  table.sort(self._items, self._sortByName)
  self._numItems = #self._items
  self._topItem = 1

  if self._numItems > 11 then
    self._scroll = {y = 0, height = math.max(270/(self._numItems-11), 20)}
  end
end

function FileChooser:_returnFolder (pos)
  self._path = ""

  for i = 1, pos do
    self._path = FileChooser._append(self._path, self._folders[i].name)
  end

  for i = pos+1, self._folders.size do
    self._folders.top = math.max(1, self._folders.top-1)
    self._folders.width = self._folders.width - self._folders[pos+1].render:getWidth() - 30
    table.remove(self._folders, pos+1)
  end

  self._folders.size = pos
  self:_updateFiles()
end

function FileChooser:_openFolder (file)
  local systemFont = love.graphics.getFont()
  self._path = FileChooser._append(self._path, file.name)
  local folder = {
        name = file.name,
        render = love.graphics.newText(systemFont, file.name)
      }

  if self._folders.width + folder.render:getWidth() + 30 >= 400 then
    local max = self._folders.width + folder.render:getWidth()
    local i = 1
    while max > 400 and i <= self._folders.size do
      self._folders.top = self._folders.top+1
      max = max - self._folders[i].render:getWidth() - 30
      i = i+1
    end
  end

  table.insert(self._folders, folder)
  self._folders.width = self._folders.width + folder.render:getWidth()
  self._folders.size = self._folders.size+1
  self:_updateFiles()
end

FileChooser.fileIcon = Resources.loadResource("image", "icons/file")
FileChooser.folderIcon = Resources.loadResource("image", "icons/folder")

function FileChooser._drawButton(text, opt, x, y, w, h)
	local c = Suit.theme.getColorForState(opt)
  local hfont = opt.font:getHeight()
  local icon

  if opt.dir then
    icon = FileChooser.folderIcon
  else
    icon = FileChooser.fileIcon
  end

	Suit.theme.drawBox(x, y, w, h, c, opt.cornerRadius)
	love.graphics.setColor(c.fg)
	love.graphics.setFont(opt.font)

	y = y + Suit.theme.getVerticalOffsetForAlign(opt.valign, opt.font, h)
  love.graphics.draw(icon, x+2, y, 0, hfont/icon:getWidth(), hfont/icon:getHeight())
	love.graphics.printf(text, x+4+hfont, y, w-4, opt.align or "center")
end

-------------------------------------------------------------------------------

function FileChooser:new (mode, ...)
  assert(mode == "open" or mode == "save", "bad argument #1 (mode must be 'open' or 'save' literal)")

  local obj = setmetatable({}, self)
  local args = {...}

  if mode == "save" then
    obj._filename = {text = args[1] or "untitle"}
    obj._onSuccess = args[2]
    obj._onCancel = args[3]
  else
    obj._onSuccess = args[1]
    obj._onCancel = args[2]
  end

  obj._gui = Suit.new()
  obj._path = love.filesystem.getUserDirectory()
  obj._folders = obj:_getFolders()
  obj._mode = mode or "open"
  obj._focus = {key = false, mouse = false}
  obj:_updateFiles()
  obj._closed = false

  return obj
end

function FileChooser:isKeyboardFocused ()
  if self._filename.id then
    return Suit.hasKeyboardFocus(self._filename.id)
  end

  return false
end

function FileChooser:isMouseFocused ()
  local width, height = love.window.getMode()
  local posX, posY = love.mouse.getPosition()
  local x, y = width/2-250, height/2-175
  return posX >= x and posX <= x + width and posY >= y and posY <= y + height
end

function FileChooser:textInput (t)
  if not self._closed then
    self._gui:textinput(t)
  end
end

function FileChooser:keyPressed (key)
  if not self._closed then
    self._gui:keypressed(key)
  end
end

function FileChooser:wheelMoved (x, y, button)
  if self._numItems > 11 then
    local gap = (270-self._scroll.height)/(self._numItems-12)
    local max_y = 270-self._scroll.height

    self._topItem = math.min(math.max(1, self._topItem-y), self._numItems-11)
    self._scroll.y = math.max(0, math.min(self._scroll.y+gap*-y, max_y))
  end
end

function FileChooser:update (dt)
  if not self._closed then
    local width, height = love.window.getMode()
    local x, y = width/2-250, height/2-175

    self._gui.layout:reset(x+5, y+5)
    self._gui.layout:padding(5, 5)

    for i = self._folders.top, self._folders.size do
      local x, y, width, height = self._gui.layout:col(self._folders[i].render:getWidth()+20, 24)
      if self._gui:Button(self._folders[i].name, x, y, width, height).hit then
        self:_returnFolder(i)
        return
      end
    end

    self._gui.layout:push(x+5, y+40)
    if self._numItems > 0 then
      for i = self._topItem, math.min(self._topItem+10, self._numItems) do
        local options = {
          dir = self._items[i].mode == "directory",
          align = "left",
          draw = FileChooser._drawButton,
          color = {
            normal  = {bg = {0, 0, 0, 0},   fg = {1, 1, 1}},
            hovered = {bg = {1, 1, 1, .25}, fg = {1, 1, 1}},
          }
        }

        if self._gui:Button(self._items[i].name, options, self._gui.layout:row(470, 20)).hit then
          if self._items[i].mode == "directory" then
            self:_openFolder(self._items[i])
            return
          else
            if self._mode == "open" then
              if self._onSuccess then
                self._onSuccess(FileChooser._append(self._path, self._items[i].name))
              end
              self._closed = true
            end
          end
        end

      end
    else
      self._gui:Label("The folder is empty", self._gui.layout:row(480, 20))
    end

    local red = {
          color = {
              normal  = {bg = {.7, .0, .0}, fg = {1, 1, 1}},
              hovered = {bg = {.9, .0, .0}, fg = {1, 1, 1}},
              active  = {bg = {1,  .6,  0}, fg = {1, 1, 1}}
          }
        }
    local white = {color = {normal  = {bg = {.95, .95, .95}, fg = {.1, .1, .1}}}}
    local green = {
          color = {
              normal  = {bg = {0, .7, .0}, fg = {1, 1, 1}},
              hovered = {bg = {0, .9, .0}, fg = {1, 1, 1}},
              active  = {bg = {1, .6,  0}, fg = {1, 1, 1}}
          }
        }

    self._gui.layout:push(x+5, y+321)
    if self._mode == "open" then
      if self._gui:Button("Cancel", red, self._gui.layout:col(100, 24)).hit then
        if self._onCancel then self._onCancel() end
        self._closed = true
      end
    else
      if self._gui:Button("Cancel", red, self._gui.layout:col(50, 24)).hit then
        if self._onCancel then self._onCancel() end
        self._closed = true
      end

      self._filename.id = self._gui:Input(self._filename, white, self._gui.layout:col(380, 24)).id

      if self._gui:Button("Save", green, self._gui.layout:col(50, 24)).hit then
        if self._onSuccess then
          self._onSuccess(self._path, self._filename.text)
        end
        self._closed = true
      end
    end
  end
end

function FileChooser:draw ()
  if not self._closed then
    local width, height = love.window.getMode()
    local x, y = width/2-250, height/2-175

    love.graphics.setColor(0, 0, 0, .5)
    love.graphics.rectangle("fill", x, y, 500, 350, 5, 5)

    love.graphics.setColor(.75, .75, .75)
    love.graphics.setLineStyle("rough")
    love.graphics.setLineWidth(1)
    love.graphics.line(x+5, y+35, x+495, y+35)
    love.graphics.line(x+5, y+314, x+495, y+314)

    love.graphics.setColor(1, 1, 1, 1)
    self._gui:draw()

    if self._numItems > 11 then
      love.graphics.setColor(1, 1, 1, .25)
      love.graphics.rectangle("fill", x+485, y+40+self._scroll.y, 10, self._scroll.height, 5, 5)
    end
  end
end

return setmetatable(FileChooser, {__call = FileChooser.new})
