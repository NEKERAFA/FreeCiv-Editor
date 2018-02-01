-- Rafael Alcalde Azpiazu - 31 Jan 2018
-- This file parsers the output of the ASP Clingo Solver and converts it in a
-- Freeciv map file

rows = 0
columns = 0

usage = "lua ./parser.lua <rows> <columns> <solutions>"

parser_string = "cell%((%d+),(%d+),(%l+)%)"

-- Get the parse table and translate it into a Freeciv map file
translate = (file, terrain) ->
  df = io.open file, "w+"

  for i = 1, rows do
    df\write string.format "t%04i=\"", (i-1)
    for j = 1, columns do
      value = terrain[i][j]
      switch value
        when 'water'
          df\write ":"
        when 'grass'
          df\write "g"
    df\write "\"\r\n"

  df\flush!
  df\close!

-- Gets a string result and parse it
parse = (answer, str) ->
  -- Creates a array map
  map = {}
  for i = 1, rows
    row = {}
    for j = 1, columns
      table.insert row, ''
    table.insert map, row

  -- Parses the result and inserts in the map
  for row, col, contain in string.gmatch str, parser_string
    i = tonumber row
    j = tonumber col
    unless map[i][j] == '' then
      error "cell (#{i}, #{j}) not empty. Assigned #{map[i][j]}, got #{contain}"

    map[i][j] = contain

  return map

-- Main function
main = (number, args) ->
  -- Checks arguments
  if number ~= 3 then
    print usage
    os.exit(0)

  -- Variables
  rows = args[1]
  columns = args[2]
  solver = "clingo"
  sol = args[3]
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

  -- Parse the answers
  if results > 0 then
    print "Answers: #{tostring results}"

    for i = 1, results do
      map = parse i, answers[i]
      translate "map-#{i}.txt", map

  else
    for info_str in *info
      print info_str

main #arg, arg
