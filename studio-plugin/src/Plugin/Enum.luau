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


	PreviewSize = 65,
}
return enum