
const { app, BrowserWindow,ipcMain, dialog } = require('electron')
const server = require('./app');
const shell = require( "electron" ).shell
const path = require('node:path')
const fs = require('fs');

// const { updateElectronApp } = require('update-electron-app');
// updateElectronApp(); 


const version = app.getVersion()

const createWindow = () => {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    icon: '/images/appIcon.png',
    title: "Roblox Integration Hub", 
    webPreferences: {
      preload: path.join(__dirname, 'preload.js')
    }
  })
  win.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: 'deny' };
  });

  const saveFile = (from, suggestedName) => {
    var options = {
      title: 'Save file',
      defaultPath : suggestedName,
      buttonLabel : 'Save',
      filters :[
          {name: 'All Files', extensions: ['*']}
      ]
    }

    dialog.showSaveDialog(null, options).then(({ filePath }) => {
      fs.copyFile(from, filePath, (err) => {
        if (err) {
            console.log("Error saving file:", err)
        }
        else {
            console.log("Copied file")
        }
      })
    })
  } 
  
  
  ipcMain.on('install-photoshop-plugin', (event) => {
    const webContents = event.sender
    console.log('photoshop!')
    saveFile(path.join(__dirname, 'plugins/photoshop-plugin.ccx'), "photoshop-studio-plugin.ccx")
  })

  ipcMain.on('install-studio-plugin', (event) => {
    const webContents = event.sender
    console.log('studio!')
    saveFile(path.join(__dirname, 'plugins/studio-photoshop-plugin.rbxm'), "studio-photoshop-plugin.rbxm")
  })

  win.loadFile('index.html', {query: {"version": version}})
}

app.whenReady().then(() => {
  createWindow()
  
})

app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') app.quit()
})





