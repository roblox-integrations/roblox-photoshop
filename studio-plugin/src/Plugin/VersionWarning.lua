local VersionWarning = {}

local HttpService = game:GetService("HttpService")

local VERSION_URL = "https://api.github.com/repositories/785342744/releases/latest"
local VERSION = require(script.Parent._VERSION)
local VERSION_CHECK_TIME = 3600

local function checkCurrentVersion()
	local ok, response = pcall(function()
		return HttpService:RequestAsync({
			Url = VERSION_URL,
			Method = "GET",
			Headers = {
				["Content-Type"] = "application/json",
			},
		})
	end)
	if ok and response.Success then
		local body = HttpService:JSONDecode(response.Body)
		local latestVersion = body.name
		if latestVersion ~= VERSION then
			warn(
				"There is a new version of the Photoshop Integration plugin available. Please update from the GitHub repository: https://github.com/roblox-integrations/roblox-photoshop"
			)
		end
	end
end

function VersionWarning:runVersionChecking()
	task.spawn(function()
		while true do
			checkCurrentVersion()
			task.wait(VERSION_CHECK_TIME)
		end
	end)
end

return VersionWarning
