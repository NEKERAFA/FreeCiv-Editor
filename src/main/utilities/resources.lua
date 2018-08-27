-- Rafael Alcalde Azpiazu - 7 Jun 2018
-- Facultade de Informática da Coruña - Universidade da Coruña

local Lfs = require "lfs"
local Json = require "libs.json.json"

-- List for save the _loaded resources
local _loaded = {}
-- List for save the added _loaders
local _loaders = {}

--- This module controls all the resources.
-- @module Resources
local Resources = {}

--- Gets some strings that it represents folder names and converts into a valid path.
-- @param ... A list of folder names.
-- @return A valid path.
function Resources.appendFolders (...)
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

--------------------------------------------------------------------------------

-- Path that contains the images
local imagePath = "resources"
-- Path that contains the configuration files
local configPath = love.filesystem.getSaveDirectory()
-- Path that contains the file with the scenario template
local scenarioPath = Resources.appendFolders("resources", "scenario.txt")

--------------------------------------------------------------------------------

--- Adds a loader for a specific resource.
-- @param resource Type of the resource.
-- @param method A function that receives a name resource and returns a resource object.
function Resources.addLoader (resource, method)
  _loaders[resource] = method
end

--- Calls a loader and return a resource.
-- @param resource Type of the resource.
-- @param name The name of the new resource.
-- @return Returns a reference to the resource.
function Resources.loadResource (resource, name)
  assert(_loaders[resource], "not loader added for " .. resource .. " resources")

  local key = resource .. ":" .. name

  if not _loaded[key] then
    _loaded[key] = _loaders[resource](name)
  end

  return _loaded[key]
end

--- Remove a _loaded resource.
-- @param resource Type of the resource.
-- @param name The name of the new resource.
function Resources.removeResource (resource, name)
  local key = resource .. ":" .. name

  assert(_loaded[key], key .. " resource is not _loaded")

  if _loaded[key].release then
    _loaded[key]:release()
  end

  _loaded[key] = false
end

--- Saves a configuration.
-- @param name The name of the configuration.
-- @param conf The table with the values to save.
function Resources.saveConfiguration (name, conf)
  local fullPath = Resources.appendFolders(configPath, name .. ".json")
  local df = io.open(fullPath, "w+")
  df:write(Json.encode(conf))
  df:flush()
  df:close()

  local key = "conf:" .. name
  if _loaded[key] then _loaded[key] = false end
end

--- Checks if a configuration exists
-- @param name The name of the configuration.
-- @return True if configuration exists, false otherwise.
function Resources.existConfiguration (name)
  local fullPath = Resources.appendFolders(configPath, name .. ".json")
  return lfs.attributes(fullPath) ~= nil
end

--------------------------------------------------------------------------------

-- Adds a configuration loader
Resources.addLoader("conf", function(name)
  local fullPath = Resources.appendFolders(configPath, name .. ".json")
  local df = io.open(fullPath, "r+")
  local content = df:read("a")
  df:close()
  return Json.decode(content)
end)

-- Add a image loader
Resources.addLoader("image", function(name)
  local fullPath = Resources.appendFolders(imagePath, name .. ".png")
  return love.graphics.newImage(fullPath)
end)

-- Add a scenario loader
Resources.addLoader("scenario", function()
  local content = love.filesystem.read(scenarioPath)
  return content
end)

-- Add a json loader
Resources.addLoader("json", function(fullPath)
  local df = io.open(fullPath, 'r')
  local content = df:read("a")
  return Json.decode(content)
end)

return Resources
