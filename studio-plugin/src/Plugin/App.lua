local PhotoshopIntegration = script:FindFirstAncestor("PhotoshopIntegration")
local Packages = PhotoshopIntegration.Packages

local React = require(Packages.React)

local e = React.createElement

local App = React.Component:extend("App")

local StudioSharedToolbar = require(script.Parent.Studio.StudioSharedToolbar)
local StudioPluginContext = require(script.Parent.Studio.StudioPluginContext)
local StudioPluginGui = require(script.Parent.Studio.StudioPluginGui)
local Widget = require(script.Parent.Widget)

function App:init()
	self:setState({
		guiEnabled = false,
	})
end

function App:render()
	local pluginName = "Photoshop Integration"

	return e(StudioPluginContext.Provider, {
		value = self.props.plugin,
	}, {
		gui = e(StudioPluginGui, {
			id = pluginName,
			title = pluginName,
			active = self.state.guiEnabled,

			initDockState = Enum.InitialDockState.Left,
			overridePreviousState = false,
			floatingSize = Vector2.new(260, 200),
			minimumSize = Vector2.new(260, 200),

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
			toolbarName = "Integrations",
			buttonName = "Photoshop",
			buttonIcon = "rbxassetid://16371612297",
			buttonTooltip = "Toggle the Photoshop Integration widget",
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
