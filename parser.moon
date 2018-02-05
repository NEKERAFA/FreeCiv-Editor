-- Rafael Alcalde Azpiazu - 31 Jan 2018
-- Facultade de Informática da Coruña - Universidade da Coruña
--
-- This file parsers the output of the ASP Clingo Solver and converts it in a
-- Freeciv map file

parser_string = "cell%((%d+),(%d+),(%l+)%)"

-- Gets a string result and parse it
parse = (answer, rows, columns, str) ->
  -- Creates a array map
  map = {}
  for i = 1, rows
    row = {}
    for j = 1, columns
      table.insert row, 'water'
    table.insert map, row

  -- Parses the result and inserts in the map
  for row, col, contain in string.gmatch str, parser_string
    i = tonumber row
    j = tonumber col
    unless map[i][j] == 'water' then
      error "cell (#{i}, #{j}) not empty. Assigned #{map[i][j]}, got #{contain}"

    map[i][j] = contain

  return map

{ :parse}
