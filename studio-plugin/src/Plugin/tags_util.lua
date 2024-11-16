


-- {'tag': 'prop'}
-- wiring persistance via tags
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local TAG_WIRED = 'wired'
local TAG_PREFIX = 'piece:'


local tags_util = {}

function tags_util:get_instance_wires(instance: Instance)
    if not instance:HasTag(TAG_WIRED) then return {} end
    for _, tag in instance:GetTags() do
        local replaced, count = string.gsub(tag, TAG_PREFIX, "")
        if count < 1  then
            --print('skipping tag ' .. tag)
            continue
        end
        -- todo MI handle json parsing errors
        local property_wires = HttpService:JSONDecode(replaced) :: {}
        return property_wires
    end

end


function tags_util:shouldRebuildWirersStat(selectedInstances, instance) 
    local updateWirersState = false
    for _, selectedInstance in selectedInstances do
       if selectedInstance == instance then 
          updateWirersState = true 
          break
      end
    end
    return updateWirersState
end
function tags_util:wire_instance(instance: Instance, piece_id, property)
    local wires = self:get_instance_wires(instance)

    -- remove existing wire for property
    for w_piece_id, w_property in wires do
        if w_property == property then 
            wires[w_piece_id] = nil
            break
        end
    end
    wires[piece_id] = property
    self:set_instance_wires(instance, wires)
end

function tags_util:unwire_instance(instance: Instance, property)
    
    local wires = self:get_instance_wires(instance)
    print('set_instance_wires before!', wires)
    local resulting_wires = {}
    for piece_id, property in wires do
        if property == property then continue end
        resulting_wires[piece_id] = property
    end
    self:set_instance_wires(instance, resulting_wires)
end



function tags_util:set_instance_wires(instance: Instance, wires: {})
    -- cleanup tags

    print('set_instance_wires!', wires)
    instance:RemoveTag(TAG_WIRED)
    for _, tag in instance:GetTags() do
        local _, count = string.gsub(tag, TAG_PREFIX, "")
        if count < 1  then
            continue
        end
        instance:RemoveTag(tag)
    end

    -- re-setup tags
    local counter = 0;
    for _, _ in wires do
        counter = counter + 1
    end
    
    if counter == 0 then return
    end
     
    instance:AddTag(TAG_WIRED)
    local tagsJson = TAG_PREFIX .. HttpService:JSONEncode(wires)
    instance:AddTag(tagsJson)

end


function tags_util:ts_get_all_wired_in_dm(): {[Instance]: {string: string} } 
    local instance_wires = {}
    for _, inst in CollectionService:GetTagged(TAG_WIRED) do -- TODO MI: Filter invalid instance types
        instance_wires[inst] = tags_util:get_instance_wires(inst)
    end
    return instance_wires
end




function tags_util:table_size(tab) 
    local count = 0
    for _, _ in tab do
        count = count+1
    end
    return count
end


return tags_util