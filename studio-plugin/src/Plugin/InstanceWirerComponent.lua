--!strict
local PhotoshopIntegration = script:FindFirstAncestor("PhotoshopIntegration")
local Packages = PhotoshopIntegration.Packages

local Cryo = require(Packages.Cryo)

local React = require(Packages.React)

local e = React.createElement

local TextureProperties = require(script.Parent.TextureProperties)

local InstanceWirerComponent = React.Component:extend("InstanceWirerComponent")
local PluginEnum = require(script.Parent.Enum)


type StateData = {
	source: Instance?,
	propertyName: string,
	imageType: string,
	shownImage: string,
	productInfo: { Name: string, Creator: { Name: string } },
	hasPolling: boolean,
	isPolling: boolean,
	sessionData: SessionData,
}

type SessionData = {
	sessionId: string,
	lastUpdated: string,
	asset: string?,
	outAsset: string?,
}

-- -- functional components definition
-- local function newInstanceWirerComponent(props)
	
-- 	local state = self:setState(props)

--     local text = React.createElement("TextButton", {
--         Text = string.format("Clicked %d times", count)
--         -- Clicking the button updates the count, which re-renders the component
--         [React.Event.Activated] = function()
--             setCount(count + 1)
--         end
--     })
-- 	-- text:setTe
-- end

-- local function Component()
-- 	local selection, setSelection = React.useState(Selection:Get())

-- 	React.useEffect(function()
-- 		local onSelectionChanged = Selection.SelectionChanged:Connect(function()
-- 			print('selection changed')
-- 			setSelection(Selection:Get())
-- 		end)

-- 		print("mounted")

-- 		return function()
-- 			onSelectionChanged:Disconnect()
-- 			print("unmounted")
-- 		end
-- 	end, {}) -- {} means no dependencies
-- end

-- local function Text(props: {
-- 	text: string
-- })
-- 	return React.createElement("TextLabel", {
-- 		Text = props.text,
-- 	})
-- end

-- local function Button(props: {
-- 	onClick: () -> (),
-- })
-- 	return React.createElement("TextButton", {
-- 		[React.Event.Activated] = props.onClick,
-- 	})
-- end



function InstanceWirerComponent:onClickSyncButton()

end

function InstanceWirerComponent:didMount()
	 -- TODO MI add listener for tags changes
		-- if self.state.source and self.state.propertyName then
		-- 	self.state.source:GetPropertyChangedSignal(self.state.propertyName):Connect(function()
		-- 		self.state.shownImage = self.state.source[self.state.propertyName]
		-- 		self.props.onSessionDataChanged(self)
		-- 	end)
		-- end
end

function InstanceWirerComponent:willUnmount()
	--self:onClickDisconnectButton()
end



function InstanceWirerComponent:init()
end

function InstanceWirerComponent.getDerivedStateFromProps(props)
	return props
end

function InstanceWirerComponent:render()
	
	local properties =  {}
	for i, _ in self.props.properties do
		local p = self:renderPropertyWires(i)
		properties[i] = p;
	end
	local header =  e("TextLabel", {
		Size = UDim2.new(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		Text = self.props.header,
		Font = Enum.Font.BuilderSansBold,
		TextSize = PluginEnum.FontSizeHeader,
		TextColor3 = PluginEnum.ColorTextPrimary,
		BackgroundColor3 = PluginEnum.ColorBackground,
		BorderSizePixel = 0,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 1
	})
	
	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = self.props.index,
	}, {
		Cryo.Dictionary.join({
				uiListLayout = e("UIListLayout", {
					Padding = UDim.new(0, PluginEnum.PaddingVertical),
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			}, {header = header}, properties) 
	})
end

function InstanceWirerComponent:renderPropertyWires(i)
	return e('Frame', {				
		Size = UDim2.new(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = self.props.index + 1, 
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
					BorderSizePixel = 0,
					Image='http://www.roblox.com/asset/?id=699259085',
					
					LayoutOrder = 1,
				}),
				name = e('TextLabel', {
					Size = UDim2.new(0, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.XY,
					Text = self.props.properties[i],
					Font = Enum.Font.BuilderSansMedium,
					TextSize = PluginEnum.FontSizeTextPrimary,
					TextColor3 = PluginEnum.ColorTextPrimary,
					BackgroundColor3 = PluginEnum.ColorBackground,
					BorderSizePixel = 0,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = 2
				}),
				openButton = e("TextButton", {
					Text = 'Wire',
					AutomaticSize = Enum.AutomaticSize.XY,
					Size = UDim2.new(0, 0, 0, 0),
					TextColor3 = PluginEnum.ColorButtonNavigationText,
					BackgroundColor3 = PluginEnum.ColorButtonNavigationBackground,
					BorderSizePixel = 0,
					Font = Enum.Font.BuilderSansBold,
					TextSize = PluginEnum.FontSizeNavigationButton,
					LayoutOrder = 3,
					[React.Event.MouseButton1Click] = function()
						self.props.onClick(self.props.instances, self.props.properties[i])
					end,
				})
			})
		}
		)
end

return InstanceWirerComponent
