--!strict
local Packages = script:FindFirstAncestor("PhotoshopIntegration").Packages
local React = require(Packages.React)
local Cryo = require(Packages.Cryo)

local e = React.createElement
local Selection = game:GetService("Selection")
local CollectionService = game:GetService("CollectionService")

local PieceDetailsComponent = React.Component:extend("PieceDetailsComponent")
local WireableProperties = require(script.Parent.WireableProperties)

local InstanceWirerComponent = require(script.Parent.InstanceWirerComponent)
local PluginEnum = require(script.Parent.Enum)
local t_u = require(script.Parent.tags_util)


function PieceDetailsComponent:didMount()
	-- print('PieceDetailsComponent:didMount', self.state.selectedWirersModel)

end

function PieceDetailsComponent:willUnmount()
	--  print('PieceDetailsComponent:willUnmount')
	 
	--self:onClickDisconnectButton()
end

function PieceDetailsComponent:init()
	self:updateSelectedWirersState()
	self.onSelectionChanged = Selection.SelectionChanged:Connect(function()
		self:updateSelectedWirersState()
	end)
	self:updateDMWirerState()

	CollectionService:GetInstanceAddedSignal('wired'):Connect(function(instance)
		local updateWirersState = t_u:shouldRebuildWirersStat(Selection:Get(), instance)
		if updateWirersState then self:updateSelectedWirersState() end
		self:updateDMWirerState()


    end)

    CollectionService:GetInstanceRemovedSignal('wired'):Connect(function(instance)
		local updateWirersState = t_u:shouldRebuildWirersStat(Selection:Get(), instance)
		if updateWirersState then self:updateSelectedWirersState() end

		self:updateDMWirerState()
	end)


end

function PieceDetailsComponent:buildWirersModel(instances, pieceType) 
	local result = {}
	for _, instance in instances do
		local wirerModelByType = result[instance.ClassName]
		if wirerModelByType == nil then 
			local properties = nil
			if (pieceType == 'image') then
				properties = WireableProperties['texture'][instance.ClassName]
			elseif (pieceType == 'mesh') then 
				properties = WireableProperties['mesh'][instance.ClassName]
			end

			--if properties == nil then properties = {} end
			if properties == nil then continue end -- this instance can't be wired
			wirerModelByType = {
				instances = {},
				properties = properties
			} 
			result[instance.ClassName] = wirerModelByType
		end
		table.insert(wirerModelByType.instances, instance)
	end


	for className, wirerModel in result do
		local count = #wirerModel.instances
		if count > 1 
			then wirerModel.header = count .. ' ' .. className  .. 's' 
			else wirerModel.header = wirerModel.instances[1].Name
		end


		-- per-property wiring state -- wired to current, not wired, etc
		local properties_wire_state = {}
		for j, instance in wirerModel.instances do
			local instanceWires = t_u:get_instance_wires(instance)
			for piece_id, property in instanceWires do
				local prop_wire_st = properties_wire_state[property]
				if prop_wire_st == nil then prop_wire_st = {} end
				prop_wire_st[piece_id] = true
				properties_wire_state[property] = prop_wire_st
			end
		end


		for _, property in wirerModel.properties do -- add empty for properties that are not wired
			if properties_wire_state[property] == nil then properties_wire_state[property]  = {} end
		end

		wirerModel.combinedPropertyState = {}
		for property, wire_state in properties_wire_state do
			local count = t_u:table_size(wire_state)
			-- print('property->wireState', property, wire_state, count)
			
			if count == 0 then wirerModel.combinedPropertyState[property] = PluginEnum.WIRED_NOT continue  end
			if count > 1 then wirerModel.combinedPropertyState[property] = PluginEnum.WIRED_MIXED continue end
			
			if wire_state[self.props.piece.id] then wirerModel.combinedPropertyState[property] = PluginEnum.WIRED_ALL_CURRENT
			else 
				wirerModel.combinedPropertyState[property] = PluginEnum.WIRED_ALL_OTHER 
				wirerModel.combinedPropertyState['piece_id_' .. property] = Cryo.Dictionary.keys(wire_state)[1]
			end
		end	
		-- print('!!wireState', wirerModel.combinedPropertyState)
	end
	return result
end

function PieceDetailsComponent:updateDMWirerState()
	local instancesToWires = t_u.ts_get_all_wired_in_dm()
	local instancesWiredToCurrentPiece = {}
	for instance, wires in instancesToWires do
		if wires[self.props.piece.id] ~= nil then table.insert(instancesWiredToCurrentPiece, instance) end
	end
	local result = self:buildWirersModel(instancesWiredToCurrentPiece, self.props.piece.type)
	self:setState({dmWirersModel = result})
end


function PieceDetailsComponent:updateSelectedWirersState()
	local selection = Selection:Get()
	local result = self:buildWirersModel(selection, self.props.piece.type)
	self:setState({selectedWirersModel = result})
end

function PieceDetailsComponent.getDerivedStateFromProps(props)
	return props
