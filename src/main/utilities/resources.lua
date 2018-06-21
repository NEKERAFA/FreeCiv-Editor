-- Rafael Alcalde Azpiazu - 7 Jun 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local Lfs = require "lfs"
local Json = require "libs.json.json"

local function _append (...)
  local args = {...}
  local nargs = #args
  local path = ""

  for i, folder in ipairs(args) do
    path = path .. folder

    if i < nargs then
      if love.system.getOS() == "Windows" then
        path = path .. "\\"
      else
        path = path .. "/"
      end
    end
  end

  return path
end

local imagePath = "resources"
local configPath = love.filesystem.getSaveDirectory()
local scenarioPath = _append("resources", "scenario.txt")

-- List for save the loaded resources
local loaded = {}
-- List for save the added loaders
local loaders = {}

--- This module controls all the resources.
-- @module Resources
local Resources = {
  --- Adds a loader for a specific resource.
  -- @param resource Type of the resource.
  -- @param method A function that receives a name resource and returns a resource object.
  addLoader = function(resource, method)
    loaders[resource] = method
  end,

  --- Calls a loader and return a resource.
  -- @param resource Type of the resource.
  -- @param name The name of the new resource.
  -- @return Returns a reference to the resource.
  loadResource = function(resource, name)
    assert(loaders[resource], "not loader added for " .. resource .. " resources")

    local key = resource .. ":" .. name

    if not loaded[key] then
      loaded[key] = loaders[resource](name)
    end

    return loaded[key]
  end,

  --- Remove a loaded resource.
  -- @param resource Type of the resource.
  -- @param name The name of the new resource.
  removeResource = function(resource, name)
    local key = resource .. ":" .. name

    assert(loaded[key], key .. " resource is not loaded")

    if loaded[key].release then
      loaded[key]:release()
    end

    loaded[key] = false
  end,

  --- Saves a configuration.
  -- @param name The name of the configuration.
  -- @param conf The table with the values to save.
  saveConfiguration = function(name, conf)
    local fullPath = _append(configPath, name .. ".json")
    local df = io.open(fullPath, "w+")
    df:write(Json.encode(conf))
    df:flush()
    df:close()
  end,

  --- Checks if a configuration exists
  -- @param name The name of the configuration.
  -- @return True if configuration exists, false otherwise.
  existConfiguration = function(name)
    local fullPath = _append(configPath, name .. ".json")
    return lfs.attributes(fullPath) ~= nil
  end
}

-- Adds a configuration loader
Resources.addLoader("conf", function(name)
  local fullPath = _append(configPath, name .. ".json")
  local df = io.open(fullPath, "r+")
  local content = df:read("a")
  df:close()
  return Json.decode(content)
end)

-- Add a image loader
Resources.addLoader("image", function(name)
  local fullPath = _append(imagePath, name .. ".png")
  return love.graphics.newImage(fullPath)
end)

-- Add a scenario loader
Resources.addLoader("scenario", function()
  local content = love.filesystem.read(scenarioPath)
  return content
end)

-- Add a map loader
Resources.addLoader("map", function(fullPath)
  local df = io.open(fullPath, 'r')
  local content = df:read("a")
  return Json.decode(content)
end)

return Resources
