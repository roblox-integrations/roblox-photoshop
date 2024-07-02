--!strict

local PhotoshopIntegration = script:FindFirstAncestor("PhotoshopIntegration")
local Packages = PhotoshopIntegration.Packages

local MarketplaceService = game:GetService("MarketplaceService")
local Selection = game:GetService("Selection")

local React = require(Packages.React)
local Cryo = require(Packages.Cryo)

local e = React.createElement

local SyncableTexture = require(script.Parent.SyncableTexture)
local TextureProperties = require(script.Parent.TextureProperties)

local Types = require(script.Parent.Types)
type ImageType = Types.ImageType
type ProductInfo = Types.ProductInfo
type Session = Types.Session

type InstanceTextureData = {
	Instance: Instance,
	PropertyName: string,
	TextureId: string,
}

local function getTexturesFromInstancesNoBatching(instances: { Instance }): { InstanceTextureData }
	local instancesCopy = table.clone(instances)
	local textureList: { InstanceTextureData } = {}
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
						Instance = instance,
						PropertyName = propertyName,
						TextureId = textureId,
					})
				end
			end
		end
	end
	return textureList
end

-- function Widget:getProductInfo(assetId: string)
-- 	local state = self.state
-- 	if state[assetId] then
-- 		return state[assetId]
-- 	end
-- 	local productInfo: ProductInfo = {
-- 		Name = "",
-- 		Description = "",
-- 		Creator = {
-- 			CreatorType = "",
-- 			Name = "",
-- 			Id = -1,
-- 		},
-- 	}
-- 	self:setState({
-- 		[assetId] = table.clone(productInfo),
-- 	})
-- 	task.defer(function()
-- 		-- GetProductInfo is slow, so we'll do it on a separate thread and fill in data if we get results
-- 		local numericAssetId = string.match(assetId, "(%d+)")
-- 		if numericAssetId then
-- 			local ok, assetProductInfo = pcall(function()
-- 				return MarketplaceService:GetProductInfo(numericAssetId, Enum.InfoType.Asset)
-- 			end)
-- 			if ok then
-- 				local didMakeChanges = false
-- 				for key, value in assetProductInfo do
-- 					if productInfo[key] then
-- 						productInfo[key] = value
-- 						didMakeChanges = true
-- 					end
-- 				end
-- 				if didMakeChanges then
-- 					self:setState({
-- 						[assetId] = table.clone(productInfo),
-- 					})
-- 				end
-- 			end
-- 		end
-- 	end)
-- 	return productInfo
-- end

local function getProductInfo(assetId: string): ProductInfo
	return {
		Name = "",
		Description = "",
		Creator = {
			CreatorType = "",
			Name = "",
			Id = -1,
		},
	}
end

-- Returns all available sessions that are not already locked
local function getAvailableSessions(selection: { Instance }, lockedSessions: { [string]: Session }): { Session }
	local sessions = {}

	local lockedSourcePaths = {}
	for _, session in lockedSessions do
		lockedSourcePaths[session.sessionId] = true
	end

	if #selection > 0 then
		local textures = getTexturesFromInstancesNoBatching(selection)
		for _, textureData in textures do
			local sessionId = textureData.Instance:GetDebugId() .. "." .. textureData.PropertyName
			if lockedSourcePaths[sessionId] then
				continue
			end
			lockedSourcePaths[sessionId] = true
			local textureState: Session = {
				sessionId = sessionId,
				source = textureData.Instance,
				propertyName = textureData.PropertyName,
				shownImage = textureData.TextureId,
				imageType = "AssetId",
				productInfo = getProductInfo(textureData.TextureId),
			}
			table.insert(sessions, textureState)
		end
	end

	return sessions
end

local function lockSession(
	session: Session,
	lockedSessions: { [string]: Session },
	setLockedSessions: ({ [string]: Session }) -> nil
)
	print("lock", session.sessionId)
	setLockedSessions(Cryo.Dictionary.join(lockedSessions, {
		[session.sessionId] = session,
	}))
end

local function unlockSession(
	session: Session,
	lockedSessions: { [string]: Session },
	setLockedSessions: ({ [string]: Session }) -> nil
)
	print("unlock", session.sessionId)
	setLockedSessions(Cryo.Dictionary.join(lockedSessions, {
		[session.sessionId] = Cryo.None,
	}))
end

local function Widget(props: {
	[any]: { __RESTRICTED__: boolean },
})
	local selection: { Instance }, setSelection = React.useState({} :: { Instance })
	local lockedSessions: { [string]: Session }, setLockedSessions = React.useState({} :: { [string]: Session })

	React.useEffect(function()
		local onSelectionChanged = Selection.SelectionChanged:Connect(function()
			setSelection(Selection:Get())
		end)
		setSelection(Selection:Get())
		return function()
			onSelectionChanged:Disconnect()
		end
	end, {})

	local index = 1
	local function createTexture(session: Session, locked: boolean)
		local newTexture = e(
			SyncableTexture,
			Cryo.Dictionary.join(session, {
				locked = locked,
				index = index,
				setLocked = function(toLock: boolean)
					if toLock then
						lockSession(session, lockedSessions, setLockedSessions)
					else
						unlockSession(session, lockedSessions, setLockedSessions)
					end
				end,
				setShownImage = function(newImage: string)
					if session.source then
						session.source[session.propertyName] = "rbxassetid://" .. newImage
					end
					-- If the session is locked, update the shown image
					-- If the session isn't locked, it will be automatically updated when Widget is refreshed
					if lockedSessions[session.sessionId] then
						lockedSessions[session.sessionId].shownImage = newImage
					end
					setLockedSessions(table.clone(lockedSessions))
				end,
			})
		)
		index += 1
		return newTexture
	end

	local availableTextures = {}
	local lockedTextures = {}
	for _, session in getAvailableSessions(selection, lockedSessions) do
		availableTextures[session.sessionId] = createTexture(session, false)
	end
	for _, session in lockedSessions do
		lockedTextures[session.sessionId] = createTexture(session, true)
	end

	local hasAvailableTextures = not Cryo.isEmpty(availableTextures)
	local hasLockedTextures = not Cryo.isEmpty(lockedTextures)

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
		availableTextureList = hasAvailableTextures and e(
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
			}, availableTextures)
		),
		spacer = hasAvailableTextures and hasLockedTextures and e("Frame", {
			Size = UDim2.new(1, 0, 0, 4),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.CheckedFieldBorder),
			BorderSizePixel = 0,
			LayoutOrder = 2,
		}),
		lockedTextureList = hasLockedTextures and e(
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
		),
	})
end

return Widget