end

function PieceDetailsComponent:buildInstanceWirerComponent(i, wirerModel, showSelectButton)
	return e(
		InstanceWirerComponent, 
		{
			index = i,
			instances = wirerModel.instances, 
			properties = wirerModel.properties,
			header = wirerModel.header,
			fetcher = self.props.fetcher,
			piece = self.props.piece,
			showSelectButton = showSelectButton,
			combinedPropertyState = wirerModel.combinedPropertyState,

			onClick = function(instances, propertyName)
				for _, instance in instances do
					-- print('wire instance', instance, self.props.piece.id, propertyName)
					t_u:wire_instance(instance, self.props.piece.id, propertyName)
					self.props.fetcher:update_instance_if_needed(instance)
				end
			end, 
			onUwireClick = function(instances, propertyName) 
				for _, instance in instances do
					-- print('unwire all')
					t_u:unwire_instance(instance, propertyName)
				end
				
			end
		})
end

function PieceDetailsComponent:render()
	local state = self.state

	local selectionInstanceWirers = {}
	local dmInstanceWirers = {}


	local i = 3 
	local hasSelectionToWire = false
	for _, wirerModel in state.selectedWirersModel do 
		-- print('redo wirers')
		local newInstanceWirer = self:buildInstanceWirerComponent(i, wirerModel, false)
		selectionInstanceWirers['selectionInstanceWirer' .. i] = newInstanceWirer
		hasSelectionToWire = true
		i = i + 1
	end

	local dmWirersLabelIndex = i + 1
	local hasDMWires = false
	i = i + 2 
	for _, wirerModel in state.dmWirersModel do 
		--print('redo DM wirers')
		local newInstanceWirer = self:buildInstanceWirerComponent(i, wirerModel, true)
		dmInstanceWirers['selectionInstanceWirer' .. i] = newInstanceWirer
		local hasDMWires = true
		i = i + 1
	end



	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = self.props.index, 
	}, {
		Cryo.Dictionary.join({
			uiListLayout = e("UIListLayout", {
				Padding = UDim.new(0, 10),
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalFlex = Enum.UIFlexAlignment.Fill

			}),
		}, self:renderPreviewAndName(1), 
		{
				selectedHeader = hasSelectionToWire and  e("TextLabel", {
				Size = UDim2.new(0, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 2,
				Text = "Selected:",
				Font = Enum.Font.BuilderSansBold,
				TextSize = PluginEnum.FontSizeHeader,
				TextColor3 = PluginEnum.ColorTextPrimary,
				BackgroundColor3 = PluginEnum.ColorBackground,
				BorderSizePixel = 0,
				TextXAlignment = Enum.TextXAlignment.Center,
				})
		},
		selectionInstanceWirers, 
		{
			dmWirerHeader = hasDMWires and e("TextLabel", {
			Size = UDim2.new(0, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			LayoutOrder = dmWirersLabelIndex,
			Text = "Wired to:",
			Font = Enum.Font.BuilderSansBold,
			TextSize = PluginEnum.FontSizeHeader,
			TextColor3 = PluginEnum.ColorTextPrimary,
			BackgroundColor3 = PluginEnum.ColorBackground,
			BorderSizePixel = 0,
			TextXAlignment = Enum.TextXAlignment.Center,
			})
		},
		dmInstanceWirers		
		)
	})
end


function PieceDetailsComponent:renderPreviewAndName(order: number)
	-- print('render piece details component')

	local content = self.props.fetcher:fetch(self.props.piece)
	return {
		e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			LayoutOrder = self.props.index, 
		}, {
		uiListLayoutTop = e("UIListLayout", {
			Padding = UDim.new(0, PluginEnum.PaddingHorizontal),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		texturePreviewTop = content ~= nil and e("ImageLabel", {
			Size = UDim2.new(0, PluginEnum.DetailsSize, 0, PluginEnum.DetailsSize),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = PluginEnum.ColorBackground,
			BorderSizePixel = 0,
			ImageContent = content,
		}),
		-- texturePreviewTop = self.state.editableImage ~= nil and e("ImageLabel", {
		-- 	Size = UDim2.new(0, PluginEnum.PreviewSize, 0, PluginEnum.PreviewSize),
		-- 	AutomaticSize = Enum.AutomaticSize.XY,
		-- 	BackgroundColor3 = PluginEnum.ColorBackground,
		-- 	BorderSizePixel = 0,
		-- 	Image =  'http://www.roblox.com/asset/?id=699259085',
		-- }),

		nameTop = e('TextLabel', {
			Size = UDim2.new(0, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			Text = self.props.piece.name,
			Font = Enum.Font.BuilderSansBold,
			TextSize = PluginEnum.FontSizeTextPrimary,
			TextColor3 = PluginEnum.ColorTextPrimary,
			BackgroundColor3 = PluginEnum.ColorBackground,
			BorderSizePixel = 0,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 1
		})
	})
}
end
return PieceDetailsComponent
