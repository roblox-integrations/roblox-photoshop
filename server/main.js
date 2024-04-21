
const { app, BrowserWindow } = require('electron')
let server = require('./app');

const createWindow = () => {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    title: "Roblox Integration Hub"
  })

  win.loadFile('index.html')
}

app.whenReady().then(() => {
  createWindow()
})





