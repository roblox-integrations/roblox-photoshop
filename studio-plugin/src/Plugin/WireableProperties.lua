type PropertyData = {
    ClassName: string,
    Properties: {string},
}

local wireableProperties: {string: {PropertyData}}  = {
    texture = {
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
        Texture = {"Texture"},
        Trail = {"Texture"},
        UserInputService = {"MouseIcon"},
    }, 
    mesh = {
        MeshPart = {"MeshId"}
    }

}




return wireableProperties