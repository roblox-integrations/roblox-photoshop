--!strict
local Packages = script:FindFirstAncestor("PhotoshopIntegration").Packages

local HttpService = game:GetService("HttpService")
local Cryo = require(Packages.Cryo)

local React = require(Packages.React)

local e = React.createElement

local PieceComponent = React.Component:extend("PieceComponent")
local PluginEnum = require(script.Parent.Enum)


export type Piece = {
    id: string,
    role: string, -- "asset|editable"
    type: string, --  "image|mesh|meshtexturepack|pbrpack"
    filePath: string,
    fileHash: string,
    uploads: {
        {
            assetId: string,
            decalId: string,
            fileHash: string,
            operationId: string
        }
    },
    updatedAt: number,
    uploadedAt: number, 
    deletedAt: number
}


function PieceComponent:onClickSyncButton()
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

function PieceComponent:didMount()
	 -- add listener for tags changes
		-- if self.state.source and self.state.propertyName then
		-- 	self.state.source:GetPropertyChangedSignal(self.state.propertyName):Connect(function()
		-- 		self.state.shownImage = self.state.source[self.state.propertyName]
		-- 		self.props.onSessionDataChanged(self)
		-- 	end)
		-- end
end

function PieceComponent:willUnmount()
	--self:onClickDisconnectButton()
end

function PieceComponent:init()
	self:setState(self.props)
end

function PieceComponent:getDerivedStateFromProps(props)
	return props
end


function PieceComponent:render()
	local state = self.state
	print('about to render piece component')
	return e('Frame', {				
		Size = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = self.props.index, 
		BackgroundColor3
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

return PieceComponent
