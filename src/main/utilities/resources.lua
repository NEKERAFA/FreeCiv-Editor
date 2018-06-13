-- Rafael Alcalde Azpiazu - 7 Jun 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local Json = require "libs.json.json"

local imagePath = "resources"
local configPath = love.filesystem.getSaveDirectory()
local scenarioPath = "resources/scenario.txt"

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

  --- Loads a configuration.
  -- @param name The name of the configuration.
  -- @return A table with the values saved.
  loadConfiguration = function(name)
    local fullPath = configPath .. "/" .. name .. ".json"
    local content = love.filesystem.read(fullPath)
    return Json.decode(content)
  end,

  --- Saves a configuration.
  -- @param name The name of the configuration.
  -- @param conf The table with the values to save.
  saveConfiguration = function(name, conf)
    local fullPath = configPath .. "/" .. name .. ".json"
    local content = Json.encode(conf)
    love.filesystem.write(fullPath, content)
  end,

  --- Checks if a configuration exists
  -- @param name The name of the configuration.
  -- @return True if configuration exists, false otherwise.
  existConfiguration = function(name)
    local fullPath = configPath .. "/" .. name .. ".json"
    return love.filesystem.getInfo(fullPath) ~= nil
  end
}

-- Add a image loader
Resources.addLoader("image", function(name)
  local fullPath = imagePath .. "/" .. name .. ".png"
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
