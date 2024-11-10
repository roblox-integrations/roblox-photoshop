
local HttpService = game:GetService("HttpService")
local AssetService = game:GetService("AssetService")
local Packages = script:FindFirstAncestor("PhotoshopIntegration").Packages
local base64 = require(Packages.base64)
local BASE_URL = 'http://localhost:3000'
local object_fetcher = {
    cache = {},
    pieces = {}
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




coroutine.wrap(function()
    while true do
        local res = HttpService:GetAsync(BASE_URL .. '/api/pieces')
        local json = HttpService:JSONDecode(res)
        local pieces = json :: { Piece }
        if pieces == nil then pieces = {} end
        object_fetcher.pieces = pieces
         
        print('reset pieces', #object_fetcher.pieces)
        wait(1)
    end

end)()


function object_fetcher:fetch(piece)
    local obj = self.cache[piece.id]
    
    print('fetch piece with id and hash: ', piece.id, piece.fileHash)

    if obj ~= nil and obj.hash == piece.fileHash then 
        print('returning cached version')
        return obj.object 
    end
    
    if piece.type ~= 'image' then
        print('not an image, IMPLEMENT ME')
        return 
    end

    local url = BASE_URL .. '/api/pieces/' .. piece.id .. '/raw'
    print('URL: ' .. url)
    local res = HttpService:GetAsync(url)
    local json = HttpService:JSONDecode(res)
    local width = json['width']
    local height = json['height']
    local b64string = json['bitmap']
    local options = { Size = Vector2.new(width, height) }
    local editableImage = AssetService:CreateEditableImage(options)
    
    
    local decodedData = base64.decode(buffer.fromstring(b64string))
    
    editableImage:WritePixelsBuffer(Vector2.zero, editableImage.Size, decodedData)
    local content = Content.fromObject(editableImage)
    self.cache[piece.id] = {object = content, hash = piece.fileHash}
    return content
end


return object_fetcher