export type ImageType = "AssetId" | "BMP"

export type ProductInfo = {
	Name: string,
	Description: string,
	Creator: {
		CreatorType: string,
		Name: string,
		Id: number,
	},
}

-- Local session information
export type Session = {
	sessionId: string,
	source: Instance,
	propertyName: string,
	shownImage: string,
	imageType: ImageType,
	productInfo: ProductInfo,
	connectedSession: SessionPacket?,
}

-- Session data sent from the server
export type SessionPacket = {
	sessionId: string,
	lastUpdated: string,
	asset: string,
	outAsset: {
		assetId: string,
	},
}

return nil
