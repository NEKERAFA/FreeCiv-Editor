-- Rafael Alcalde Azpiazu - 01 Feb 2018
-- This file calls to clingo to generate a new map, parses it and transforms in
-- a Freeciv scenario file

parser     = require 'parser'
translator = require 'translator'

-- Variables
export rows = 10
export columns = 10
export solutions = 1
export output = "my_map"

usage = "lua ./generate.lua [-d=rows,columns] -s=solutions -o=output"
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
        if string.find arg, parse_dim then error_arg arg
        rows, columns = string.match arg, parse_dim
      when "-s"
        if string.find arg, parse_sol then error_arg arg
        solutions = string.match arg, parse_sol
      when "-o"
        if string.find parse_out then error_arg arg
        output = string.match arg, parse_out
      else
        error_arg arg

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
      translator.translate "map-#{i}.sav", map

  else
    for info_str in *info
      print info_str

main #arg, arg
