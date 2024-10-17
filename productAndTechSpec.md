# Images (and Mesh) workflows on Roblox
The goal is to enable effortless iteration on images and meshes on Roblox.


# Terms and high-level concepts
We use a filesystem as a source of images and meshes. Editors like Figma, Substance Painter, Blender, or Photoshop write files to the specific folder called Working Folder.  As long as the file within the hierarchy of the working folder, it will be monitored and available for real-time updates on Roblox. The Desktop application exposes the filesystem's contents via _http_, so Studio plugin can access it.

_TBD: unified mesh+texture workflow_


[studio] -> [desktop app]->[folder with files]<- [editors write to file: ps, figma, substance painter, etc]    

## Stack
Stack is a list of images or meshes(Pieces), that can be wired to a property of an Instance(s). Stack is empty when the underlying folder is empty. 

## Piece
Piece is a Stack item representing an image or a mesh on a filesystem. A Piece can be wired to one or more unique instance-property pairs, so when the underlying image or mesh file is updated, all wired properties are also updated. Unwired Piece does not affect the workspace when updating the underlying image or mesh files. 



# Main workflows

## File System
The Desktop app monitors a working folder on the filesystem for images and meshes (tbd: unified mesh+texture workflow and pbr texure pack workflow). The working folder can contain files and subfolders. 

## Studio-first
* I want to set images(or meshes) for objects in my workspace.
* I want to have control over which objects and properties are being set
* I want to be able to start iterating even with empty properties
* I want to do batch update images(meshes) references in my workspace
* I want to live update my images(meshes) during the play test * (nice to have atm)
  

## Editor-first
* I want to use the entities I operate with in the editor for iteration on Roblox. For example a PBR material, Mesh + Texuture Pack, A button with multiple states, a decal. 
* I want to export images from my editor and live update them in Roblox

# Desktop application

## Overview
The Desktop Application monitors the filesystem, manages the state of the Stack and Pieces, and provides access to Roblox Cloud APIs. Also, it's a distribution channel for Codename which is tracking latest releases and automatically updates Studio and any other Plugins that might be distributed along with Codename in the future. 

## Technical details
Windows and Mac Electron application. 

### Updates
Track updates to unwired Pieces and show alerts? 

### Piece Stucture

```js
const piece = {
  id: "uuid",
  fileHash: "abcdefg", // md5 of piece
  role: "asset|editable", // tbd: support EditableImage/EditableMesh where possible
  type: "image|mesh|meshtexturepack|pbrpack", // or tbd mesh+texture pack
  assetIds: [1, 2, 3, 4, 5, 6], // history of asset ids, the last one is the current
  updatedAt: timestamp,
  filePath: "artpiece.png",
  is_stub: false/true // needed when empty property being edited. We don't want to create an asset from the placeholder, so until the first rewrite of the file we don't save it as an asset
}
```



# Studio Plugin
## Overview
Studio plugin is responsible for mapping between Pieces and instance properties and performing images/meshes updates. The mappings are managed via Stack and Pieces UI, and updates are done by executing Commands from the Desktop Application. 

## Understanding what's wired to what.
### Via Stack/Piece
Stack can be sorted by Wired/Unwired first. Clicking a Piece brings up a complete list of it's wires with an option to unwire current properties and wire others compatible properties. 

### Via Selection
In Piece details, selected instances are rendered on top of Wired instances, with an option to wire all compatible properties.
The selected instances are grouped by type.  Wiring to a common property is a batch operation for the whole selection/group. 

In Stack, bubble up Pieces wired to selections and display "quick unwire X instnaces" next to piece? TBD



TBD Should we do bulk unwiring? E.g. have a quick action "unwire all selected" in the Stack?


## Technical details


### Studio Plugin Piece Wiring
At the time of wiring, create two tags, “piece” and “piece:$UUID:[prop1, prop2],” for each instance wired to a Piece. In this case, all wired instances can be looked up by “piece” tag and the actual Piece ID  can be read from a tag that starts with “piece:”, and prefix. 


### Studio Commands
```
SET propname to x X where assetId=Y
SET propname to X where selected
SET propname to X where tag = piece:uuid:property


SET propname = 67890 where notSelected
SET propname = 67890 where assetId = 12345 and selected
SET propname = 67890 where assetId = 12345 and notSelected
```
SET propname = 67890 where tag = piece:propname:uuid ???? до



## Instances with Texture Properties
https://github.com/roblox-integrations/roblox-photoshop/blob/main/studio-plugin/src/Plugin/TextureProperties.lua


### Update Logic
* Listen to new wires tags to to appear
* Take into account per-instance update timestamps; consider dropping the global update timestamp for now


Open items: 
EditableMeshes/Images
Packages versions?
