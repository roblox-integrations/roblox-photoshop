type TexturePropertyData = {
    ClassName: string,
    Properties: {string},
}

local textureProperties: {TexturePropertyData} = {
    AdGui = {"TextureID"},
    BackpackItem = {"TextureId"},
    Beam = {"Texture"},
    ClickDetector = {"CursorIcon"},
    Decal = {"Texture"},
    DragDetector = {"ActivatedCursorIcon"},
    FileMesh = {"TextureId"},
    FloorWire = {"Texture"},
    ImageButton = {"Image", "HoverImage", "PressedImage"},
    ImageHandleAdornment = {"Image"},
    ImageLabel = {"Image"},
    MaterialVariant = {"ColorMap", "MetalnessMap", "NormalMap", "RoughnessMap"},
    MeshPart = {"TextureID"},
    Mouse = {"Icon"},
    Pants = {"PantsTemplate"},
    ParticleEmitter = {"Texture"},
    PluginToolbarButton = {"Icon"},
    ScreenshotHud = {"CameraButtonIcon"},
    ScrollingFrame = {"MidImage", "TopImage", "BottomImage"},
    Shirt = {"ShirtTemplate"},
    ShirtGraphic = {"Graphic"},
    Sky = {"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp", "SunTextureId", "MoonTextureId"},
    SurfaceAppearance = {"ColorMap", "MetalnessMap", "NormalMap", "RoughnessMap"},
    TerrainDetail = {"ColorMap", "MetalnessMap", "NormalMap", "RoughnessMap"},
    Trail = {"Texture"},
    UserInputService = {"MouseIcon"},
}

return textureProperties