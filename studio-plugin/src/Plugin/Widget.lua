local PhotoshopIntegration = script:FindFirstAncestor("PhotoshopIntegration")
local Packages = PhotoshopIntegration.Packages


local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")

local React = require(Packages.React)
local Cryo = require(Packages.Cryo)

local e = React.createElement

local Widget = React.Component:extend("Widget")
local InstanceWirerComponent = require(script.Parent.InstanceWirerComponent)
local PieceComponent = require(script.Parent.PieceComponent)
local PieceDetailsComponent = require(script.Parent.PieceDetailsComponent)
local TextureProperties = require(script.Parent.TextureProperties)
local PluginEnum = require(script.Parent.Enum)
type ImageType = "None" | "AssetId" | "BMP"

local DEBUG_USE_EDITABLE_IMAGES = true
local ok, areEditableImagesEnabled = pcall(function()
	Instance.new("EditableImage"):WritePixels(Vector2.zero, Vector2.one, { 0, 0, 0, 0 })
end)
if not (ok and areEditableImagesEnabled) then
	DEBUG_USE_EDITABLE_IMAGES = false
end
local MODE_LIST = 0
local MODE_PIECE_DETAILS = 1


function Widget:willUnmount()
	self.onSelectionChanged:Disconnect()
end


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


function getPieces(): { Piece }
    print(`poll`)
    -- todo MI handle errors
    local res = HttpService:GetAsync("http://localhost:3000/api/pieces")
    local json = HttpService:JSONDecode(res)
    -- print(`fetched json updates:  {#json}`)
    local pieces = json :: { Piece }
	return pieces
    -- local tmp_pieces_map = {}
    -- for _, p in pieces do
    --     tmp_pieces_map[p.id] = p
    -- end

	-- return tmp_pieces_map
end


function Widget:init()
	print('Widget:init') 
	local localPieces = self.state.pieces
	self.onSelectionChanged = Selection.SelectionChanged:Connect(function()
		print('selection changed')
		-- if self.state ~= nil then  
		-- 	print('update current state')
		-- 	local st = self.state 
		-- 	st.selection = Selection:Get(),
		-- 	self.setState(st)
		-- else  
		-- 	print('set new state')
			self:setState({
			selection = Selection:Get(),
			pieces = self.state.pieces,
			mode = self.state.mode
			})
		-- end 
	end)
	self:setState({
		selection = Selection:Get(),
		pieces = {},
		mode = MODE_LIST
	})
	print('Widget:done')
 	coroutine.wrap(function()
        print("WIDGET starting polling")
 		while true do	
			local pieces = getPieces()
			if #pieces > 0 then
				print(`there were {#pieces} updates`)
			end
			for k, v in pieces do
				print(k .. '->' .. v.filePath)
			end
			wait(1)
			self:setState({
				selection = Selection:Get(),
				pieces = pieces
			})
			break
		end 		
    end)()
	
end



function Widget:render()
	

	print('about to render')
	local theme = settings().Studio.Theme

    -- local elemen = renderPlayground()
	-- if true then return elemen end

	local element = e("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.XY,
		ScrollingDirection = Enum.ScrollingDirection.XY,
	}, {
		uiListLayout = e("UIListLayout", {
			Padding = UDim.new(0, 4),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		modeSwitcher = e("TextButton", {
			Text = 'Switch',
			AutomaticSize = Enum.AutomaticSize.XY,
			Size = UDim2.new(0, 0, 0, 0),
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButtonText),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButton),
			BorderSizePixel = 0,
			Font = Enum.Font.BuilderSansBold,
			TextSize = 40,
			LayoutOrder = 0,
			[React.Event.MouseButton1Click] = function()
				local lMode = self.state.mode+1
				if lMode > MODE_PIECE_DETAILS then
					lMode = MODE_LIST
				end
				local st = self.state
				st.mode = lMode
				self:setState(st)
			end
		}),
		content =  if self.state.mode == MODE_LIST then self:renderList() else self:renderPieceDetails(),

	})

	return element
end


function Widget:renderPieceDetails()

	return e("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.XY,
		ScrollingDirection = Enum.ScrollingDirection.XY,
	}, {
		uiListLayout = e("UIListLayout", {
			Padding = UDim.new(0, 4),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		pieceDetails = e(PieceDetailsComponent, {
				piece = self.state.currentPiece,
				selection = self.state.selection
			}
		),
	})
end


function Widget:renderList()
	local instanceWirers = {}
	if #self.state.selection == 0 and #self.state.pieces == 0 then
		print('selections are nil')
		local theme = settings().Studio.Theme

		local element = e("TextLabel", {
			Size = UDim2.new(0, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			LayoutOrder = 1,
			Text = "To start iterating on images, select an instance with an image property and click ‘Wire’ or place a bitmap file to a working folder.",
			Font = Enum.Font.BuilderSansMedium,
			TextSize = 20,
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogButtonText),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Light),
			BorderSizePixel = 0,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		return element
	end
	local pieceComponents  = {}
	print('about to build pieces')

	local k = 1	
	for _, piece in self.state.pieces do 
		local newPieceComponent = e(
			PieceComponent, 
			{
				piece = piece,
				index = k,
				onClick = function()
					self.state.mode = MODE_PIECE_DETAILS
					local st = self.state
					st.currentPiece = piece
					self:setState(st)
				end
			}
		)

		print('about to set piece component ' .. k)
		pieceComponents[k] = newPieceComponent
		k = k + 1
		print('set piece component')
	end
	-- print('about to build selection')

	return e("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.XY,
		ScrollingDirection = Enum.ScrollingDirection.XY,
	}, {
		uiListLayout = e("UIListLayout", {
			Padding = UDim.new(0, 4),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		-- instanceWirersList = e(
		-- 		"Frame",
		-- 		{
		-- 			Size = UDim2.new(0, 0, 0, 0),
		-- 			BackgroundTransparency = 1,
		-- 			AutomaticSize = Enum.AutomaticSize.XY,
		-- 			LayoutOrder = 1,
		-- 		},
		-- 		Cryo.Dictionary.join({
		-- 			uiListLayout = e("UIListLayout", {
		-- 				Padding = UDim.new(0, 0),
		-- 				HorizontalAlignment = Enum.HorizontalAlignment.Left,
		-- 				SortOrder = Enum.SortOrder.LayoutOrder,
		-- 			}),
		-- 		}, instanceWirers)
		-- 	),

		pieceComponentsList = e(
			"Frame",
			{
				Size = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 1,
			},
			Cryo.Dictionary.join({
				uiListLayout = e("UIListLayout", {
					Padding = UDim.new(0, 0),
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			}, pieceComponents)
		)	
	})
end

function renderPlayground()

	local i = 1
	local elements = {}
	while i < 100 do
		
		local sourceText = e(
			'Frame', {				
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.XY,
			LayoutOrder = i,
			}, {
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
						Text = "Item right " .. -i,
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
		})

		elements[i] = sourceText
		i = i +1
	end
	
	print('elements count: ' .. #elements)

	local elemen = e("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.XY,
			ScrollingDirection = Enum.ScrollingDirection.XY,
	}, {
		Cryo.Dictionary.join({
			uiListLayout = e("UIListLayout", {
				Padding = UDim.new(0, 10),
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		}, elements)
	}

	)
	return elemen
end
return Widget
