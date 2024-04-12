type TexturePropertyData = {
    ClassName: string,
    Properties: {string},
}

local textureProperties: {TexturePropertyData} = {
    {ClassName = "AdGui", Properties = {"TextureID"}},
    {ClassName = "BackpackItem", Properties = {"TextureId"}},
    {ClassName = "Beam", Properties = {"Texture"}},
    {ClassName = "ClickDetector", Properties = {"CursorIcon"}},
    {ClassName = "Decal", Properties = {"Texture"}},
    {ClassName = "DragDetector", Properties = {"ActivatedCursorIcon"}},
    {ClassName = "FileMesh", Properties = {"TextureId"}},
    {ClassName = "FloorWire", Properties = {"Texture"}},
    {ClassName = "ImageButton", Properties = {"Image", "HoverImage", "PressedImage"}},
    {ClassName = "ImageHandleAdornment", Properties = {"Image"}},
    {ClassName = "ImageLabel", Properties = {"Image"}},
    {ClassName = "MaterialVariant", Properties = {"ColorMap", "MetalnessMap", "NormalMap", "RoughnessMap"}},
    {ClassName = "MeshPart", Properties = {"TextureID"}},
    {ClassName = "Mouse", Properties = {"Icon"}},
    {ClassName = "Pants", Properties = {"PantsTemplate"}},
    {ClassName = "ParticleEmitter", Properties = {"Texture"}},
    {ClassName = "PluginToolbarButton", Properties = {"Icon"}},
    {ClassName = "ScreenshotHud", Properties = {"CameraButtonIcon"}},
    {ClassName = "ScrollingFrame", Properties = {"MidImage", "TopImage", "BottomImage"}},
    {ClassName = "Shirt", Properties = {"ShirtTemplate"}},
    {ClassName = "ShirtGraphic", Properties = {"Graphic"}},
    {ClassName = "Sky", Properties = {"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp", "SunTextureId", "MoonTextureId"}},
    {ClassName = "SurfaceAppearance", Properties = {"ColorMap", "MetalnessMap", "NormalMap", "RoughnessMap"}},
    {ClassName = "TerrainDetail", Properties = {"ColorMap", "MetalnessMap", "NormalMap", "RoughnessMap"}},
    {ClassName = "Trail", Properties = {"Texture"}},
    {ClassName = "UserInputService", Properties = {"MouseIcon"}},
}

return textureProperties