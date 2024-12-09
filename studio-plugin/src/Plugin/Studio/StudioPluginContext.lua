local Freeway = script:FindFirstAncestor("Freeway")
local Packages = Freeway.Packages

local React = require(Packages.React)

local StudioPluginContext = React.createContext(nil)

return StudioPluginContext
