local benchmarks = require "benchmarks.benchmarks"

--------------------------------------------------------------------------------

print("Benchmarks with diferents percentages of land and biomas.")

local startTime = os.time()
do
  local islands = math.floor(math.sqrt(25) - 1)

  local n1 = islands
  while 25 % n1 ~= 0 do
    n1 = n1 + 1
  end

  local n2 = math.floor(25 / n1)

  local div = math.min(n1, n2)
  local cells = math.max(n1, n2)

  for land = 70, 80, 5 do
    for bioma = 10, 80, 5 do
      benchmarks.addbenchmark("Land and bioma: " .. tostring(land) .. "%, " ..
          tostring(bioma) .. "%", 5, {q_rows=div, q_cols=div, c_rows=cells,
          c_cols=cells, land=land, terrain=bioma, regions=islands})
    end
  end
end
local endTime = os.time()

print("Completed in " .. os.difftime(endTime, startTime) .. " s")

benchmarks.writeresults("performance.json")
