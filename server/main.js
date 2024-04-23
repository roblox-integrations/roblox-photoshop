
const { app, BrowserWindow } = require('electron')
let server = require('./app');
const shell = require( "electron" ).shell


const createWindow = () => {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    icon: '/images/appIcon.png',
    title: "Roblox Integration Hub"
  })
  win.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: 'deny' };
  });

  win.loadFile('index.html')
}

app.whenReady().then(() => {
  createWindow()
})





