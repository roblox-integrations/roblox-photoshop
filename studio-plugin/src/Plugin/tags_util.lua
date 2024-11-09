


-- {'tag': 'prop'}
-- wiring persistance via tags
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local TAG_WIRED = 'wired'
local TAG_PREFIX = 'piece:'


local tags_util = {}

  


function tags_util:set_instance_wires(instance: Instance, wires: {})
    -- cleanup tags
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
    local counter = 0 
    for _, inst in CollectionService:GetTagged(TAG_WIRED) do
        for _, tag in inst:GetTags() do
            local replaced, count = string.gsub(tag, TAG_PREFIX, "")
            if count < 1  then
                print('skipping tag ' .. tag)
                continue
            end
            -- todo MI handle json parsing errors
            local property_wires = HttpService:JSONDecode(replaced) :: {}
            instance_wires[inst] = property_wires   

            counter = counter + 1
        end
    end

    print('found ' .. counter .. ' wired instances')
    return instance_wires

    
end

return tags_util