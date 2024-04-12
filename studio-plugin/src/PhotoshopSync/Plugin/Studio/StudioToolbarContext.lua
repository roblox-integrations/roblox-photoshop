local PhotoshopSync = script:FindFirstAncestor("PhotoshopSync")
local Packages = PhotoshopSync.Packages

local React = require(Packages.React)

local StudioToolbarContext = React.createContext(nil)

return StudioToolbarContext