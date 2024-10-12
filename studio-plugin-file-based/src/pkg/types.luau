export type Piece = {
    id: string,
    role: string,
    type: string, -- todo enum?
    filePath: string,
    fileHash: string,
    assetIds: {},
    updatedAt: number,
    deletedAt: number
}




export type V3 = {
    x: number,
    y: number,
    z: number
}
export type V2 = {
    x: number,
    y: number
}


return {}
