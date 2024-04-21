
local CoreGui = game:GetService("CoreGui")

export type SharedToolbarSettings = {
	ButtonName: string,
	ButtonIcon: string,
	ButtonTooltip: string,
	ToolbarName: string,
	CombinerName: string,
	ClickedFn: () -> (),
	Button: PluginToolbarButton?,
}

return function(plugin: Plugin, set: SharedToolbarSettings)
	local combiner = CoreGui:FindFirstChild(set.CombinerName)
	if not combiner then
		combiner = Instance.new("ObjectValue")
		combiner.Name = set.CombinerName
		combiner.Parent = CoreGui
	end
	local owner = combiner:FindFirstChild("Owner")
	if not owner then
		owner = Instance.new("ObjectValue")
		owner.Name = "Owner"
		owner.Parent = combiner
	end

	local buttonCn;
	local function createButton(toolbar: PluginToolbar)
		if buttonCn then
			buttonCn:Disconnect()
		end
		local buttonRef = combiner:FindFirstChild(set.ButtonName)
		if not buttonRef then
			buttonRef = Instance.new("ObjectValue")
			buttonRef.Name = set.ButtonName
			buttonRef.Value = toolbar:CreateButton(set.ButtonName, set.ButtonTooltip, set.ButtonIcon)
			buttonRef.Value.Name = plugin.Name .. "_" .. set.ButtonName
			buttonRef.Parent = combiner
		end
		buttonCn = buttonRef.Value.Click:Connect(set.ClickedFn)
		set.Button = buttonRef.Value
	end

	-- Initial toolbar handling... create or use
	do
		local toolbar = combiner.Value
		if not toolbar then
			toolbar = plugin:CreateToolbar(set.ToolbarName)
			combiner.Value = toolbar
			owner.Value = plugin
		end
		createButton(toolbar)
	end

	-- Handle unloading plugins
	local ownerChangedConnection = owner:GetPropertyChangedSignal("Value"):Connect(function()
		task.delay(0.5, function()
			if not owner.Value then
				local toolbar = plugin:CreateToolbar(set.ToolbarName)
				toolbar.Name = plugin.Name .. "_Toolbar"
				combiner.Value = toolbar
				owner.Value = plugin
			elseif combiner.Value then
				createButton(combiner.Value)
			end
		end)
	end)

	-- Handle our own unloading
	local unloadConnection;
	unloadConnection = plugin.Unloading:Connect(function()
		unloadConnection:Disconnect()
		ownerChangedConnection:Disconnect()
		if buttonCn then
			buttonCn:Disconnect()
		end
		if owner.Value == plugin then
			-- Clear the button refs
			for _, ch in combiner:GetChildren() do
				if ch ~= owner then
					ch:Destroy()
				end
			end
			combiner.Value = nil
			owner.Value = nil
		end
	end)
end
