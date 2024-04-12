local PhotoshopSync = script:FindFirstAncestor("PhotoshopSync")
local Packages = PhotoshopSync.Packages

local React = require(Packages.React)

local e = React.createElement

local App = React.Component:extend("App")

local StudioToolbar = require(script.Parent.Studio.StudioToolbar)
local StudioToggleButton = require(script.Parent.Studio.StudioToggleButton)
local StudioPluginContext = require(script.Parent.Studio.StudioPluginContext)
local StudioPluginGui = require(script.Parent.Studio.StudioPluginGui)
local Widget = require(script.Parent.Widget)

function App:init()
    self:setState({
		guiEnabled = false,
		toolbarIcon = "rbxassetid://16371612297",
	})
end

function App:render()
    local pluginName = "Photoshop Sync"

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
        toolbar = e(StudioToolbar, {
            name = pluginName,
        }, {
            button = e(StudioToggleButton, {
                name = "Sync",
                tooltip = "Toggle the Photoshop Sync widget",
                icon = self.state.toolbarIcon,
                active = self.state.guiEnabled,
                enabled = true,
                onClick = function()
                    self:setState(function(state)
                        return {
                            guiEnabled = not state.guiEnabled,
                        }
                    end)
                end,
            }),
        })
    })
end

return App
