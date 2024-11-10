--!strict
local Packages = script:FindFirstAncestor("PhotoshopIntegration").Packages
local React = require(Packages.React)
local Cryo = require(Packages.Cryo)

local e = React.createElement
local Selection = game:GetService("Selection")

local PieceDetailsComponent = React.Component:extend("PieceDetailsComponent")

local InstanceWirerComponent = require(script.Parent.InstanceWirerComponent)
local PluginEnum = require(script.Parent.Enum)
local t_u = require(script.Parent.tags_util)


function PieceDetailsComponent:onClickSyncButton()
	-- local state = self.state
	-- local ok, response = pcall(function()
	-- 	-- call sync long running method and return
	-- 	return false
	-- end)
	-- if not ok or not response.Success then
	-- 	if typeof(response) == "table" then
	-- 		warn("Request failed:", response.StatusCode, response.StatusMessage)
	-- 	else
	-- 		warn("Request failed:", response)
	-- 	end
	-- 	return
	-- end
end


function PieceDetailsComponent:didMount()
	 -- add listener for tags changes
		-- if self.state.source and self.state.propertyName then
		-- 	self.state.source:GetPropertyChangedSignal(self.state.propertyName):Connect(function()
		-- 		self.state.shownImage = self.state.source[self.state.propertyName]
		-- 		self.props.onSessionDataChanged(self)
		-- 	end)
		-- end
end

function PieceDetailsComponent:willUnmount()
	--self:onClickDisconnectButton()
end

function PieceDetailsComponent:init()
	local selection = Selection:Get()
	self:setState({selection = selection})
		self.onSelectionChanged = Selection.SelectionChanged:Connect(function()
			local selection = Selection:Get()
			self:setState({selection = selection})
		end)
end

function PieceDetailsComponent.getDerivedStateFromProps(props)
	return props
end



function PieceDetailsComponent:render()
	local state = self.state
	local instanceWirers = {}

	-- todo MI: add instance grouping by classname
	for i, selectedInstance in state.selection do 
		print('redo wirers')
		local newInstanceWirer = e(
			InstanceWirerComponent, 
			{
				index = i,
				instances = state.selection, 
				onClick = function(instance, propertyName)
					local wire = {}
					wire[self.props.piece.id] = propertyName
					print('onClick')
					print(instance)
					print({wire})
					t_u:set_instance_wires(instance, wire)
				end

			})
		instanceWirers['instanceWirer' .. i] = newInstanceWirer
	end
	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = self.props.index, 
	}, {
		Cryo.Dictionary.join({
			uiListLayout = e("UIListLayout", {
				Padding = UDim.new(0, 0),
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		}, self:renderPreviewAndName(1), instanceWirers)
	})
end


function PieceDetailsComponent:renderPreviewAndName(order: number)
	print('render piece details component')

	local content = self.props.fetcher:fetch(self.props.piece)
	return {
		e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			LayoutOrder = self.props.index, 
		}, {
		uiListLayoutTop = e("UIListLayout", {
			Padding = UDim.new(0, PluginEnum.PaddingHorizontal),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		texturePreviewTop = content ~= nil and e("ImageLabel", {
			Size = UDim2.new(0, PluginEnum.PreviewSize, 0, PluginEnum.PreviewSize),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = PluginEnum.ColorBackground,
			BorderSizePixel = 0,
			ImageContent = content,
		}),
		-- texturePreviewTop = self.state.editableImage ~= nil and e("ImageLabel", {
		-- 	Size = UDim2.new(0, PluginEnum.PreviewSize, 0, PluginEnum.PreviewSize),
		-- 	AutomaticSize = Enum.AutomaticSize.XY,
		-- 	BackgroundColor3 = PluginEnum.ColorBackground,
		-- 	BorderSizePixel = 0,
		-- 	Image =  'http://www.roblox.com/asset/?id=699259085',
		-- }),

		nameTop = e('TextLabel', {
			Size = UDim2.new(0, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			Text = self.props.piece.filePath,
			Font = Enum.Font.BuilderSansBold,
			TextSize = PluginEnum.FontSizeTextPrimary,
			TextColor3 = PluginEnum.ColorTextPrimary,
			BackgroundColor3 = PluginEnum.ColorBackground,
			BorderSizePixel = 0,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 1
		})
	})
}
end
return PieceDetailsComponent
