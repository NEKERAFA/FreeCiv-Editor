-- Rafael Alcalde Azpiazu - 31 Jan 2018
-- This file parsers the output of the ASP Clingo Solver and converts it in a
-- Freeciv map file

parser_string = "cell%((%d+),(%d+),(%l+)%)"

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

{ :parse}
