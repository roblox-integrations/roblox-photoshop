local PhotoshopIntegration = script:FindFirstAncestor("PhotoshopIntegration")
local Packages = PhotoshopIntegration.Packages

local MarketplaceService = game:GetService("MarketplaceService")
local AssetService = game:GetService("AssetService")
local Selection = game:GetService("Selection")

local React = require(Packages.React)
local Cryo = require(Packages.Cryo)

local e = React.createElement

local Widget = React.Component:extend("Widget")
local SyncableTexture = require(script.Parent.SyncableTexture)

local TextureProperties = require(script.Parent.TextureProperties)
type ImageType = "None" | "AssetId" | "BMP"

local DEBUG_USE_EDITABLE_IMAGES = true
local ok, areEditableImagesEnabled = pcall(function()
	Instance.new("EditableImage"):WritePixels(Vector2.zero, Vector2.one, { 0, 0, 0, 0 })
end)
if not (ok and areEditableImagesEnabled) then
	DEBUG_USE_EDITABLE_IMAGES = false
end

local function getTexturesFromInstancesNoBatching(instances: { Instance })
	local instancesCopy = table.clone(instances)
	local textureList = {}
	for _, instance in instancesCopy do
		if instance:IsA("BasePart") and not instance:IsA("TriangleMeshPart") and not instance:IsA("Terrain") then
			-- For convenience, if the selected part has a SpecialMesh then we'll include that too
			local fileMesh = instance:FindFirstChildWhichIsA("FileMesh")
			if fileMesh and not table.find(instancesCopy, fileMesh) then
				table.insert(instancesCopy, fileMesh)
				continue
			end
		end
		if instance:IsA("MeshPart") then
			local surfaceAppearance = instance:FindFirstChildWhichIsA("SurfaceAppearance")
			if surfaceAppearance and not table.find(instancesCopy, surfaceAppearance) then
				table.insert(instancesCopy, surfaceAppearance)
				continue
			end
		end
		for _, texturePropertyData in TextureProperties do
			if not instance:IsA(texturePropertyData.ClassName) then
				continue
			end
			for _, propertyName in texturePropertyData.Properties do
				local ok, textureId = pcall(function()
					return instance[propertyName]
				end)
				if not ok then
					warn(textureId)
					continue
				end
				if textureId ~= "" then
					table.insert(textureList, {
						instance = instance,
						propertyName = propertyName,
						textureId = textureId,
					})
				end
			end
		end
	end
	return textureList
end

function Widget:DEPRECATED_refreshSelection()
	local source: Instance? = React.None
	local shownImage = ""
	local productInfo = { Creator = {} } :: { Name: string, Creator: { Name: string } }

	local shownAssetId = string.match(shownImage, "(%d+)")
	local imageType = "None"
	if shownAssetId then
		imageType = "AssetId"
		local ok, assetProductInfo = pcall(function()
			return MarketplaceService:GetProductInfo(shownAssetId, Enum.InfoType.Asset)
		end)
		if ok and assetProductInfo then
			productInfo = assetProductInfo
		end
	elseif shownImage ~= "" and DEBUG_USE_EDITABLE_IMAGES then
		imageType = "BMP"
		local ok, editableImagePreview = pcall(function()
			return AssetService:CreateEditableImageAsync(shownImage)
		end)
		if ok and editableImagePreview then
			shownImage = editableImagePreview
		else
			shownImage = nil
		end
	end

	self:setState({
		source = source,
		imageType = imageType,
		shownImage = shownImage,
		productInfo = productInfo,
	})
end

function Widget:getProductInfo(assetId: string)
	local state = self.state
	if state[assetId] then
		return state[assetId]
	end
	local productInfo = {
		Name = "",
		Description = "",
		Creator = {
			CreatorType = "",
			Name = "",
			Id = -1,
		},
	}
	self:setState({
		[assetId] = table.clone(productInfo),
	})
	task.defer(function()
		-- GetProductInfo is slow, so we'll do it on a separate thread and fill in data if we get results
		local numericAssetId = string.match(assetId, "(%d+)")
		if numericAssetId then
			local ok, assetProductInfo = pcall(function()
				return MarketplaceService:GetProductInfo(numericAssetId, Enum.InfoType.Asset)
			end)
			if ok then
				local didMakeChanges = false
				for key, value in assetProductInfo do
					if productInfo[key] then
						productInfo[key] = value
						didMakeChanges = true
					end
				end
				if didMakeChanges then
					self:setState({
						[assetId] = table.clone(productInfo),
					})
				end
			end
		end
	end)
	return productInfo
end

function Widget:getAvailableSessions()
	local sessions = {}

	local lockedSourcePaths = {}
	for _, session in self.state.lockedSessions do
		lockedSourcePaths[session.sourcePath] = true
	end

	local selection = self.state.selection
	if #selection > 0 then
		local textures = getTexturesFromInstancesNoBatching(selection)
		for _, textureData in textures do
			local sourcePath = textureData.instance:GetDebugId() .. "." .. textureData.propertyName
			if lockedSourcePaths[sourcePath] then
				continue
			end
			lockedSourcePaths[sourcePath] = true
			local textureState = {
				source = textureData.instance,
				propertyName = textureData.propertyName,
				sourcePath = sourcePath,
				shownImage = textureData.textureId,
				imageType = "AssetId",
				productInfo = self:getProductInfo(textureData.textureId),
			}
			table.insert(sessions, textureState)
		end
	end

	return sessions
end

function Widget:willUnmount()
	self.onSelectionChanged:Disconnect()
end

function Widget:init()
	self.onSelectionChanged = Selection.SelectionChanged:Connect(function()
		self:setState({
			selection = Selection:Get(),
		})
	end)
	self:setState({
		selection = Selection:Get(),
		lockedSessions = {},
	})
end

function Widget:onLockTexture(syncableTexture)
	local lockedSessions = self.state.lockedSessions
	local sessionId = syncableTexture.state.sessionData.sessionId
	if sessionId then
		lockedSessions[sessionId] = syncableTexture.state
	end
	self:setState({})
end

function Widget:onUnlockTexture(syncableTexture, ...)
	local lockedSessions = self.state.lockedSessions
	local sessionId = syncableTexture.state.sessionData.sessionId
	if sessionId then
		lockedSessions[sessionId] = nil
	end
	self:setState({})
end

function Widget:render()
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
