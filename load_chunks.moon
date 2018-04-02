PARSER_STRING = "cell%((%d+),(%l+)%)"

-- Gets a string result and parse it
parse = (answer, rows, columns, str) ->
    -- Creates a array map
    map = {}
    for i = 1, rows
        row = {}
        for j = 1, columns
            table.insert row, {' ', -1}
        table.insert map, row

    -- Parses the result and inserts in the map
    for position, contain in string.gmatch str, parser_string
        p = tonumber position
        i = math.floor(p/columns)+1
        j = (p%columns)+1
        unless map[i][j][2] == -1 then
            error "cell[#{p}] (#{i}, #{j}) not empty. Assigned cell[#{map[i][j][2]}]: #{map[i][j][1]}, got #{contain}"

        map[i][j] = {contain, p}

    return map
