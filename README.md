# About 
The first integration of [Roblox Integration Hub](https://github.com/roblox-integrations/roblox-photoshop?tab=readme-ov-file#whats-roblox-integration-hub), which connects Adobe Photoshop to Roblox Studio for seamless image editing. Integration with Blender is coming next. 

# How it works 
There are two main scenarios: 
1. #### Save any Photoshop document as Roblox image asset and copy it's AssetID![new file upload](https://github.com/roblox-integrations/roblox-photoshop/assets/3534732/98dfb785-8605-4bc0-88d7-951657669bef)

2. #### Open any image in your Roblox place for editing and hot-swap the AssetId directly in Studio![edit-workflow-short](https://github.com/roblox-integrations/roblox-photoshop/assets/3534732/3587c100-65ed-47a0-baa7-246092f9bd06)



# Installation 
Install the [latest release of  Roblox Integration Hub application]([http://example.com](https://github.com/roblox-integrations/roblox-photoshop/releases/latest)), run it and extract and install Photoshop and Studio plugins. 

_Mac users:_ run ``` xattr -c ~/Downloads/RobloxIntegrationsHub.app ``` in your terminal to fix the "RobloxIntegrationsHub” is damaged and can’t be opened." error.   

### Photoshop Plugin Installation 
Click 'Download the Photoshop plugin' in the [Roblox Integration Hub]([http://example.com](https://github.com/roblox-integrations/roblox-photoshop/releases/latest)) app, and then double-click the saved plugin file. The plugin is found in the main menu's Plugins->Roblox Photoshop Plugin. 
To upload assets, you'll need to provide an Open Cloud API Key. 
1. In [Creator Dashboad](https://create.roblox.com/dashboard/credentials?activeTab=ApiKeysTab) click Create API Key, name it 'Photoshop Plugin', in 'Access Permission' select API System Assets, add both 'read' and 'write' permissions and use 0.0.0.0/0 as IP subnet, then generate and copy the API key. ![add api key](https://github.com/roblox-integrations/roblox-photoshop/assets/3534732/6bca3e51-ea31-40b3-8ca2-de75fc9f8bab).
2. Get your user ID. Go to [roblox.com](htts://roblox.com), click on your profile, and copy the numeric value from the URL in the browser: ![user id](https://github.com/roblox-integrations/roblox-photoshop/assets/3534732/648b7a07-2637-474b-92c9-662efb0f399d)





### Roblox Studio Plugin Installation 
Click 'Download the Studio plugin' in the Roblox Integration Hub app. Then, in the Studio ribbon, click the 'Plugins' tab, click on the 'Plugins Folder' button, and double-click the plugin file there(if you have an older version, please replace it). Then restart Studio, and you can find the Photoshop plugin in the Plugins tab in the Ribbon.
![Open Plugins Folder](https://github.com/roblox-integrations/roblox-photoshop/assets/3534732/6425aef4-4c64-4e1f-a2e9-2ba1aed29be5)

# What's Roblox Integration Hub?

[Roblox Integration Hub](https://github.com/roblox-integrations/roblox-photoshop/releases/latest) is a desktop app for Windows and Mac that allows Roblox Studio plugins to connect to other applications by exposing a local web server. It's free from the sandbox limitations of Studio(or third-party applications) plugins, which enables complex integrations that might require filesystem access, running native utilities, and so on.

It also tracks new integration releases and could be a great way to discover better creative workflows for Roblox.  

Today, Roblox Integration Hub supports **Photoshop**, and it can be extended with other tools like Blender, Figma, FMOD Studio and more! 

# Contributions
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
For feature requests and bug reports, please create an issue. 
Also, please leave a star on GitHub, it helps a lot!

# License
MIT

