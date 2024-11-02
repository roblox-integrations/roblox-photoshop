--!strict
local Packages = script:FindFirstAncestor("PhotoshopIntegration").Packages

local HttpService = game:GetService("HttpService")

local React = require(Packages.React)

local e = React.createElement

local PieceComponent = React.Component:extend("PieceComponent")



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

function PieceComponent.getDerivedStateFromProps(props)
	return props
end


function PieceComponent:render()
	local state = self.state
	local theme = settings().Studio.Theme

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
			syncButton = e("TextButton", {
				Text = 'Open',
				AutomaticSize = Enum.AutomaticSize.XY,
				Size = UDim2.new(0, 0, 0, 0),
				TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButtonText),
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButton),
				BorderSizePixel = 0,
				Font = Enum.Font.BuilderSansBold,
				TextSize = 40,
				LayoutOrder = 1,
				[React.Event.MouseButton1Click] = function()
					self.state.onClick()
				end,
			}, {
				e("UIPadding", {
					PaddingLeft = UDim.new(0, 5),
					PaddingRight = UDim.new(0, 5),
					PaddingTop = UDim.new(0, 5),
					PaddingBottom = UDim.new(0, 5),
				}),
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
	})
end

return PieceComponent
