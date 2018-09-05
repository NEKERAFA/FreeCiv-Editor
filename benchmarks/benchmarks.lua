local json = require "benchmarks.json"
local luaproc = require "luaproc"

local info = {}
local num = 1

--- Función que se ejecuta en un thread y que al pasar 5 min termina el proceso.
local function timer()
  local luaproc = require "luaproc"
  local os = require "os"
  local io = require "io"

  local startTime = os.time()
  local currentTime = startTime
  local oldTime = startTime
  local pid = assert(luaproc.receive("timer"))
  local finished = false

  repeat
    currentTime = os.time()
    finished = luaproc.receive("timer", true) or false

    if oldTime < currentTime then
      oldTime = currentTime
    end
  until finished or os.difftime(currentTime, startTime) >= 300

  if not finished then
    os.execute("/bin/kill " .. pid .. " 1>&- 2>&-")
  end

  luaproc.send("timer", true)
end

--- Hace una llamada a clingo restringiendo el tiempo de ejecución en 5 minutos
-- @param args Lista de parámetros que se pasan al módulo de clingo
-- @return Devuelve verdadero si clingo se ha ejecutado satisfactiblemente en el
-- tiempo establecido, devolviendo el tiempo de ejecución. Si no es satisfactible
-- devuelve false con el tiempo de ejecución. Si no se ha ejecutado en el tiempo
-- estimado devuelve nil.
local function clingo(args)
  if args == nil then
    args = {}
  end

  -- Recorre los parámetros y los convierte en constantes
  local constants = ""
  for name, value in pairs(args) do
    constants = constants .. "-c " .. name .. "=" .. tostring(value) .. " "
  end

  -- Crea un nuevo canal para intercomunicar procesos
  luaproc.newchannel("timer")

  -- Ejecuta clingo redirigiendo la salida
  local df = io.popen("cd src && clingo " .. constants .." main/asp/generator.lp & echo $!")
  -- Obtiene el pid, que es la primera linea que se imprime
  pid = df:read("*l")

  -- Se inicia el proceso temporizador que matará el proceso cuando supere los
  -- 5 minutos y se le pasa el pid del proceso creado
  assert(luaproc.newproc(timer))
  luaproc.send("timer", pid)

  -- Se queda esperando a que termine clingo
  local output = df:read("*a")
  df:close()

  -- Comprobamos que no se ha interumpido clingo para enviarle una señar al
  -- proceso temporizador
  local interrupted = luaproc.receive("timer", true)

  if not interrupted then
    luaproc.send("timer", true)
    luaproc.receive("timer")

    -- Se comprueba si es satisfactible y se obtiene el tiempo de ejecución
    local satisfiable = string.find(output, "SATISFIABLE")
    local result = string.match(output, "CPU Time     : (%d+%.%d+)s")
    return (satisfiable ~= nil), tonumber(result)
  end

  return nil
end

--- Función que registra una serie benchmarks en la lista de benchmarcks.
local function add(name, executions, args)
  -- Log
  io.write("Bench " .. tostring(num) .. ". " .. name)

  -- Medidas de tiempo y cantidad de ejecuciones
  local lastUpdate = 0
  local time = 0
  local success = 0
  local faileds = 0
  local timeouts = 0
  local continue = true
  local execution = 1
  local back = ""

  local startTime = os.time()
  while continue do
    local currentUpdate = os.time()

    -- Imprimimos el porcentaje si ha pasado un segundo (Así no saturamos la terminal)
    if lastUpdate < currentUpdate then
      local info = string.format("... %i%% (%i) ", execution/executions*100, execution)
      io.write(back .. info)
      back = ""
      for i = 1, #info do
        back = back .. "\b"
      end

      lastUpdate = currentUpdate
    end

    local result, exetime = clingo(args)

    -- Si ha saltado el timeout, deja de ejecutar la prueba
    if result == nil then
      timeouts = timeouts+1
    -- Si se ha ejecutado, se guardan los datos de la ejecución
    else
      if result then
        success = success+1
      else
        faileds = faileds+1
      end

      time = time + exetime
    end

    execution = execution + 1
    continue = timeouts == 0 and execution <= executions
  end
  local endTime = os.time()

  if timeouts == 0 then
    io.write(back .. ": ")
  end

  -- Si hay un timeout se imprimen los datos no finales
  if timeouts > 0 then
    if success == 0 then
      io.write("?/")
    else
      io.write(tostring(success) .. "*/")
    end

    if faileds == 0 then
      io.write("?/")
    else
      io.write(tostring(faileds) .. "*/")
    end

    io.write(tostring(timeouts) .. "* ")
  -- Si no hay timeout se imprime los datos reales
  else
    io.write(tostring(success) .. "/" .. tostring(faileds) .. "/" ..
              tostring(timeouts) .. " ")
  end

  -- Se imprime las ejecucciones totales y el tiempo total y tiempo medio
  io.write("(" .. tostring(execution-1) .. "), Total: " ..
      tostring(os.difftime(endTime, startTime)) .. "s Clingo: " ..
      tostring(time) .. "s\n")

  table.insert(info, {nume = num, name = name,
      success = success, faileds = faileds, timeouts = timeouts,
      total = os.difftime(endTime, startTime), cpu = time,
      executions = execution-1})
end

--- Imprime los resultados de los benchmarks en un fichero json.
-- @param path Ruta del fichero json.
local function results(path)
  local file = io.open(path, "w+")
  file:write(json.encode(info))
  file:flush()
  file:close()
end

--- Genera varios test de evalicación para ver lo que tarda la utilidad y guarda
-- los resultados en formato json.
-- @module Benchmarks
local Benchmarks = {
  callclingo = clingo,
  addbenchmark = add,
  writeresults = results
}

return Benchmarks
