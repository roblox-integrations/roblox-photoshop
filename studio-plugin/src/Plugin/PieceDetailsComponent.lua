--!strict
local Packages = script:FindFirstAncestor("PhotoshopIntegration").Packages

local HttpService = game:GetService("HttpService")

local React = require(Packages.React)

local e = React.createElement

local PieceDetailsComponent = React.Component:extend("PieceDetailsComponent")

local InstanceWirerComponent = require(script.Parent.InstanceWirerComponent)
local PluginEnum = require(script.Parent.Enum)


function PieceDetailsComponent:onClickSyncButton()
	local state = self.state
	local ok, response = pcall(function()
		-- call sync long running method and return
		return false
	end)
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
	print('PieceDetailsComponent component:init')

	self:setState(self.props)

end

function PieceDetailsComponent.getDerivedStateFromProps(props)
	return props
end




function PieceDetailsComponent:render()
	local state = self.state
	print('PieceDetailsComponent render')
	local instanceWirers = {}
	for i, selected in self.state.selection do 
		local newInstanceWirer = e(
			InstanceWirerComponent, 
			{
				instance = selected,
				index = i
			})
		instanceWirers[i] = newInstanceWirer
	end

	print('PieceDetailsComponent past wirers ' .. PluginEnum.FontSizeTextPrimary)

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 0, 120),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = self.props.index,
	}, {
		uiPadding = e("UIPadding", {
			PaddingLeft = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5),
			PaddingTop = UDim.new(0, 5),
			PaddingBottom = UDim.new(0, 5),
		}),
		
		uiListLayout = e("UIListLayout", {
			Padding = UDim.new(0, 10),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		texturePreview = e("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ImageTransparency = 0,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			LayoutOrder = 1,
			Image =  'http://www.roblox.com/asset/?id=699259085',
		}),
		syncDetails = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = 2,
		}, 
			{
				uiListLayout = e("UIListLayout", {
					Padding = UDim.new(0, 10),
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				name = e('TextLabel', {
					Size = UDim2.new(0, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.XY,
					Text = state.piece.filePath,
					Font = Enum.Font.BuilderSansMedium,
					TextSize = PluginEnum.FontSizeTextPrimary,
					TextColor3 = PluginEnum.ColorTextPrimary,
					BackgroundColor3 = PluginEnum.ColorBackground,
					BorderSizePixel = 0,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = 2
				}),
		})
		-- instanceWirers = e('Frame', {
		-- 	BackgroundTransparency = 1,
		-- 	Size = UDim2.new(0, 0, 1, 0),
		-- 	AutomaticSize = Enum.AutomaticSize.X,
		-- 	LayoutOrder = 3,
		-- }, {
		-- 		uiListLayout = e("UIListLayout", {
		-- 			Padding = UDim.new(0, 10),
		-- 			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		-- 			VerticalAlignment = Enum.VerticalAlignment.Center,
		-- 			SortOrder = Enum.SortOrder.LayoutOrder,
		-- 		}),
		-- 		Cryo.Dictionary.join({
		-- 			uiListLayout = e("UIListLayout", {
		-- 				Padding = UDim.new(0, 0),
		-- 				HorizontalAlignment = Enum.HorizontalAlignment.Left,
		-- 				SortOrder = Enum.SortOrder.LayoutOrder,
		-- 			}),
		-- 		}, instanceWirers)
				
		-- 	}
			
		-- )
	})
end


function PieceDetailsComponent:renderPropertyWires()
	return e('Frame', {				
		Size = UDim2.new(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = self.props.index, 
		BackgroundTransparency = 1
		},
		{
			Cryo.Dictionary.join({
				uiListLayout = e("UIListLayout", {
					Padding = UDim.new(0, PluginEnum.PaddingHorizontal),
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal, 
					VerticalAlignment =  Enum.VerticalAlignment.Center
				}),
			}, {
				uiPadding = e("UIPadding", {
					PaddingLeft = UDim.new(0, PluginEnum.PaddingHorizontal),
					PaddingRight = UDim.new(0, PluginEnum.PaddingHorizontal),
					PaddingTop = UDim.new(0, PluginEnum.PaddingVertical),
					PaddingBottom = UDim.new(0, PluginEnum.PaddingVertical),
					
				}),
		
				imagePreview = e('ImageLabel', {
					
					Size = UDim2.new(0, PluginEnum.PreviewSize, 0, PluginEnum.PreviewSize),
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundColor3 = PluginEnum.ColorBackground,
					BorderSizePixel = 0,
					Image='http://www.roblox.com/asset/?id=699259085',
					LayoutOrder = 1,
				}),
				name = e('TextLabel', {
					Size = UDim2.new(0, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.XY,
					Text = state.piece.filePath,
					Font = Enum.Font.BuilderSansMedium,
					TextSize = PluginEnum.FontSizeTextPrimary,
					TextColor3 = PluginEnum.ColorTextPrimary,
					BackgroundColor3 = PluginEnum.ColorBackground,
					BorderSizePixel = 0,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = 2
				}),
				openButton = e("TextButton", {
					Text = 'Open',
					AutomaticSize = Enum.AutomaticSize.XY,
					Size = UDim2.new(0, 0, 0, 0),
					TextColor3 = PluginEnum.ColorButtonNavigationText,
					BackgroundColor3 = PluginEnum.ColorButtonNavigationBackground,
					BorderSizePixel = 0,
					Font = Enum.Font.BuilderSansBold,
					TextSize = PluginEnum.FontSizeNavigationButton,
					LayoutOrder = 3,
					[React.Event.MouseButton1Click] = function()
						self.state.onClick()
					end,
				})
			})
		}
		)
end
return PieceDetailsComponent
