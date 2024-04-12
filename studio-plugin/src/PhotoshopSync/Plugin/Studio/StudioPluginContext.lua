local PhotoshopSync = script:FindFirstAncestor("PhotoshopSync")
local Packages = PhotoshopSync.Packages

local React = require(Packages.React)

local StudioPluginContext = React.createContext(nil)

return StudioPluginContext