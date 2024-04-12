local PhotoshopSync = script:FindFirstAncestor("PhotoshopSync")
local Packages = PhotoshopSync.Packages

local React = require(Packages.React)
local Cryo = require(Packages.Cryo)

local StudioToolbarContext = require(script.Parent.StudioToolbarContext)

local e = React.createElement

local StudioToggleButton = React.Component:extend("StudioToggleButton")

StudioToggleButton.defaultProps = {
	enabled = true,
	active = false,
}

function StudioToggleButton:init()
	local button =
		self.props.toolbar:CreateButton(self.props.name, self.props.tooltip, self.props.icon, self.props.text)

	button.Click:Connect(function()
		if self.props.onClick then
			self.props.onClick()
		end
	end)

	button.ClickableWhenViewportHidden = true

	self.button = button
end

function StudioToggleButton:render()
	return nil
end

function StudioToggleButton:didUpdate(lastProps)
	if self.props.enabled ~= lastProps.enabled then
		self.button.Enabled = self.props.enabled
	end

	if self.props.icon ~= lastProps.icon then
		self.button.Icon = self.props.icon
	end

	if self.props.active ~= lastProps.active then
		self.button:SetActive(self.props.active)
	end
end

function StudioToggleButton:willUnmount()
	self.button:Destroy()
end

local function StudioToggleButtonWrapper(props)
	return e(StudioToolbarContext.Consumer, {
		render = function(toolbar)
			return e(
				StudioToggleButton,
				Cryo.Dictionary.join(props, {
					toolbar = toolbar,
				})
			)
		end,
	})
end

return StudioToggleButtonWrapper