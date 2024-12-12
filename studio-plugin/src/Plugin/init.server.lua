if not plugin then
	return
end

local RunService = game:GetService("RunService")

if RunService:IsRunning() then
	print('Don\'t run Freeway in play mode')
	return
end

local Freeway = script:FindFirstAncestor("Freeway")
local Packages = Freeway.Packages

local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)

local App = require(script.App)

local app = React.createElement(App, {
	plugin = plugin,
})

local tree = ReactRoblox.createRoot(Instance.new("Folder"))
tree:render(ReactRoblox.createPortal(app, game:GetService("CoreGui")))

print('plugin reloaded')
plugin.Unloading:Connect(function()
	tree:unmount()
end)
