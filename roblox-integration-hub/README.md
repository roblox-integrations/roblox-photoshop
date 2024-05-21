# Roblox Integrations Hub

This serves as a message bus between Roblox Studio plugins and other apps, like Photoshop Plugin in this repo. 
The Hub in an Express app wrapped into and Electron desktop application for easier distribution. 


Follow these instructions to set up the development env for the Hub. 
## Install dependencies

First ensure that your terminal is in the `plugin` folder of this project. To do this, use: 

```bash
cd /roblox-photoshop/server
```

For `yarn` users, install all dependencies using:

```
yarn install
```

For `npm` users, install all dependencies using:

```
npm install
```

## Starting The Project

Use this command to start up the server.

```
npm start
```



## Building a Distributable Package

'''
npm run make
'''