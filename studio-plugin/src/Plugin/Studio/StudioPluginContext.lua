local PhotoshopIntegration = script:FindFirstAncestor("PhotoshopIntegration")
local Packages = PhotoshopIntegration.Packages

local React = require(Packages.React)

local StudioPluginContext = React.createContext(nil)

return StudioPluginContext
