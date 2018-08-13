-- Rafael Alcalde Azpiazu - 7 Jun 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

--- This module controls all the resources.
-- @module Resources

local Lfs = require "lfs"
local Json = require "libs.json.json"

-- List for save the loaded resources
local loaded = {}
-- List for save the added loaders
local loaders = {}

local function appendFiles (...)
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

--- Adds a loader for a specific resource.
-- @param resource Type of the resource.
-- @param method A function that receives a name resource and returns a resource object.
local function addLoader (resource, method)
  loaders[resource] = method
end

--- Calls a loader and return a resource.
-- @param resource Type of the resource.
-- @param name The name of the new resource.
-- @return Returns a reference to the resource.
local function loadResource (resource, name)
  assert(loaders[resource], "not loader added for " .. resource .. " resources")

  local key = resource .. ":" .. name

  if not loaded[key] then
    loaded[key] = loaders[resource](name)
  end

  return loaded[key]
end

--- Remove a loaded resource.
-- @param resource Type of the resource.
-- @param name The name of the new resource.
local function removeResource (resource, name)
  local key = resource .. ":" .. name

  assert(loaded[key], key .. " resource is not loaded")

  if loaded[key].release then
    loaded[key]:release()
  end

  loaded[key] = false
end

local imagePath = "resources"
local configPath = love.filesystem.getSaveDirectory()
local scenarioPath = appendFiles("resources", "scenario.txt")

--- Saves a configuration.
-- @param name The name of the configuration.
-- @param conf The table with the values to save.
local function saveConfiguration (name, conf)
  local fullPath = appendFiles(configPath, name .. ".json")
  local file = love.filesystem.newFile(fullPath, "w")
  local df = io.open(fullPath, "w+")
  df:write(Json.encode(conf))
  df:flush()
  df:close()

  local key = "conf:" .. name
  if loaded[key] then loaded[key] = false end
end

--- Checks if a configuration exists
-- @param name The name of the configuration.
-- @return True if configuration exists, false otherwise.
local function existConfiguration (name)
  local fullPath = appendFiles(configPath, name .. ".json")
  return lfs.attributes(fullPath) ~= nil
end

-- Adds a configuration loader
addLoader("conf", function(name)
  local fullPath = appendFiles(configPath, name .. ".json")
  local df = io.open(fullPath, "r+")
  local content = df:read("a")
  df:close()
  return Json.decode(content)
end)

-- Add a image loader
addLoader("image", function(name)
  local fullPath = appendFiles(imagePath, name .. ".png")
  return love.graphics.newImage(fullPath)
end)

-- Add a scenario loader
addLoader("scenario", function()
  local content = love.filesystem.read(scenarioPath)
  return content
end)

-- Add a json loader
addLoader("json", function(fullPath)
  local df = io.open(fullPath, 'r')
  local content = df:read("a")
  return Json.decode(content)
end)

local Resources = {
  appendFiles = appendFiles,
  addLoader = addLoader,
  loadResource = loadResource,
  removeResource = removeResource,
  saveConfiguration = saveConfiguration,
  existConfiguration = existConfiguration
}

return Resources
