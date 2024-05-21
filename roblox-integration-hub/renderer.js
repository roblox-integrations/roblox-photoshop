const installStudioPlugin = document.getElementById('btnInstallStudioPlugin')
installStudioPlugin.addEventListener('click', () => {
  window.electronAPI.installStudioPlugin()
  return false
})

const btnInstallPhotoshopPlugin = document.getElementById('btnInstallPhotoshopPlugin')
btnInstallPhotoshopPlugin.addEventListener('click', () => {
  window.electronAPI.installPhotoshopPlugin()
  return false
})

