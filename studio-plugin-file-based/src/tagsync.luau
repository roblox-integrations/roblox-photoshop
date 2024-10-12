--[[

idea: synced images have IDs, any instance with a tag matching the ID will have a clone of the image replicated underneath it

]]

local CollectionService = game:GetService("CollectionService")

local TAG_PREFIX = "sync:"

local ts = {}

local registred_ids: { [number]: boolean } = {}

function ts.make_tag(id: number): string
    return TAG_PREFIX .. tostring(id)
end

function remove_child_insts(inst: Instance, class: string)
    local ei_child = inst:FindFirstChildOfClass(class)
    while ei_child ~= nil do
        ei_child:Destroy()
        ei_child = inst:FindFirstChildOfClass(class)
    end
end
function update_child_inst(p: Instance, inst: Instance, type: string)
    local class = nil
    if type == "png" then
        class = "EditableImage"
    elseif type == "obj" then
        class = "EditableMesh"
    else
        print(`type {type} not supported`)
        return
    end

    remove_child_insts(p, class)
    local i = inst:Clone()
    i.Parent = p
end

function get_source_inst(id: number): Instance?
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local sync_folder = ReplicatedStorage.SyncFolder :: Folder
    for _, c in sync_folder:GetChildren() do
        if c:GetAttribute("sync_id") == id then
            return c
        end
    end
    return nil
end

function register_id(id: number, type: string)
    registred_ids[id] = true
    local tag = ts.make_tag(id)
    CollectionService:GetInstanceAddedSignal(tag):Connect(function(inst)
        local src_inst = get_source_inst(id)
        if src_inst == nil then
            print(`id[ {id} ]: aborting update, no image found for id`)
        end
        update_child_inst(inst, src_inst, type)
    end)
end

function ts.update_id(id: number, type: string)
    if not registred_ids[id] then
        register_id(id, type)
    end

    local tag = ts.make_tag(id)
    local img = get_source_inst(id)
    if img == nil then
        print(`id[ {id} ]: aborting update, no image found for id`)
    end
    for _, inst in CollectionService:GetTagged(tag) do
        update_child_inst(inst, img, type)
    end
end

return ts
