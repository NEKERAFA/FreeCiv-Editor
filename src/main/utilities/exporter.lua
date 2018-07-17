-- Rafael Alcalde Azpiazu - 01 Feb 2018
-- Facultade de Informática da Coruña - Universidade da Coruña
--
-- This file gets the result of the parser and converts it in Freeciv map file

-- Variables
local NAME = "::NAME::"
local PLAYERS = "::PLAYERS::"
local ROWS = "::ROWS::"
local COLUMNS = "::COLUMNS::"
local TERRAIN = "::TERRAIN::"
local PLAYER_LIST = "::PLAYER_LIST::"
local LAYER_B = "::LAYER_B::"
local LAYER_R = "::LAYER_R::"

-- Generates the string of the map representation
local get_map = function (rows, columns, terrain)
  local map = ""

  -- Creates the map representation string
  for i = 1, rows do
    map = map .. string.format("t%04i=\"", (i-1))
    for j = 1, columns do
      value = terrain[i][j][1]
      if value == "glacier" then
        map = map .. "a"
      elseif value == "ocean" then
        map = map .. ":"
      elseif value == "shore" then
        map = map .. " "
      elseif value == "desert" then
        map = map .. "d"
      elseif value == "forest" then
        map = map .. "f"
      elseif value == "plains" then
        map = map .. "p"
      elseif value == "grass" then
        map = map .. "g"
      elseif value == "hills" then
        map = map .. "h"
      elseif value == "jungle" then
        map = map .. "j"
      elseif value == "mountains" then
        map = map .. "m"
      elseif value == "swamp" then
        map = map .. "s"
      elseif value == "tundra" then
        map = map .. "t"
      end
    end

    if i < rows then
      map = map .. "\"\n"
    else
      map = map .. "\""
    end
  end

  return map
end

-- Generates the string of the start position
local get_startpos = function (startpos)
  local s_startpos = ""

  -- Creates the start position string
  for i = 1, #startpos do
    local pos = startpos[i]
    if i < #startpos then
      s_startpos = s_startpos.."#"..tostring(pos.x)..",#"..tostring(pos.y)..",FALSE,\"\"\n"
    else
      s_startpos = s_startpos.."#"..tostring(pos.x)..",#"..tostring(pos.y)..",FALSE,\"\""
    end
  end

  return s_startpos
end

-- Generates the string of the b00 layer map
local get_b_layer = function (rows, columns)
  local b_layer = ""

  for i = 1, rows do
    b_layer = b_layer .. string.format("b00_%04i=\"", (i-1))
    for j = 1, columns do
      b_layer = b_layer .. "0"
    end

    if i < rows then
      b_layer = b_layer .. "\"\n"
    else
      b_layer = b_layer .. "\""
    end
  end

  return b_layer
end

-- Generates the string of the r00 layer map
local get_r_layer = function (rows, columns)
  local r_layer = ""

  for i = 1, rows do
    r_layer = r_layer .. string.format("r00_%04i=\"", (i-1))
    for j = 1, columns do
      r_layer = r_layer .. "0"
    end

    if i < rows then
      r_layer = r_layer .. "\"\n"
    else
      r_layer = r_layer .. "\""
    end
  end

  return r_layer
end

local exporter = {
  -- Gets the parse table and translate it into a Freeciv map file
  export = function (file, name, rows, columns, terrain, startpos)
    local s_map = get_map(rows, columns, terrain)
    local s_startpos = get_startpos(startpos)
    local s_b_layer = get_b_layer(rows, columns)
    local s_r_layer = get_r_layer(rows, columns)

    -- Open files
    local template = io.open("resources/scenario.txt", "r")
    local generated = io.open(file, "w+")

    -- Replace the parameters
    for line in template:lines() do
      line = string.gsub(line, NAME, name)
      line = string.gsub(line, PLAYERS, tostring(#startpos))
      line = string.gsub(line, ROWS, rows)
      line = string.gsub(line, COLUMNS, columns)
      line = string.gsub(line, TERRAIN, s_map)
      line = string.gsub(line, PLAYER_LIST, s_startpos)
      line = string.gsub(line, LAYER_B, s_b_layer)
      line = string.gsub(line, LAYER_R, s_r_layer)
      generated:write(line .. "\n")
    end

    -- Close files
    generated:flush()
    generated:close()
    template:close()
  end
}

return exporter
