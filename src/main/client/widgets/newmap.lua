local Suit = require "libs.suit"
local Class = require "libs.hump.class"

local NewMap = {}
NewMap.__index = NewMap

--------------------------------------------------------------------------------

function NewMap:new (onSuccess, onCancel)
  local obj = setmetatable({}, self)
  obj._onSuccess = onSuccess
  obj._onCancel = onCancel
  obj._gui = Suit.new()
  obj._gui.theme = setmetatable({}, {__index = Suit.theme})
  obj._gui.theme.Input = NewMap.drawInput
  obj._canvas = love.graphics.newCanvas()

  -- Texto que sale en los inputs
  obj._regions = {text = "2"}
  obj._q_rows = {text = "3"}
  obj._q_cols = {text = "3"}
  obj._c_rows = {text = "4"}
  obj._c_cols = {text = "4"}
  -- Mira si se ha introducido un elemento no numérico
  obj._nan_input = false
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

function NewMap:isMouseFocused ()
  local width, height = love.window.getMode()
  local posX, posY = love.mouse.getPosition()
  local x, y = width/2-105, height/2-53
  return posX >= x and posX <= x + width and posY >= y and posY <= y + height
end

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

function NewMap:update (dt)
  if not self._closed then
    local width, height = love.window.getMode()
    local x, y = width/2-105, height/2-53

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

    -- Mostramos los inputs del número de regiones
    self._gui.layout:reset(x+5, y+5)
    self._gui:Label("Number of regions: ", Class.clone(white_left_text), self._gui.layout:col(180, 20))
    if tonumber(self._regions.text) == nil then
      self._nan_input = true
      self._gui:Input(self._regions, Class.clone(red_input), self._gui.layout:col(20, 20))
    else
      self._gui:Input(self._regions, self._gui.layout:col(20, 20))
    end

    -- Mostramos los inputs del número de cuadrantes
    self._gui.layout:push(x+5, y+30)
    self._gui:Label("Number of quadrants: ", Class.clone(white_left_text), self._gui.layout:col(140, 20))
    if tonumber(self._q_rows.text) == nil then
      self._nan_input = true
      self._gui:Input(self._q_rows, Class.clone(red_input), self._gui.layout:col(20, 20))
    else
      self._gui:Input(self._q_rows, self._gui.layout:col(20, 20))
    end

    self._gui:Label("x", Class.clone(white_center_text), self._gui.layout:col(20, 20))

    if tonumber(self._q_cols.text) == nil then
      self._nan_input = true
      self._gui:Input(self._q_cols, Class.clone(red_input), self._gui.layout:col(20, 20))
    else
      self._gui:Input(self._q_cols, self._gui.layout:col(20, 20))
    end

    -- Mostramos los inputs del tamaño de los cuadrantes
    self._gui.layout:push(x+5, y+55)
    self._gui:Label("Size of quadrants: ", Class.clone(white_left_text), self._gui.layout:col(140, 20))
    if tonumber(self._c_rows.text) == nil then
      self._nan_input = true
      self._gui:Input(self._c_rows, Class.clone(red_input), self._gui.layout:col(20, 20))
    else
      self._gui:Input(self._c_rows, self._gui.layout:col(20, 20))
    end

    self._gui:Label("x", Class.clone(white_center_text), self._gui.layout:col(20, 20))

    if tonumber(self._c_cols.text) == nil then
      self._nan_input = true
      self._gui:Input(self._c_cols, Class.clone(red_input), self._gui.layout:col(20, 20))
    else
      self._gui:Input(self._c_cols, self._gui.layout:col(20, 20))
    end

    self._gui.layout:push(x+5, y+80)
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
        local regions = tonumber(self._regions.text)
        local q_rows = tonumber(self._q_rows.text)
        local q_cols = tonumber(self._q_cols.text)
        local c_rows = tonumber(self._c_rows.text)
        local c_cols = tonumber(self._c_cols.text)
        self._onSuccess(regions, q_rows, q_cols, c_rows, c_cols)
      end
      self._closed = true
    end

  end
end

-- Dibuja la interfaz
function NewMap:draw ()
  if not self._closed then
    local width, height = love.window.getMode()
    local x, y = width/2-105, height/2-53
    local h = 105
    if self._nan_input then
      h = h+25
    end

    love.graphics.setColor(0, 0, 0, .5)
    love.graphics.rectangle("fill", x, y, 210, h, 5, 5)

    love.graphics.setColor(1, 1, 1)
    self._gui:draw()
  end
end

return setmetatable(NewMap, {__call = NewMap.new})
