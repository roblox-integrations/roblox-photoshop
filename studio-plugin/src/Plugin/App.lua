local PhotoshopIntegration = script:FindFirstAncestor("PhotoshopIntegration")
local Packages = PhotoshopIntegration.Packages

local React = require(Packages.React)

local e = React.createElement

local App = React.Component:extend("App")

local StudioSharedToolbar = require(script.Parent.Studio.StudioSharedToolbar)
local StudioPluginContext = require(script.Parent.Studio.StudioPluginContext)
local StudioPluginGui = require(script.Parent.Studio.StudioPluginGui)
local Widget = require(script.Parent.Widget)
local VersionWarning = require(script.Parent.VersionWarning)

function App:init()
	self:setState({
		guiEnabled = false,
	})
	VersionWarning:runVersionChecking()
end

function App:render()
	local pluginName = "Ronron Asset Sync"

	return e(StudioPluginContext.Provider, {
		value = self.props.plugin,
	}, {
		gui = e(StudioPluginGui, {
			id = pluginName,
			title = pluginName,
			active = self.state.guiEnabled,

			initDockState = Enum.InitialDockState.Left,
			overridePreviousState = false,
			floatingSize = Vector2.new(250, 200),
			minimumSize = Vector2.new(250, 200),

			zIndexBehavior = Enum.ZIndexBehavior.Sibling,

			onInitialState = function(initialState)
				self:setState({
					guiEnabled = initialState,
				})
			end,

			onClose = function()
				self:setState({
					guiEnabled = false,
				})
			end,
		}, {
			widget = e(Widget),
		}),
		sharedToolbarButton = e(StudioSharedToolbar, {
			combinerName = "Roblox-Integration-Toolbar",
			toolbarName = "Ronron",
			buttonName = "Assets Sync",
			buttonIcon = "rbxassetid://103039951720673",
			buttonTooltip = "Toggle the Asset Sync widget",
			buttonEnabled = true,
			buttonActive = self.state.guiEnabled,
			onClick = function()
				self:setState(function(state)
					return {
						guiEnabled = not state.guiEnabled,
					}
				end)
			end,
		}),
	})
end

return App
