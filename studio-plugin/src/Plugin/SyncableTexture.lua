--!strict

local PhotoshopIntegration = script:FindFirstAncestor("PhotoshopIntegration")
local Packages = PhotoshopIntegration.Packages

local HttpService = game:GetService("HttpService")

local React = require(Packages.React)
local Cryo = require(Packages.Cryo)

local e = React.createElement

local Types = require(script.Parent.Types)
type ImageType = Types.ImageType
type ProductInfo = Types.ProductInfo
type Session = Types.Session
type SessionPacket = Types.SessionPacket

local SESSION_HEARTBEAT_INTERVAL = 3 -- Time between session heartbeat updates
local SESSION_UPDATE_INTERVAL = 0.25 -- Time between checks for updates
local BASE_ENDPOINT = "http://localhost:9531/"
local MAX_SOURCE_PATH_NAME_LENGTH = 13

local function getSourcePath(source: Instance, propertyName: string)
	local sourcePath = source.Name
	if #sourcePath > MAX_SOURCE_PATH_NAME_LENGTH then
		sourcePath = sourcePath:sub(1, MAX_SOURCE_PATH_NAME_LENGTH - 3) .. "..."
	end
	sourcePath = sourcePath .. " - " .. propertyName
	return sourcePath
end

local function updateSession()
	local ok, response = pcall(function()
		return HttpService:RequestAsync({
			Url = BASE_ENDPOINT .. "heartbeat",
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
			},
			Body = HttpService:JSONEncode({ plugin = "studio" }),
		})
	end)
	if not ok then
		warn(`Http POST request failed: {response}`)
		return
	end
	if not response.Success then
		warn(`Http POST request failed: (Code {response.StatusCode}) {response.StatusMessage}`)
		return
	end
end

local function areBothPluginsConnected()
	local ok, response = pcall(function()
		return HttpService:RequestAsync({
			Url = BASE_ENDPOINT .. "heartbeat",
			Method = "GET",
		})
	end)
	if not ok then
		warn(`Http GET request failed: {response}`)
		return
	end
	if not response.Success then
		warn(`Http GET request failed: (Code {response.StatusCode}) {response.StatusMessage}`)
		return
	end
	local body = HttpService:JSONDecode(response.Body) :: {
		studio: boolean,
		photoshop: boolean,
	}
	return (body.studio and body.photoshop)
end

function checkForUpdates(
	sessionPacketBinding: React.Binding<SessionPacket>,
	setSessionPacket: (SessionPacket) -> (),
	setShownImage: (string) -> ()
)
	local sessionPacket = sessionPacketBinding:getValue()
	local ok, response = pcall(function()
		return HttpService:RequestAsync({
			Url = BASE_ENDPOINT .. "session/?sessionId=" .. sessionPacket.sessionId,
			Method = "GET",
		})
	end)
	if not ok then
		warn(`Http GET request failed: {response}`)
		return
	end
	if not response.Success then
		warn(`Http GET request failed: (Code {response.StatusCode}) {response.StatusMessage}`)
		return
	end
	local body = HttpService:JSONDecode(response.Body) :: SessionPacket
	if sessionPacket.lastUpdated ~= body.lastUpdated then
		setSessionPacket(Cryo.Dictionary.join(sessionPacket, {
			lastUpdated = body.lastUpdated,
		}))
		if body.outAsset and body.outAsset.assetId then
			setShownImage(body.outAsset.assetId)
		end
	end
end

