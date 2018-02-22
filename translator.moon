-- Rafael Alcalde Azpiazu - 01 Feb 2018
-- Facultade de Informática da Coruña - Universidade da Coruña
--
-- This file gets the result of the parser and converts it in Freeciv map file

-- Variables
NAME = "::NAME::"
PLAYERS = "::PLAYERS::"
ROWS = "::ROWS::"
COLUMNS = "::COLUMNS::"
TERRAIN = "::TERRAIN::"
PLAYER_LIST = "::PLAYER_LIST::"
LAYER_B = "::LAYER_B::"
LAYER_R = "::LAYER_R::"

-- Generates the string of the map representation
get_map = (rows, columns, terrain) ->
  map = ""
  -- Creates the map representation string
  for i = 1, rows do
    map ..= string.format "t%04i=\"", (i-1)
    for j = 1, columns do
      value = terrain[i][j][1]
      switch value
        when "glacier"
          map ..= "a"
        when "ocean"
          map ..= ":"
        when "desert"
          map ..= "d"
        when "forest"
          map ..= "f"
        when "plains"
          map ..= "p"
        when "grass"
          map ..= "g"
        when "hills"
          map ..= "h"
        when "jungle"
          map ..= "j"
        when "mountains"
          map ..= "m"
        when "swamp"
          map ..= "s"
        when "tundra"
          map ..= "t"

    if i < rows then
      map ..= "\"\n"
    else
      map ..= "\""
  map

-- Generates the string of the start position
get_startpos = (startpos) ->
  s_startpos = ""
  -- Creates the start position string
  for i = 1, #startpos do
    pos = startpos[i]
    if i < #startpos then
      s_startpos ..= "#{pos.x},#{pos.y},FALSE,\"\"\n"
    else
      s_startpos ..= "#{pos.x},#{pos.y},FALSE,\"\""
  s_startpos

-- Generates the string of the b00 layer map
get_b_layer = (rows, columns) ->
  b_layer = ""
  for i = 1, rows do
    b_layer ..= string.format "b00_%04i=\"", (i-1)
    for j = 1, columns do
      b_layer ..= "0"
    if i < rows then
      b_layer ..= "\"\n"
    else
      b_layer ..= "\""
  b_layer

-- Generates the string of the r00 layer map (resources layer)
get_r_layer = (rows, columns) ->
  r_layer = ""
  for i = 1, rows do
    r_layer ..= string.format "r00_%04i=\"", (i-1)
    for j = 1, columns do
      r_layer ..= "0"
    if i < rows then
      r_layer ..= "\"\n"
    else
      r_layer ..= "\""
  r_layer

-- Gets the parse table and translate it into a Freeciv map file
translate = (file, name, rows, columns, terrain, startpos) ->
  s_map = get_map rows, columns, terrain
  s_startpos = get_startpos startpos
  s_b_layer = get_b_layer rows, columns
  s_r_layer = get_r_layer rows, columns

  -- Open files
  template = io.open "scenario.txt", "r"
  generated = io.open file, "w+"

  -- Replace the parameters
  for line in template\lines! do
    line = string.gsub line, NAME, name
    line = string.gsub line, PLAYERS, tostring #startpos
    line = string.gsub line, ROWS, rows
    line = string.gsub line, COLUMNS, columns
    line = string.gsub line, TERRAIN, s_map
    line = string.gsub line, PLAYER_LIST, s_startpos
    line = string.gsub line, LAYER_B, s_b_layer
    line = string.gsub line, LAYER_R, s_r_layer
    generated\write line .. "\n"

  -- Close files
  generated\flush!
  generated\close!
  template\close!

{ :translate}
