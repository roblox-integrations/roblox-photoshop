--!strict

local PhotoshopIntegration = script:FindFirstAncestor("PhotoshopIntegration")
local Packages = PhotoshopIntegration.Packages

local React = require(Packages.React)
local Cryo = require(Packages.Cryo)
local CreateSharedToolbar = require(Packages.CreateSharedToolbar)

local StudioPluginContext = require(script.Parent.StudioPluginContext)

local e = React.createElement

type ToolbarSettings = CreateSharedToolbar.SharedToolbarSettings

local function StudioSharedToolbar(props: {
	plugin: Plugin,
	combinerName: string,
	toolbarName: string,
	buttonName: string,
	buttonIcon: string,
	buttonTooltip: string,
	onClick: () -> (),
	buttonEnabled: boolean,
	buttonActive: boolean,
	[any]: { __RESTRICTED__: boolean },
})
	local toolbarSettings: ToolbarSettings, setToolbarSettings = React.useState({} :: ToolbarSettings)

	React.useEffect(function()
		local toolbarSettings = {} :: ToolbarSettings
		toolbarSettings.CombinerName = props.combinerName
		toolbarSettings.ToolbarName = props.toolbarName
		toolbarSettings.ButtonName = props.buttonName
		toolbarSettings.ButtonIcon = props.buttonIcon
		toolbarSettings.ButtonTooltip = props.buttonTooltip
		toolbarSettings.ClickedFn = props.onClick
		CreateSharedToolbar(props.plugin, toolbarSettings)
		assert(toolbarSettings.Button, "Button not created")
		toolbarSettings.Button.ClickableWhenViewportHidden = true
		setToolbarSettings(toolbarSettings)
	end, {})

	React.useEffect(
		function()
			if toolbarSettings.Button then
				toolbarSettings.Button.Name = props.buttonName
				toolbarSettings.Button.Icon = props.buttonIcon
				toolbarSettings.Button.Enabled = props.buttonEnabled
				toolbarSettings.Button:SetActive(props.buttonActive)
			end
		end,
		{ toolbarSettings.Button, props.buttonName, props.buttonIcon, props.buttonEnabled, props.buttonActive } :: { any }
	)

	return nil
end

local function StudioSharedToolbarWrapper(props)
	return e(StudioPluginContext.Consumer, {
		render = function(plugin)
			return e(
				StudioSharedToolbar,
				Cryo.Dictionary.join(props, {
					plugin = plugin,
				})
			)
		end,
	})
end

return StudioSharedToolbarWrapper
