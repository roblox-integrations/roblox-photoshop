--!strict
local PhotoshopIntegration = script:FindFirstAncestor("PhotoshopIntegration")
local Packages = PhotoshopIntegration.Packages

local Cryo = require(Packages.Cryo)

local HttpService = game:GetService("HttpService")

local React = require(Packages.React)

local e = React.createElement

local TextureProperties = require(script.Parent.TextureProperties)

local InstanceWirerComponent = React.Component:extend("InstanceWirerComponent")


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

function InstanceWirerComponent:init()
	print('className: ' .. self.props.instance.ClassName)
	self.props.properties = TextureProperties[self.props.instance.ClassName]
	-- TODO MI load images
	self:setState(self.props)

	
end

function InstanceWirerComponent.getDerivedStateFromProps(props)
	return props
end

function InstanceWirerComponent:render()
	local state = self.state
	print('InstanceWirer: ' .. state.instance.Name)
	-- state.instance
	-- state.index 


	


	if #self.state.properties == 0 then return nil end
	local theme = settings().Studio.Theme

	local properties =  {}
	for i, property in self.state.properties do
		print(self.state.instance.Name .. ' : ' .. property)
		local p = 
		e('Frame', {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 0, 120),
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = i
		}, 
			{
				uiListLayout = e("UIListLayout", {
					Padding = UDim.new(0, 10),
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				propertyName = e("TextLabel", {
					Size = UDim2.new(0, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.XY,
					LayoutOrder = 2,
					Text = state.properties[i],
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

				syncButton = e("TextButton", {
					Text = 'Wire',
					AutomaticSize = Enum.AutomaticSize.XY,
					Size = UDim2.new(0, 0, 0, 0),
					TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButtonText),
					BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButton),
					BorderSizePixel = 0,
					Font = Enum.Font.BuilderSansBold,
					TextSize = 40,
					LayoutOrder = 1,
					[React.Event.MouseButton1Click] = function()
						print('Wire button clicked')
					end,
					}, 
					{
						e("UIPadding", {
							PaddingLeft = UDim.new(0, 5),
							PaddingRight = UDim.new(0, 5),
							PaddingTop = UDim.new(0, 5),
							PaddingBottom = UDim.new(0, 5),
						}),
					}),
			}
		)
		properties[i] = p;
	end


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
		sourceText = e("TextLabel", {
			Size = UDim2.new(0, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			LayoutOrder = 2,
			Text = state.instance.Name,
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
			Cryo.Dictionary.join({
				uiListLayout = e("UIListLayout", {
					Padding = UDim.new(0, 0),
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			}, properties)
		}),
	})
end

return InstanceWirerComponent
