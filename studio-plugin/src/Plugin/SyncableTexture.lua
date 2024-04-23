local PhotoshopIntegration = script:FindFirstAncestor("PhotoshopIntegration")
local Packages = PhotoshopIntegration.Packages

local HttpService = game:GetService("HttpService")

local React = require(Packages.React)

local e = React.createElement

local SyncableTexture = React.Component:extend("SyncableTexture")

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

function SyncableTexture:getSourcePath(source: Instance)
	local MAX_NAME_LENGTH = 13
	local sourcePath = source.Name
	if #sourcePath > MAX_NAME_LENGTH then
		sourcePath = sourcePath:sub(1, MAX_NAME_LENGTH - 3) .. "..."
	end

	sourcePath = sourcePath .. " - " .. self.state.propertyName

	return sourcePath
end

local function updateSession()
	pcall(function()
		HttpService:RequestAsync({
			Url = "http://localhost:9531/heartbeat",
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
			},
			Body = HttpService:JSONEncode({ plugin = "studio" }),
		})
	end)
end

function SyncableTexture:areBothPluginsConnected()
	local ok, response = pcall(function()
		return HttpService:RequestAsync({
			Url = "http://localhost:9531/heartbeat",
			Method = "GET",
		})
	end)
	if not ok or not response.Success then
		return
	end
	local body = HttpService:JSONDecode(response.Body)
	return (body.studio and body.photoshop)
end

function SyncableTexture:checkForUpdates()
	local thisSession: SessionData = self.state.sessionData
	local ok, response = pcall(function()
		return HttpService:RequestAsync({
			Url = "http://localhost:9531/session/?sessionId=" .. thisSession.sessionId,
			Method = "GET",
		})
	end)
	if not ok or not response.Success then
		return
	end
	local body = HttpService:JSONDecode(response.Body)
	if thisSession.lastUpdated ~= body.lastUpdated then
		thisSession.lastUpdated = body.lastUpdated
		if body.outAsset and body.outAsset.assetId then
			local imageId = body.outAsset.assetId
			if self.state.source then
				self.state.source[self.state.propertyName] = "rbxassetid://" .. imageId
			end
			self:setState({
				shownImage = imageId,
			})
			self.props.onSessionDataChanged(self)
		end
	end
end

function SyncableTexture:pollSessionHeartbeat()
	self.heartbeatPollTask = task.spawn(function()
		while self.state.isPolling do
			for i = 1, SESSION_HEARTBEAT_INTERVAL / SESSION_UPDATE_INTERVAL do
				if not self.state.isPolling then
					return
				end
				self:checkForUpdates()
				task.wait(SESSION_UPDATE_INTERVAL)
			end

			updateSession()
			self:checkForUpdates()
		end
	end)
end

function SyncableTexture:onClickSyncButton()
	local state: StateData = self.state
	local thisSession: SessionData = state.sessionData
	local shownImage = state.shownImage
	if state.imageType == "AssetId" and shownImage == "" then
		return
	end
	if not state.source then
		return
	end
	local ok, response = pcall(function()
		local assetId = string.match(shownImage, "(%d+)")
		return HttpService:RequestAsync({
			Url = "http://localhost:9531/session/",
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
			},
			Body = HttpService:JSONEncode({
				instanceId = state.source,
				instanceName = state.source.Name,
				propertyName = state.propertyName,
				assetId = assetId,
				asset = {
					assetId = assetId,
					productInfo = state.productInfo,
				},
				gameInfo = {
					Creator = {
						CreatorType = game.CreatorType.Name,
						CreatorId = game.CreatorId,
					},
				},
			}),
		})
	end)
	if not ok or not response.Success then
		if typeof(response) == "table" then
			warn("Request failed:", response.StatusCode, response.StatusMessage)
		else
			warn("Request failed:", response)
		end
		return
	end
	local body = HttpService:JSONDecode(response.Body)
	thisSession.sessionId = body.sessionId
	thisSession.lastUpdated = body.lastUpdated
	thisSession.asset = body.asset
	thisSession.outAsset = body.outAsset
	self.props.onSessionDataChanged(self)
end

function SyncableTexture:onClickDisconnectButton()
	self.state.isPolling = false
	if self.heartbeatPollTask then
		local status = coroutine.status(self.heartbeatPollTask)
		if status == "running" or status == "normal" then
			task.cancel(self.heartbeatPollTask)
		end
	end
	self.props.onSessionDataChanged(self)
end

function SyncableTexture:didMount()
	if self.props.hasPolling then
		self.state.isPolling = true
		self:pollSessionHeartbeat()
	end
	if self.state.source and self.state.propertyName then
		self.state.source:GetPropertyChangedSignal(self.state.propertyName):Connect(function()
			self.state.shownImage = self.state.source[self.state.propertyName]
			self.props.onSessionDataChanged(self)
		end)
	end
end

function SyncableTexture:willUnmount()
	self:onClickDisconnectButton()
end

function SyncableTexture:init()
	self:setState(self.props)
end

function SyncableTexture.getDerivedStateFromProps(props)
	props.isPolling = nil
	return props
end

function SyncableTexture:render()
	local state: StateData = self.state
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
			Image = if state.imageType == "AssetId" then state.shownImage else "",
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
				Text = if self.props.hasPolling then "Unlink" else "Edit",
				AutomaticSize = Enum.AutomaticSize.XY,
				Size = UDim2.new(0, 0, 0, 0),
				TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButtonText),
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButton),
				BorderSizePixel = 0,
				Font = Enum.Font.BuilderSansBold,
				TextSize = 40,
				LayoutOrder = 1,
				[React.Event.MouseButton1Click] = function()
					if self.props.hasPolling then
						self:onClickDisconnectButton()
					else
						self:onClickSyncButton()
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
				Text = self:getSourcePath(state.source),
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
