local Json = require "src.libs.json.json"

local bench = {}
local bench_num = 1

--------------------------------------------------------------------------------

-- Función que mide el tiempo de ejecución de una llamada
function getTime(f)
  collectgarbage()

  local time, executions = 0, 0
  local continue = true

  while continue do
    local startTime, endTime

    startTime = os.clock(); f(); endTime = os.clock()

    time = time + endTime - startTime
    executions = executions + 1

    continue = (executions < 1000) and ((endTime - startTime) < 5) and (time < 120)
  end

  return time / executions, executions
end

-- Se
function log(t)
  print("Bench " .. tostring(bench_num) .. ". " .. t.name .. ": " ..
          tostring(t.time) .. "s in " .. tostring(t.executions) .. " executions")
  bench_num = bench_num + 1
end

--------------------------------------------------------------------------------

print("Benchs with diferents sizes")

-- Comprueba cuanto tarda en ejecutar con distintos tamaños de mapa
for size = 10, 80, 5 do
  local div = math.floor(math.sqrt(size) - 1)

  while size % div ~= 0 do
    div = div + 1
  end

  local cells = math.floor(size / div)
  local constants = "-c q_rows=" .. div ..
        " -c q_cols=" .. div .. " -c c_rows=" .. cells ..
        " -c c_cols=" .. cells

  local function f()
    df = assert(io.popen("cd src && clingo " .. constants .." main/asp/generator.lp"))
    df:close()
  end

  local time, executions = getTime(f)

  new_bench = {name = "Tamaño " .. tostring(size) .. "x" .. tostring(size), time = time, executions = executions}
  table.insert(bench, new_bench)
  log(new_bench)
end

print("\nBenchs with diferents percentages of land")

local div = math.floor(math.sqrt(20) - 1)
while 20 % div ~= 0 do
  div = div + 1
end
local cells = math.floor(20 / div)

for percentaje = 10, 60, 5 do
  local constants = "-c q_rows=" .. div ..
        " -c q_cols=" .. div .. " -c c_rows=" .. cells ..
        " -c c_cols=" .. cells .. " -c land=" .. percentaje

  local function f()
    df = assert(io.popen("cd src && clingo 1 " .. constants .." main/asp/generator.lp"))
    df:close()
  end

  local time, executions = getTime(f)

  new_bench = {name = "Porcentaje de tierra " .. tostring(percentaje) .. "%", time = time, executions = executions}
  table.insert(bench, new_bench)
  log(new_bench)
end

local result = io.open("result.json", "w+")
result:write(Json.encode(bench))
result:close()
