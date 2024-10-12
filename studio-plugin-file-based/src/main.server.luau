-- local AssetService = game:GetService("AssetService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TagSync = require(script.Parent.tagsync)
local ObjUtils = require(script.Parent.obj_utils)
local utl = require(script.Parent.pkg.utl)

type ImageData = {
    h: number,
    w: number,
    p: { number },
}


export type Piece = {
    id: string,
    role: string, -- "asset|editable"
    type: string, --  "image|mesh|meshtexturepack|pbrpack"
    filePath: string,
    fileHash: string,
    assetIds: {},
    updatedAt: number,
    deletedAt: number
}

print("sync plugin reloaded..." .. os.time())
local tb = plugin:CreateToolbar("Sync")
local btn = tb:CreateButton(".", "A Button", "rbxassetid://9087232887")

local plugin_enabled = true


type PiecesSyncState = {
    updatedAt: number,
    pieces: {[string]: Piece}
}


type SyncState = {
    sync_folder: Folder,
    images: { [number]: {
        id: number,
        inst: EditableImage,
    } },
    meshes: { [number]: {
        id: number,
        inst: EditableMesh,
    } },
}

local pieces_map = {}
local pieces_sync_state : PiecesSyncState = {
    updatedAt = -1,
}



function getPieces(): { [string]: Piece }
    print(`poll`)
    -- todo MI handle errors
    local res = HttpService:GetAsync("http://localhost:3000/api/pieces")
    local json = HttpService:JSONDecode(res)
    -- print(`fetched json updates:  {#json}`)
    local pieces = json :: { Piece }
    local tmp_pieces_map = {}
    for _, p in pieces do
        tmp_pieces_map[p.id] = p
    end

    return tmp_pieces_map
end




function start_polling()

    local function process_pieces(pieces: { [string]: Piece })
        pieces_map = pieces
        -- 2. cetch all wired instances
        local instanceWires = ts_get_all_wired_in_dm()
 
        -- 3. check if all wired pieces still exist
        for instance, wires in instanceWires do
            update_wired_instances(instance, wires)
        end
        for _, p in pieces_map do
            -- print('piece: ' .. p.filePath .. ', time diff: ' .. (pieces_sync_state.updatedAt - p.updatedAt))
        end
           


    end

    coroutine.wrap(function()
        print("starting polling")
        while plugin_enabled do
            local updates = getPieces()
            if #updates > 0 then
                print(`there were {#updates} updates`)
            end

            process_pieces(updates)

            wait(5)
        end
        print("polling ended")
    end)()
end

btn.Click:Connect(function()
    btn.Enabled = false
    btn.Enabled = true

    if plugin_enabled then
        print("disabling plugin")
        plugin_enabled = false
    else
        print("enabling plugin")
        plugin_enabled = true
        start_polling()
    end
end)






function update_wired_instances(instance: Instance, wires: {})
    print('instance name: ' .. instance.Name)

    for piece_id,_ in wires do
        local piece = pieces_map[piece_id]

        if piece == nil then
            print('remove a wire with piece_id: ' .. piece_id)
            wires[piece_id] = nil -- remove wire for missing piece
            continue
        elseif pieces_sync_state.updatedAt >= piece.updatedAt then -- recently updated, skip
            continue
        end

        -- image        
        if piece.type == 'image' then
            if piece.role == 'asset' then
                print('!!! Uncomment once assets persistance is there')
                -- instance[propertyName] = 'rbxassetid://' .. piece.assetIds[0]
            else 
                print('! Unsupported role ' .. piece.role .. ' for piece type: ' .. piece.type)
            end

            -- todo editable 
        else
            print('! Unsupported Piece type: ' .. piece.type)
        end
    end

    -- update tags
    ts_set_instance_wires(instance, wires)
end

-- wiring persistance via tags
local CollectionService = game:GetService("CollectionService")
local TAG_WIRED = 'wired'
local TAG_PREFIX = 'piece:'



function ts_set_instance_wires(instance: Instance, wires: {})
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


function ts_get_all_wired_in_dm(): {[Instance]: {string: string} } 
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