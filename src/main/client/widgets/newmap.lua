--- This class defines a popup window to create new map.
-- @classmod Widget.NewMap

local Suit = require "libs.suit"
local Class = require "libs.hump.class"

local NewMap = {}
NewMap.__index = NewMap

--------------------------------------------------------------------------------

--- Creates a new widget object.
-- @param ... A table with "onSuccess" and "onCancel" functions.
function NewMap:new (...)
  args = {...}
  local obj = setmetatable({}, self)
  obj._onSuccess = args[1] or args.onSuccess
  obj._onCancel = args[2] or args.onCancel
  obj._gui = Suit.new()
  obj._gui.theme = setmetatable({}, {__index = Suit.theme})
  obj._gui.theme.Input = NewMap.drawInput

  -- Texto que sale en los inputs
  obj._rows = {text = "12"}
  obj._cols = {text = "12"}
  -- Si se ha cerrado el popup
  obj._closed = false
  return obj
end

function NewMap.drawInput (input, opt, x, y, w, h)
	local utf8 = require 'utf8'
	Suit.theme.drawBox(x,y,w,h, (opt.color and opt.color.normal) or {bg = {1, 1, 1}}, opt.cornerRadius)
	x = x + 3
	w = w - 6

	local th = opt.font:getHeight()

	-- set scissors
	local sx, sy, sw, sh = love.graphics.getScissor()
	love.graphics.setScissor(x-1,y,w+2,h)
	x = x - input.text_draw_offset

	-- text
	love.graphics.setColor((opt.color and opt.color.normal and opt.color.normal.fg) or {0.25, 0.25, 0.25})
	love.graphics.setFont(opt.font)
	love.graphics.print(input.text, x, y+(h-th)/2)

	-- candidate text
	local tw = opt.font:getWidth(input.text)
	local ctw = opt.font:getWidth(input.candidate_text.text)
	love.graphics.print(input.candidate_text.text, x + tw, y+(h-th)/2)

	-- candidate text rectangle box
	love.graphics.rectangle("line", x + tw, y+(h-th)/2, ctw, th)

	-- cursor
	if opt.hasKeyboardFocus and (love.timer.getTime() % 1) > .5 then
		local ct = input.candidate_text;
		local ss = ct.text:sub(1, utf8.offset(ct.text, ct.start))
		local ws = opt.font:getWidth(ss)
		if ct.start == 0 then ws = 0 end

		love.graphics.setLineWidth(1)
		love.graphics.setLineStyle('rough')
		love.graphics.line(x + opt.cursor_pos + ws, y + (h-th)/2,
		                   x + opt.cursor_pos + ws, y + (h+th)/2)
	end

	-- reset scissor
	love.graphics.setScissor(sx,sy,sw,sh)
end

--- Checks if the mouse has the focus in this widget.
-- @return True if mouse has the focus and false otherwise.
function NewMap:isMouseFocused ()
  local width, height = love.window.getMode()
  local posX, posY = love.mouse.getPosition()
  local x, y = width/2-105, height/2-15

  return posX >= x and posX <= x + 210 and posY >= y and posY <= y + 55
end

--- Adds text to input widgets. Use this function with love.textinput.
-- @param t The text to add to a input widget.
function NewMap:textInput (t)
  if not self._closed then
    self._gui:textinput(t)
  end
end

function NewMap:keyPressed (key)
  if not self._closed then
    self._gui:keypressed(key)
  end
end

--- Updates the widget.
-- @param dt The time in seconds since the last update.
function NewMap:update (dt)
  if not self._closed then
    local width, height = love.window.getMode()
    local x, y = width/2-105, height/2-15

    -- Para comprobar si se introducen elementos que no son números
    self._nan_input = false

    local red_input = {color = {normal = {bg = {1, 0.25, 0.25}, fg = {1, 1, 1}}}}
    local red_button = {
          color = {
              normal  = {bg = {.7, .0, .0}, fg = {1, 1, 1}},
              hovered = {bg = {.9, .0, .0}, fg = {1, 1, 1}},
              active  = {bg = {1,  .6,  0}, fg = {1, 1, 1}}
          }
        }
    local white_left_text = {
          color = {normal = {fg = {1, 1, 1}}},
          align = "left"
    }
    local white_center_text = {
          color = {normal = {fg = {1, 1, 1}}},
          align = "center"
    }
    local green_button = {
          color = {
              normal  = {bg = {0, .7, .0}, fg = {1, 1, 1}},
              hovered = {bg = {0, .9, .0}, fg = {1, 1, 1}},
              active  = {bg = {1, .6,  0}, fg = {1, 1, 1}}
          }
        }

    -- Mostramos los inputs del número de cuadrantes
    self._gui.layout:reset(x+5, y+5)
    self._gui:Label("Size of map: ", Class.clone(white_left_text), self._gui.layout:col(140, 20))
    if tonumber(self._rows.text) == nil then
      self._nan_input = true
      self._gui:Input(self._rows, Class.clone(red_input), self._gui.layout:col(20, 20))
    else
      self._gui:Input(self._rows, self._gui.layout:col(20, 20))
    end

    self._gui:Label("x", Class.clone(white_center_text), self._gui.layout:col(20, 20))

    if tonumber(self._cols.text) == nil then
      self._nan_input = true
      self._gui:Input(self._cols, Class.clone(red_input), self._gui.layout:col(20, 20))
    else
      self._gui:Input(self._cols, self._gui.layout:col(20, 20))
    end

    self._gui.layout:push(x+5, y+30)
    self._gui.layout:padding(40, 5)
    -- Comprobamos que se hayan introducido números en los campos de texto
    if self._nan_input then
      self._gui:Label("Must be a number", {color = {normal  = {fg = {1, 0, 0}}}}, self._gui.layout:row(200, 20))
    end

    -- Botón para cancelar
    if self._gui:Button("Cancel", red_button, self._gui.layout:row(80, 20)).hit then
      if self._onCancel then self._onCancel() end
      self._closed = true
    end

    -- Botón para aceptar
    local status = self._gui:Button("Ok", green_button, self._gui.layout:col(80, 20))
    if status.hit and not self._nan_input then
      if self._onSuccess then
        local rows = tonumber(self._rows.text)
        local cols = tonumber(self._cols.text)
        self._onSuccess(rows, cols)
      end
      self._closed = true
    end

  end
end

--- Draws the widget.
function NewMap:draw ()
  if not self._closed then
    local width, height = love.window.getMode()
    local x, y = width/2-105, height/2-15
    local h = 55

    love.graphics.setColor(0, 0, 0, .5)
    love.graphics.rectangle("fill", x, y, 210, h, 5, 5)

    love.graphics.setColor(1, 1, 1)
    self._gui:draw()
  end
end

return setmetatable(NewMap, {__call = NewMap.new})
