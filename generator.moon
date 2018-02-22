-- Rafael Alcalde Azpiazu - 01 Feb 2018
-- Facultade de Informática da Coruña - Universidade da Coruña
--
-- This file calls to clingo to generate a new map, parses it and transforms in
-- a Freeciv scenario file

parser     = require 'parser'
translator = require 'translator'

-- Variables
rows = 30
columns = 40
solutions = 1
answer = 0
name = "My Map"
output = "map"

USAGE = "lua ./generate.lua options\n"
USAGE ..= "\nOPTIONS:\n\t-d=rows,columns\n\t-s=solutions\n\t-a=answer\n\t-n=name\n\t-o=output"
PARSE_DIM = "-d=(%d+),(%d+)"
PARSE_SOL = "-s=(%d+)"
PARSE_ANSWER = "-a=(%d+)"
PARSE_NAME = "-n=(%w+)"
PARSE_OUT = "-o=(%w+)"

FILES = "map.asp generate_map.asp"

-- This function prints a error if a argument not matches
error_arg = (arg) ->
  error "Format #{arg} not recognize\n#{USAGE}", 2

-- This function parse all arguments
parse_args = (args) ->
  for arg in *args do
    switch string.sub arg, 1, 2
      when "-d"
        if not string.find arg, PARSE_DIM then error_arg arg
        rows, columns = string.match arg, PARSE_DIM
      when "-s"
        if not string.find arg, PARSE_SOL then error_arg arg
        solutions = string.match arg, PARSE_SOL
      when "-a"
        if not string.find arg, PARSE_ANSWER then error_arg arg
        answer = string.match arg, PARSE_ANSWER
      when "-n"
        if not string.find arg, PARSE_NAME then error_arg arg
        name = string.match arg, PARSE_NAME
      when "-o"
        if not string.find arg, PARSE_OUT then error_arg arg
        output = string.match arg, PARSE_OUT
      when "-h"
        print USAGE .. "\n"
        os.exit()
      else
        error_arg arg

-- This function generates a list of start position to nations
generate_startpos = (terrain) ->
  startpos = {}
  map = {{}}
  line = 1

  -- Generate the list of cells that can travel
  for row = 1, rows do
    for col = 1, columns do
      if terrain[row][col][1] != "ocean" then
        table.insert(map[line], {x: col-1, y: row-1})
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
    print USAGE
    os.exit(0)

  parse_args args

  info = {}
  answers = {}
  answer = false

  prog = "clingo #{solutions} #{FILES} -c rows=#{rows} -c cols=#{columns}"

  -- Loads Solver
  print "> #{prog}"
  result = io.popen prog

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
      map = parser.parse i, rows, columns, answers[i]
      startpos = generate_startpos map
      translator.translate "map-#{i}.sav", name, rows, columns, map, startpos

  else
    for info_str in *info
      print info_str

main #arg, arg
