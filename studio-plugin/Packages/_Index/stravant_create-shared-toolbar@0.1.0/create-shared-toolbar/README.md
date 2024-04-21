# Roblox createSharedToolbar function
This is a function for creating a Toolbar shared between multiple plugins.

It will correctly handle a variety of edge cases such as one of the plugins sharing the toolbar being reloaded or unloaded entirely.

This code has been battle-tested in the widely used GeomTools set of plugins.

Use the `createSharedToolbar.SharedToolbarSettings` type to get code completion for the required fields in the initialization table passed to the function.

# Usage
```lua
local createSharedToolbar = require(script.Parent.createSharedToolbar)

local toolbarSettings = {} :: createSharedToolbar.SharedToolbarSettings
toolbarSettings.CombinerName = "<arbitrary name here>"
toolbarSettings.ToolbarName = "Your Toolbar Name"
toolbarSettings.ButtonName = "Your Button Name"
toolbarSettings.ButtonIcon = "rbxassetid://123456789"
toolbarSettings.ButtonTooltip = "Click here to do some fancy stuff!"
toolbarSettings.ClickedFn = function()
	-- Button handler code here. A "Button" field is added to the
	-- toolbarSettings table when createSharedToolbar is called which is
	-- used to access the button Instance so you can call SetActive on it.
	--
	-- (Note: DO NOT connect to Click on the button via this reference, use this
	-- ClickedFn callback instead, as the Button reference may change if the
	-- plugin owning the Toolbar gets reloaded or unloaded)
	sharedToolbarSettings.Button:SetActive(...)
end
createSharedToolbar(plugin, sharedToolbarSettings)
```

