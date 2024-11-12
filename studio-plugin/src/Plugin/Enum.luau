local theme = settings().Studio.Theme





local enum = {
	FontSizeTextPrimary = 15,
	FontSizeTextSecondary = 13,
	FontSizeHeader = 20,
	FontSizeNavigationButton = 24,


	PaddingHorizontal = 20,
	PaddingVertical = 0, 


	ColorBackground = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground), 

	ColorTextPrimary =  theme:GetColor(Enum.StudioStyleGuideColor.DialogButtonText), 
	ColorTextSecondary = theme:GetColor(Enum.StudioStyleGuideColor.DialogButtonText),
	
	ColorButtonNavigationText = theme:GetColor(Enum.StudioStyleGuideColor.DialogButtonText),
	ColorButtonNavigationBackground = theme:GetColor(Enum.StudioStyleGuideColor.Light),

	ColorButtonSecondaryActionText = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
	ColorButtonSecondaryActionBackground = Color3.fromRGB(200, 200, 0),

	
	PreviewSize = 65,



	WIRED_NOT = 0,
	WIRED_MIXED = 1,
	WIRED_ALL_CURRENT = 2,
	WIRED_ALL_OTHER = 3

}
return enum