local PhotoshopSync = script:FindFirstAncestor("PhotoshopSync")
local Packages = PhotoshopSync.Packages

local React = require(Packages.React)
local Cryo = require(Packages.Cryo)

local StudioToolbarContext = require(script.Parent.StudioToolbarContext)
local StudioPluginContext = require(script.Parent.StudioPluginContext)

local e = React.createElement

local StudioToolbar = React.Component:extend("StudioToolbar")

function StudioToolbar:init()
	self.toolbar = self.props.plugin:CreateToolbar(self.props.name)
end

function StudioToolbar:render()
	return e(StudioToolbarContext.Provider, {
		value = self.toolbar,
	}, self.props.children)
end

function StudioToolbar:didUpdate(lastProps)
	if self.props.name ~= lastProps.name then
		self.toolbar.Name = self.props.name
	end
end

function StudioToolbar:willUnmount()
	self.toolbar:Destroy()
end

local function StudioToolbarWrapper(props)
	return e(StudioPluginContext.Consumer, {
		render = function(plugin)
			return e(
				StudioToolbar,
				Cryo.Dictionary.join(props, {
					plugin = plugin,
				})
			)
		end,
	})
end

return StudioToolbarWrapper