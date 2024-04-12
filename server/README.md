# Roblox Photoshop Plugin Server App 

This serves as a message bus between the Photoshop and Roblox Studio plugins in this repo. 


Follow these instructions to set up the server-side for the plugin. 
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

## Environment Variables Setup

Next, you need to create a `.env` file containing all the variables. You can check the [.env.sample](./.env.sample) file for this.

```sh
{
        echo 'PORT=9531'
} >> .env
```

`PORT` specifies the port your local server runs on, 9531 is a default value that is also used in Roblox Studio and Photoshop plugins

## Starting The Project

Use this command to start up the server.

```
npm start
```
