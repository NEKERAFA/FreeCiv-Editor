-- Rafael Alcalde Azpiazu - 01 Feb 2018
-- This file gets the result of the parser and converts it in Freeciv map file

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

{ :translate}
