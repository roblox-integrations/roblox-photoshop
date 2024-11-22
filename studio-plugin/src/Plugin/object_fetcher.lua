
local HttpService = game:GetService("HttpService")
local AssetService = game:GetService("AssetService")
local Packages = script:FindFirstAncestor("PhotoshopIntegration").Packages
local CollectionService = game:GetService("CollectionService")

local t_u = require(script.Parent.tags_util)

local base64 = require(Packages.base64)

local POLL_RATE = 1 -- seconds

local BASE_URL = 'http://localhost:3000'

local object_fetcher = {
    cache = {},
    pieces = {}, 
    pieces_map = {}, 
    piece_is_wired = {}
}

export type Piece = {
    id: string,
    role: string, -- "asset|editable"
    type: string, --  "image|mesh|meshtexturepack|pbrpack",
    name: string,
    dir: string,
    hash: string,
    uploads: {
        {
            assetId: string,
            decalId: string,
            hash: string,
            operationId: string
        }
    },
    updatedAt: number,
    uploadedAt: number, 
    deletedAt: number
}

type PiecesSyncState = {
    updatedAt: number,
    pieces: {[string]: Piece}
}

local pieces_map = {}
local pieces_sync_state : PiecesSyncState = {
    updatedAt = -1, -- MI: Product opinion: update all wired instances on startup to the most recent pieces values
}



-- CollectionService:GetInstanceAddedSignal('wired'):Connect(function(instance)
--     update_instance_if_needed(instance)    
-- end)

-- CollectionService:GetInstanceRemovedSignal('wired'):Connect(function(instance)
--     update_instance_if_needed(instance)
-- end)

function object_fetcher:update_instance_if_needed(instance) 
    local wires = t_u:get_instance_wires(instance)
    update_wired_instances(instance, wires)
end 

coroutine.wrap(function()

    while true do
        local function fetchPiecesFromNetwork() 
            local res = HttpService:GetAsync(BASE_URL .. '/api/pieces')
            local json = HttpService:JSONDecode(res)
            local pieces = json :: { Piece }
            if pieces == nil then pieces = {} end
            object_fetcher.pieces = pieces

            local tmp_pieces_map = {}
            for _, p in pieces do
                tmp_pieces_map[p.id] = p
            end
            object_fetcher.pieces_map = tmp_pieces_map
            pieces_map = tmp_pieces_map

            local function process_pieces(pieces: { [string]: Piece })
                -- 1. fetch all wired instances
                local instanceWires = t_u.ts_get_all_wired_in_dm()
                local piece_is_wired = {}
                for instance, wires in instanceWires do
                    for piece_id, _ in wires do
                        piece_is_wired[piece_id] = true
                    end 
                end
                object_fetcher.piece_is_wired = piece_is_wired

                -- 2. update wired instance when needed and cleanup wires for missing pieces
                local maxTimestamp = -1
                for instance, wires in instanceWires do
                    local ts = update_wired_instances(instance, wires)
                    --print('ts ' .. ts .. ', maxTs ' .. maxTimestamp)
                    if ts > maxTimestamp then maxTimestamp = ts end
                end
            
                -- -- 3. update the timestamp
                -- pieces_sync_state.updatedAt = os.time()
                -- for _, p in pieces_map do
                --     -- print('piece: ' .. p.name .. ', time diff: ' .. (pieces_sync_state.updatedAt - p.updatedAt))
                -- end
        end
        process_pieces(tmp_pieces_map)
    end
    local status, err = pcall(fetchPiecesFromNetwork)
    if not status then
        -- MI bubble the error up, display in UI
        print('error fetching pieces', err)
    end
    task.wait(POLL_RATE)
    end

end)()


function object_fetcher:fetch(piece)
    local obj = self.cache[piece.id]
    
--    print('fetch piece with id and hash: ', piece.id, piece.hash)

    if obj ~= nil and obj.hash == piece.hash then 
        --print('returning cached version')
        return obj.object 
    end

     local function fetchFromNetwork() 
        local url = BASE_URL .. '/api/pieces/' .. piece.id .. '/raw'
        print('URL: ' .. url)
        local res = HttpService:GetAsync(url)
        local json = HttpService:JSONDecode(res)
    
        
        if piece.type == 'image' then
            local width = json['width']
            local height = json['height']
            local b64string = json['bitmap']
            local options = { Size = Vector2.new(width, height) }
            local editableImage = AssetService:CreateEditableImage(options)
            local decodedData = base64.decode(buffer.fromstring(b64string))
            editableImage:WritePixelsBuffer(Vector2.zero, editableImage.Size, decodedData)
            local content = Content.fromObject(editableImage)
            self.cache[piece.id] = {object = content, hash = piece.hash}
            return content
        end
        if piece.type == 'mesh' then
            local b64string = json['base64']
            local decodedData = base64.decode(buffer.fromstring(b64string))
            local meshString = buffer.tostring(decodedData)
            print('mesh parsed')
        end

    
    end    

    local status, err =  pcall(fetchFromNetwork) 
    if not status then 
        -- TODO MI desktop app is off? Bubble up to UI
        print('error fetching asset from network:', err)
    end

    print('!piece type not implemented:', piece.type)

end







function get_current_asset_id(piece: Piece): string
    for _, upload in piece.uploads do
        if piece.hash ~= upload.hash then continue end
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
    local needsTagsUpdate = false
    local maxTimestamp = -1;
    for piece_id, propertyName in wires do 
        -- 1. check if the piece still exists and was recently updated
        local piece = pieces_map[piece_id]
        if piece == nil then
            print('remove a wire with non-existent piece_id: ' .. piece_id)
            wires[piece_id] = nil -- remove wire for missing piece
            needsTagsUpdate = true
            continue
        end
        -- 2. Update wired instance according to the piece type
        -- 2.1 image        
        if piece.type == 'image' then
            if piece.role == 'asset' then
                local assetId = get_current_asset_id(piece)
                if assetId == nil then 
                    --print('cant find asset id for piece')
                    continue 
                end
                local assetUrl = 'rbxassetid://' .. assetId
                if(instance[propertyName] ~= assetUrl) then -- only update the property if changed
                    --print('updating ', propertyName, ' to ', assetUrl)
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
    if needsTagsUpdate then 
        print('tags need update!')
        t_u:set_instance_wires(instance, wires) 
    end

    return maxTimestamp
end







return object_fetcher