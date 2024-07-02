--!strict

local PhotoshopIntegration = script:FindFirstAncestor("PhotoshopIntegration")
local Packages = PhotoshopIntegration.Packages

local React = require(Packages.React)

local StudioSharedToolbar = require(script.Parent.Studio.StudioSharedToolbar)
local StudioPluginContext = require(script.Parent.Studio.StudioPluginContext)
local StudioPluginGui = require(script.Parent.Studio.StudioPluginGui)
local Widget = require(script.Parent.Widget)
local VersionWarning = require(script.Parent.VersionWarning)

local e = React.createElement

local function App(props: {
	plugin: Plugin,
	[any]: { __RESTRICTED__: boolean },
})
	local pluginName = "Photoshop Integration"

	local guiEnabled, setGuiEnabled = React.useState(false)

	React.useEffect(function()
		VersionWarning:runVersionChecking()
	end, {})

	return e(StudioPluginContext.Provider, {
		value = props.plugin,
	}, {
		gui = e(StudioPluginGui, {
			id = pluginName,
			title = pluginName,
			active = guiEnabled,

			initDockState = Enum.InitialDockState.Left,
			overridePreviousState = false,
			floatingSize = Vector2.new(250, 200),
			minimumSize = Vector2.new(250, 200),

			zIndexBehavior = Enum.ZIndexBehavior.Sibling,

			setEnabled = React.useCallback(function(enabled)
				setGuiEnabled(enabled)
			end, {}),
		}, {
			Widget = e(Widget),
		}),
		sharedToolbarButton = e(StudioSharedToolbar, {
			combinerName = "Roblox-Integration-Toolbar",
			toolbarName = "Integrations",
			buttonName = "Photoshop",
			buttonIcon = "rbxassetid://16371612297",
			buttonTooltip = "Toggle the Photoshop Integration widget",
			buttonEnabled = true,
			buttonActive = guiEnabled,
			onClick = React.useCallback(function()
				setGuiEnabled(function(currentEnabled)
					return not currentEnabled
				end)
			end, {}),
		}),
	})
end

return App
