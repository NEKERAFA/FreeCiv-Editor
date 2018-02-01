-- Rafael Alcalde Azpiazu - 31 Jan 2018
-- This file parsers the output of the ASP Clingo Solver and converts it in a
-- Freeciv map file

rows = 0
columns = 0

usage = "lua ./parser.lua <rows> <columns>"

parser_string = "cell%((%d+),(%d+),(%l)%)"

-- Get the parse table and translate it into a Freeciv map file
translate = (file, terrain) ->
  print "Translate"

-- Gets a string result and parse it
parse = (answer, str) ->
  map = {}

  for i = 1, rows
    row = {}
    for j = 1, columns
      table.insert row ':'
    table.insert map row

  for row, col, c in string.gmatch str
    i = tonumber row
    j = tonumber col
    map[j] = c

-- Main function
main = (number, args) ->
  if number ~= 2 then
    print usage
    os.exit(0)

  rows = args[1]
  columns = args[2]

  -- Variables
  solver = "clingo"
  sol = "0"
  files = "map.txt"
  info = {}
  answers = {}
  answer = false

  -- Loads Solver
  print "> #{solver} #{sol} #{files}"
  result = io.popen "#{solver} #{sol} #{files}"

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

  -- Parse the contain
  if results > 0 then
    print "Answers: " .. (tostring results)
  else
    for info_str in *info
      print info_str

main #arg, arg
