--!strict
local Packages = script:FindFirstAncestor("PhotoshopIntegration").Packages

local HttpService = game:GetService("HttpService")

local React = require(Packages.React)

local e = React.createElement

local PieceDetailsComponent = React.Component:extend("PieceDetailsComponent")

local InstanceWirerComponent = require(script.Parent.InstanceWirerComponent)


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

	local theme = settings().Studio.Theme
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

	print('PieceDetailsComponent past wirers')
	
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
			Image =  "",
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
				sourceText = e("TextLabel", {
					Size = UDim2.new(0, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.XY,
					LayoutOrder = 2,
					Text = state.piece.filePath,
					Font = Enum.Font.BuilderSansMedium,
					TextSize = 20,
					TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogButtonText),
					BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Light),
					BorderSizePixel = 0,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, {
					e("UIPadding", {
						PaddingLeft = UDim.new(0, 5),
						PaddingRight = UDim.new(0, 5),
						PaddingTop = UDim.new(0, 5),
						PaddingBottom = UDim.new(0, 5),
					}),
				}),
		}),
		instanceWirers = e('Frame', {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = 3,
		}, {
				uiListLayout = e("UIListLayout", {
					Padding = UDim.new(0, 10),
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Cryo.Dictionary.join({
					uiListLayout = e("UIListLayout", {
						Padding = UDim.new(0, 0),
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
				}, instanceWirers)
				
			}
			
		)
	})
end

return PieceDetailsComponent
