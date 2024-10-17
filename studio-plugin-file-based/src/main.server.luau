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
    uploads: {
        {
            assetId: string,
            decalId: string,
            fileHash: string,
            operationId: string
        }
    },
    updatedAt: number,
    uploadedAt: number, 
    deletedAt: number
}

print("sync plugin reloaded..." .. os.time())
local tb = plugin:CreateToolbar("Sync")
local btn = tb:CreateButton(".", "A Button", "rbxassetid://9087232887")

local plugin_enabled = false


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
    updatedAt = -1, -- MI: Product opinion: update all wired instances on startup to the most recent pieces values
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
        -- 1. fetch all wired instances
        local instanceWires = ts_get_all_wired_in_dm()
 
        -- 2. update wired instance when needed and cleanup wires for missing pieces
        local maxTimestamp = -1
        for instance, wires in instanceWires do
            local ts = update_wired_instances(instance, wires)
            print('ts ' .. ts .. ', maxTs ' .. maxTimestamp)
            if ts > maxTimestamp then maxTimestamp = ts end
        end

        -- -- 3. update the timestamp
        -- pieces_sync_state.updatedAt = os.time()
        -- for _, p in pieces_map do
        --     -- print('piece: ' .. p.filePath .. ', time diff: ' .. (pieces_sync_state.updatedAt - p.updatedAt))
        -- end
           


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




function get_current_asset_id(piece: Piece): string
    for _, upload in piece.uploads do
        if piece.fileHash ~= upload.fileHash then continue end
        return upload.assetId
    end
    return nil
end

function get_piece_update_time(piece: Piece): number 
    print('get_piece_update_time: ' .. piece.id)
    local uploadedAt = nil 
    if (piece.uploadedAt ~= nil) then uploadedAt = piece.uploadedAt else uploadedAt = piece.updatedAt end
    print('updatedAt: ' .. piece.updatedAt .. ', uploadedAt: ' .. uploadedAt)
    if(piece.updatedAt > uploadedAt) 
        then return piece.updatedAt
        else return uploadedAt
    end

end

function update_wired_instances(instance: Instance, wires: {}): number
    print('instance name: ' .. instance.Name)
    local maxTimestamp = -1;
    for piece_id, propertyName in wires do 
        -- 1. check if the piece still exists and was recently updated
        local piece = pieces_map[piece_id]
        if piece == nil then
            print('remove a wire with non-existent piece_id: ' .. piece_id)
            wires[piece_id] = nil -- remove wire for missing piece
            continue
        end
        -- 2. Update wired instance according to the piece type
        -- 2.1 image        
        if piece.type == 'image' then
            if piece.role == 'asset' then
                print('!!! Uncomment once assets persistance is there')
                local assetId = get_current_asset_id(piece)
                if(assetId == nil) then continue end
                local assetUrl = 'rbxassetid://' .. assetId
                if(instance[propertyName] ~= assetUrl) then -- only update the property if changed
                    instance[propertyName] = assetUrl
                end
            else 
                print('! Unsupported role ' .. piece.role .. ' for piece type: ' .. piece.type)
            end

            -- todo editable 
        else
            print('! Unsupported Piece type: ' .. piece.type)
        end
    end

    -- 4. persist current wiring config to tags
    ts_set_instance_wires(instance, wires)

    return maxTimestamp
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