-- Rafael Alcalde Azpiazu - 01 Feb 2018
-- Facultade de Informática da Coruña - Universidade da Coruña
--
-- This file calls to clingo to generate a new map, parses it and transforms in
-- a Freeciv scenario file

parser     = require 'parser'
translator = require 'translator'

-- Variables
export rows = 10
export columns = 20
export solutions = 1
export output = "my_map"

usage = "lua ./generate.lua [-d=rows,columns] [-s=solutions] [-o=output]"
parse_dim = "-d=(%d+),(%d+)"
parse_sol = "-s=(%d+)"
parse_out = "-o=(%w+)"

files = "map.txt"

-- This function prints a error if a argument not matches
error_arg = (arg) ->
  error "Format #{arg} not recognize\n#{usage}", 2

-- This function parse all arguments
parse_args = (args) ->
  for arg in *args do
    switch string.sub arg, 1, 2
      when "-d"
        if not string.find arg, parse_dim then error_arg arg
        rows, columns = string.match arg, parse_dim
      when "-s"
        if not string.find arg, parse_sol then error_arg arg
        solutions = string.match arg, parse_sol
      when "-o"
        if not string.find arg, parse_out then error_arg arg
        output = string.match arg, parse_out
      when "-h"
        print usage
        os.exit()
      else
        error_arg arg

-- This function generates a list of start position to nations
generate_startpos = (terrain) ->
  startpos = {}
  map = {{}}
  line = 1

  -- Generate the list of cells that can travel
  for i = 1, rows do
    for j = 1, columns do
      if terrain[i][j] == "grass" then
        table.insert(map[line], {x: i-1, y: j-1})
    if #map[line] > 0 then
      table.insert(map, {})
      line += 1
  if #map[line] == 0 then
    table.remove(map)

  math.randomseed(os.time())

  -- Select the start positions
  while #startpos < 5 and #map > 0 do
    i = math.random(1, #map)
    j = math.random(1, #map[i])
    table.insert(startpos, map[i][j])
    table.remove(map[i], j)
    if #map[i] == 0 then
      table.remove(map, i)

  startpos

-- Main function
main = (number, args) ->
  -- Checks arguments
  if number > 3 then
    print usage
    os.exit(0)

  parse_args args

  info = {}
  answers = {}
  answer = false

  -- Loads Solver
  print "> clingo #{solutions} #{files}"
  result = io.popen "clingo #{solutions} #{files}"

  -- Splits the result in lines into a table
  for line_str in result\lines!
    if answer then
      table.insert answers, line_str
      answer = false
    elseif string.find line_str, "Answer"
      answer = true
    else
      if string.find line_str, "UNKNOWN" then
        os.exit(-1)

      table.insert info, line_str

  results = #answers

  -- Parse the answers
  if results > 0 then
    print "Answers: #{tostring results}"

    for i = 1, results do
      map = parser.parse i, answers[i]
      startpos = generate_startpos map
      translator.translate output, "map-#{i}.sav", rows, columns, map, startpos

  else
    for info_str in *info
      print info_str

main #arg, arg
