const { contextBridge, ipcRenderer } = require('electron/renderer')

contextBridge.exposeInMainWorld('electronAPI', {
  installStudioPlugin: () => ipcRenderer.send('install-studio-plugin'), 
  installPhotoshopPlugin: () => ipcRenderer.send('install-photoshop-plugin')

})

