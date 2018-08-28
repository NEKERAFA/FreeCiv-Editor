--- This class defines a popup window to modified the parameters in the generation.
-- @classmod Widget.GenerateMap

local Suit = require "libs.suit"
local Class = require "libs.hump.class"

local GenerateMap = {}
GenerateMap.__index = GenerateMap

--------------------------------------------------------------------------------

--- Creates a new widget object.
-- @param ... A table with "onSuccess" and "onCancel" functions.
function GenerateMap:new (...)
  args = {...}
  local obj = setmetatable({}, self)
  obj._onSuccess = args[1] or args.onSuccess
  obj._onCancel = args[2] or args.onCancel
  obj._gui = Suit.new()
  obj._gui.theme = setmetatable({}, {__index = Suit.theme})
  obj._gui.theme.Input = GenerateMap.drawInput
  -- obj._canvas = love.graphics.newCanvas()

  -- Texto que sale en los inputs
  obj._regions = {text = "2"}
  obj._land = {value = 40, min = 10, max = 100, step = 10}
  obj._terrain = {value = 20, min = 10, max = 100, step = 10}
  obj._size_mountains = {text = "2"}
  obj._length_mountains = {value = 4, min = 1, max = 10, step = 1}
  obj._players = {text = "3"}
  -- Si se ha cerrado el popup
  obj._closed = false
  return obj
end

function GenerateMap.drawInput (input, opt, x, y, w, h)
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
function GenerateMap:isMouseFocused ()
  local width, height = love.window.getMode()
  local posX, posY = love.mouse.getPosition()
  local x, y = width/2-150, height/2-90

  return posX >= x and posX <= x + 300 and posY >= y and posY <= y + 180
end

--- Adds text to input widgets. Use this function with love.textinput.
-- @param t The text to add to a input widget.
function GenerateMap:textInput (t)
  if not self._closed then
    self._gui:textinput(t)
  end
end

function GenerateMap:keyPressed (key)
  if not self._closed then
    self._gui:keypressed(key)
  end
end

--- Updates the widget.
-- @param dt The time in seconds since the last update.
function GenerateMap:update (dt)
  if not self._closed then
    local width, height = love.window.getMode()
    local x, y = width/2-150, height/2-90

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
    local white_right_text = {
          color = {normal = {fg = {1, 1, 1}}},
          align = "right"
    }
    local green_button = {
          color = {
              normal  = {bg = {0, .7, .0}, fg = {1, 1, 1}},
              hovered = {bg = {0, .9, .0}, fg = {1, 1, 1}},
              active  = {bg = {1, .6,  0}, fg = {1, 1, 1}}
          }
    }

    -- Número de islas
    self._gui.layout:reset(x+5, y+5)
    self._gui.layout:padding(90, 0)
    self._gui:Label("Number of islands: ", Class.clone(white_left_text), self._gui.layout:col(160, 20))
    self._gui:Input(self._regions, Class.clone(white_right_input), self._gui.layout:col(40, 20))

    -- Cantidad de tierra que se alcanza
    self._gui.layout:push(x+5, y+30)
    self._gui.layout:padding(0, 0)
    self._gui:Label("Land reached: ", Class.clone(white_left_text), self._gui.layout:col(160, 20))
    self._gui:Slider(self._land, self._gui.layout:col(80, 20))
    self._gui:Label(tostring(math.floor(self._land.value/10)*10) .. "%", Class.clone(white_right_text), self._gui.layout:col(50, 20))

    -- Tamaño de las celdas de los biomas
    self._gui.layout:push(x+5, y+55)
    self._gui:Label("Size of biomas: ", Class.clone(white_left_text), self._gui.layout:col(160, 20))
    self._gui:Slider(self._terrain, self._gui.layout:col(80, 20))
    self._gui:Label(tostring(math.floor(self._terrain.value/10)*10) .. "%", Class.clone(white_right_text), self._gui.layout:col(50, 20))

    -- Ancho de las coordilleras
    self._gui.layout:push(x+5, y+80)
    self._gui.layout:padding(90, 0)
    self._gui:Label("Width of mountains: ", Class.clone(white_left_text), self._gui.layout:col(160, 20))
    self._gui:Input(self._size_mountains, Class.clone(white_right_input), self._gui.layout:col(40, 20))

    -- Longitud de las coordilleras
    self._gui.layout:push(x+5, y+105)
    self._gui.layout:padding(0, 0)
    self._gui:Label("Length of mountains: ", Class.clone(white_left_text), self._gui.layout:col(160, 20))
    self._gui:Slider(self._length_mountains, self._gui.layout:col(80, 20))
    self._gui:Label(math.floor(self._length_mountains.value), Class.clone(white_right_text), self._gui.layout:col(50, 20))

    -- Longitud de las coordilleras
    self._gui.layout:push(x+5, y+130)
    self._gui.layout:padding(90, 0)
    self._gui:Label("Number of players: ", Class.clone(white_left_text), self._gui.layout:col(160, 20))
    self._gui:Input(self._players, self._gui.layout:col(40, 20))

    -- Botones de la
    self._gui.layout:push(x+5, y+155)
    self._gui.layout:padding(130, 5)

    -- Botón para cancelar
    if self._gui:Button("Cancel", red_button, self._gui.layout:row(80, 20)).hit then
      if self._onCancel then self._onCancel() end
      self._closed = true
    end

    -- Botón para aceptar
    if self._gui:Button("Ok", green_button, self._gui.layout:col(80, 20)).hit then
      if self._onSuccess then
        local regions = tonumber(self._regions.text)
        local land = math.floor(self._land.value/10)*10
        local terrain = math.floor(self._terrain.value/10)*10
        local size_mountains = tonumber(self._size_mountains.text)
        local width_mountains = math.floor(self._length_mountains.value)
        local players = tonumber(self._players.text)
        self._onSuccess(regions, land, terrain, size_mountains, width_mountains, players)
      end
      self._closed = true
    end

  end
end

--- Draws the widget.
function GenerateMap:draw ()
  if not self._closed then
    local width, height = love.window.getMode()
    local x, y = width/2-150, height/2-90

    love.graphics.setColor(0, 0, 0, .5)
    love.graphics.rectangle("fill", x, y, 300, 180, 5, 5)

    love.graphics.setColor(1, 1, 1)
    self._gui:draw()
  end
end

return setmetatable(GenerateMap, {__call = GenerateMap.new})