local function SyncableTexture(props: Session & {
	locked: boolean,
	index: number,
	setLocked: (boolean) -> (),
	setShownImage: (string) -> (),
})
	local theme = settings().Studio.Theme

	local sessionPacket, setSessionPacket = React.useBinding({
		sessionId = "",
		lastUpdated = "",
		asset = "",
		outAsset = {
			assetId = "",
		},
	} :: SessionPacket)

	local function onClickSyncButton()
		local shownImage = props.shownImage
		if props.imageType == "AssetId" and shownImage == "" then
			return
		end
		if not props.source then
			return
		end
		-- local ok, response = pcall(function()
		-- 	local assetId = string.match(shownImage, "(%d+)")
		-- 	return HttpService:RequestAsync({
		-- 		Url = BASE_ENDPOINT .. "session/",
		-- 		Method = "POST",
		-- 		Headers = {
		-- 			["Content-Type"] = "application/json",
		-- 		},
		-- 		Body = HttpService:JSONEncode({
		-- 			instanceId = props.source,
		-- 			instanceName = props.source.Name,
		-- 			propertyName = props.propertyName,
		-- 			assetId = assetId,
		-- 			asset = {
		-- 				assetId = assetId,
		-- 				productInfo = props.productInfo,
		-- 			},
		-- 			gameInfo = {
		-- 				Creator = {
		-- 					CreatorType = game.CreatorType.Name,
		-- 					CreatorId = game.CreatorId,
		-- 				},
		-- 			},
		-- 		}),
		-- 	})
		-- end)
		-- if not ok then
		-- 	warn(`Http POST request failed: {response}`)
		-- 	return
		-- end
		-- if not response.Success then
		-- 	warn(`Http POST request failed: (Code {response.StatusCode}) {response.StatusMessage}`)
		-- 	return
		-- end
		-- local body = HttpService:JSONDecode(response.Body) :: SessionPacket
		-- setSessionPacket(Cryo.Dictionary.join(sessionPacket, {
		-- 	sessionId = body.sessionId,
		-- 	lastUpdated = body.lastUpdated,
		-- 	asset = body.asset,
		-- 	outAsset = body.outAsset,
		-- }))
		props.setLocked(true)
	end

	local function onClickDisconnectButton()
		if props.locked then
			props.setLocked(false)
		end
	end

	React.useEffect(function()
		local heartbeatPollTaskConn: thread?
		if props.locked then
			heartbeatPollTaskConn = task.spawn(function()
				while true do
					for i = 1, SESSION_HEARTBEAT_INTERVAL / SESSION_UPDATE_INTERVAL do
						-- checkForUpdates(sessionPacket, setSessionPacket, props.setShownImage)
						task.wait(SESSION_UPDATE_INTERVAL)
					end

					-- updateSession()
					-- checkForUpdates(sessionPacket, setSessionPacket, props.setShownImage)
				end
			end)
		end
		return function()
			if heartbeatPollTaskConn then
				task.cancel(heartbeatPollTaskConn)
			end
		end
	end, { props.locked } :: { any })

	React.useEffect(function()
		local onPropertyChangedConn: RBXScriptConnection?
		if props.source and props.propertyName then
			onPropertyChangedConn = props.source:GetPropertyChangedSignal(props.propertyName):Connect(function()
				local newImage = props.source[props.propertyName]
				props.setShownImage(newImage)
			end)
		end
		return function()
			if onPropertyChangedConn then
				onPropertyChangedConn:Disconnect()
			end
			onClickDisconnectButton()
		end
	end, {})

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 0, 120),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = props.index,
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
			Image = if props.imageType == "AssetId" then props.shownImage else "",
		}),
		syncDetails = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = 2,
		}, {
			uiListLayout = e("UIListLayout", {
				Padding = UDim.new(0, 10),
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			syncButton = e("TextButton", {
				Text = if props.locked then "Unlink" else "Edit",
				AutomaticSize = Enum.AutomaticSize.XY,
				Size = UDim2.new(0, 0, 0, 0),
				TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButtonText),
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButton),
				BorderSizePixel = 0,
				Font = Enum.Font.BuilderSansBold,
				TextSize = 40,
				LayoutOrder = 1,
				[React.Event.MouseButton1Click] = function()
					if props.locked then
						onClickDisconnectButton()
					else
						onClickSyncButton()
					end
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
				Text = getSourcePath(props.source, props.propertyName),
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

return SyncableTexture
