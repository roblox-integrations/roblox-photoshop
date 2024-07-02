--!strict

local PhotoshopIntegration = script:FindFirstAncestor("PhotoshopIntegration")
local Packages = PhotoshopIntegration.Packages

local ReactRoblox = require(Packages.ReactRoblox)
local React = require(Packages.React)
local Cryo = require(Packages.Cryo)

local StudioPluginContext = require(script.Parent.StudioPluginContext)

local e = React.createElement

local function StudioPluginGui(props: {
	plugin: Plugin,
	initDockState: Enum.InitialDockState,
	active: boolean,
	overridePreviousState: boolean,
	floatingSize: Vector2,
	minimumSize: Vector2,
	id: string,
	title: string,
	zIndexBehavior: Enum.ZIndexBehavior,
	setEnabled: (boolean) -> (),
	[any]: { __RESTRICTED__: boolean },
})
	local pluginGui: DockWidgetPluginGui?, setPluginGui = React.useState(nil :: DockWidgetPluginGui?)

	React.useEffect(function()
		local floatingSize = props.floatingSize
		local minimumSize = props.minimumSize

		local dockWidgetPluginGuiInfo = DockWidgetPluginGuiInfo.new(
			props.initDockState,
			props.active,
			props.overridePreviousState,
			floatingSize.X,
			floatingSize.Y,
			minimumSize.X,
			minimumSize.Y
		)

		local pluginGui = props.plugin:CreateDockWidgetPluginGui(props.id, dockWidgetPluginGuiInfo)

		pluginGui.Name = props.id
		pluginGui.Title = props.title
		pluginGui.ZIndexBehavior = props.zIndexBehavior

		if not props.overridePreviousState then
			props.setEnabled(pluginGui.Enabled)
		end

		pluginGui:BindToClose(function()
			props.setEnabled(false)
		end)

		setPluginGui(pluginGui)

		return function()
			pluginGui:Destroy()
		end
	end, {})

	React.useEffect(function()
		if pluginGui then
			pluginGui.Enabled = props.active
		end
	end, { props.active })

	if not pluginGui then
		return nil
	end

	return ReactRoblox.createPortal({
		Container = e("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			Transparency = 1,
		}, props.children),
	}, pluginGui)
end

local function StudioPluginGuiWrapper(props: {
	initDockState: Enum.InitialDockState,
	active: boolean,
	overridePreviousState: boolean,
	floatingSize: Vector2,
	minimumSize: Vector2,
	id: string,
	title: string,
	zIndexBehavior: Enum.ZIndexBehavior,
	setEnabled: (boolean) -> (),
	[any]: { __RESTRICTED__: boolean },
})
	return e(StudioPluginContext.Consumer, {
		render = function(plugin)
			return e(
				StudioPluginGui,
				Cryo.Dictionary.join(props, {
					plugin = plugin,
				})
			)
		end,
	})
end

return StudioPluginGuiWrapper
