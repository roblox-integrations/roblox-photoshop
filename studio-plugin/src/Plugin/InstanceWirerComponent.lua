--!strict
local PhotoshopIntegration = script:FindFirstAncestor("PhotoshopIntegration")
local Packages = PhotoshopIntegration.Packages

local Cryo = require(Packages.Cryo)

local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")

local React = require(Packages.React)

local e = React.createElement

local TextureProperties = require(script.Parent.TextureProperties)

local InstanceWirerComponent = React.Component:extend("InstanceWirerComponent")
local PluginEnum = require(script.Parent.Enum)


local SESSION_HEARTBEAT_INTERVAL = 3 -- Time between session heartbeat updates
local SESSION_UPDATE_INTERVAL = 0.25 -- Time between checks for updates

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

function InstanceWirerComponent:setHeaderAndPropertiesHeaderLabel(target, instances) 
	if #instances >= 1 then
		print('Build header')
		target.header = instances[1].ClassName .. ' : ' .. instances[1].Name
		local className = instances[1].ClassName
		local properties = TextureProperties[className]
		if properties == nil then properties = {} end
		target.properties = properties		
	end 
end


function InstanceWirerComponent:init()

	local instances  = self.props.instances
	self:setHeaderAndPropertiesHeaderLabel(self.props, instances)
	self:setState(self.props)


	self.onSelectionChanged = Selection.SelectionChanged:Connect(function()
		print('InstanceWirer: selectionChanged')
		local instances  = Selection:Get()
		local stateUpdate = {}
		self:setHeaderAndPropertiesHeaderLabel(stateUpdate, instances)
		stateUpdate.instances = instances
		self:setState(stateUpdate)
	end)


	
end

function InstanceWirerComponent.getDerivedStateFromProps(props)
	return props
end

function InstanceWirerComponent:render()


	print('InstanceWirer: ' .. self.state.header)

	if #self.state.properties == 0 then return nil end

	local properties =  {}
	for i, _ in self.state.properties do
		local p = self:renderPropertyWires(i)
		properties[i] = p;
	end

	local header =  e("TextLabel", {
		Size = UDim2.new(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		Text = self.state.header,
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
					Text = self.state.properties[i],
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
						print('--- onclick')
						print(self.state.instances[1])
						print(self.state.properties[i])
						
						self.state.onClick(self.state.instances[1], self.state.properties[i])
					end,
				})
			})
		}
		)
end

return InstanceWirerComponent
