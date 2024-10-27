local PhotoshopIntegration = script:FindFirstAncestor("PhotoshopIntegration")
local Packages = PhotoshopIntegration.Packages


local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")

local React = require(Packages.React)
local Cryo = require(Packages.Cryo)

local e = React.createElement

local Widget = React.Component:extend("Widget")
-- local SyncableTexture = require(script.Parent.SyncableTexture)
local InstanceWirerComponent = require(script.Parent.InstanceWirerComponent)
local PieceComponent = require(script.Parent.PieceComponent)
local TextureProperties = require(script.Parent.TextureProperties)
type ImageType = "None" | "AssetId" | "BMP"

local DEBUG_USE_EDITABLE_IMAGES = true
local ok, areEditableImagesEnabled = pcall(function()
	Instance.new("EditableImage"):WritePixels(Vector2.zero, Vector2.one, { 0, 0, 0, 0 })
end)
if not (ok and areEditableImagesEnabled) then
	DEBUG_USE_EDITABLE_IMAGES = false
end



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
		self:setState({
			selection = Selection:Get(),
			pieces = self.state.pieces
		})
	end)
	self:setState({
		selection = Selection:Get(),
		pieces = {}
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
			wait(5)
			self:setState({
				selection = Selection:Get(),
				pieces = pieces
			})
			break
		end 		
    end)()
	
end




function Widget:render()
	local instanceWirers = {}
	print('about to render')
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
	pieceComponents  = {}
	print('about to build pieces')

	local k = 1	
	for _, piece in self.state.pieces do 
		local newPieceComponent = e(
			PieceComponent, 
			{
				piece = piece,
				index = k
			}
		)

		print('about to set piece component ' .. k)
		pieceComponents[k] = newPieceComponent
		k = k + 1
		print('set piece component')
	end
	print('about to build selection')

	for i, selected in self.state.selection do 
		local newInstanceWirer = e(
			InstanceWirerComponent, 
			{
				instance = selected,
				index = i
			})
		instanceWirers[i] = newInstanceWirer
	end
	print('about to build the component')
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

		instanceWirersList = e(
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
				}, instanceWirers)
			),

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

function Widget:render2()
	local sessionTextures = {}
	local hasSessionTextures = false
	local availableSessions = self:getAvailableSessions()
	for i, stateData in availableSessions do
		local newTexture = e(
			SyncableTexture,
			Cryo.Dictionary.join(stateData, {
				index = i,
				sessionData = {},
				hasPolling = false,
				onSessionDataChanged = function(syncableTexture)
					self:onLockTexture(syncableTexture)
				end,
			})
		)
		sessionTextures[stateData.sourcePath] = newTexture
		hasSessionTextures = true
	end

	local lockedTextures = {}
	local hasLockedTextures = false
	local i = 1
	for _, stateData in self.state.lockedSessions do
		local newTexture = e(
			SyncableTexture,
			Cryo.Dictionary.join(stateData, {
				index = #availableSessions + i,
				hasPolling = true,
				onSessionDataChanged = function(syncableTexture)
					self:onUnlockTexture(syncableTexture)
				end,
			})
		)
		lockedTextures[stateData.sourcePath] = newTexture
		hasLockedTextures = true
		i += 1
	end

	local theme = settings().Studio.Theme

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
		selected = if hasSessionTextures
			then e(
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
				}, sessionTextures)
			)
			else nil,
		spacer = if hasSessionTextures and hasLockedTextures
			then e("Frame", {
				Size = UDim2.new(1, 0, 0, 4),
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.CheckedFieldBorder),
				BorderSizePixel = 0,
				LayoutOrder = 2,
			})
			else nil,
		activeEdits = if hasLockedTextures
			then e(
				"Frame",
				{
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 0.5,
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					LayoutOrder = 3,
				},
				Cryo.Dictionary.join({
					uiListLayout = e("UIListLayout", {
						Padding = UDim.new(0, 4),
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
				}, lockedTextures)
			)
			else nil,
	})
end

return Widget
