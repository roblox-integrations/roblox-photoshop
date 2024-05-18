
import React, {useEffect, useState, useRef} from 'react'
import "./App.css"


import {storage} from "uxp"
import os from "os";

const versions = require('uxp').versions

const { localFileSystem: fs } = require('uxp').storage
const secureStorage = require('uxp').storage.secureStorage

const app = require('photoshop').app
const {shell} = require("uxp");

const VERSION_URL = "https://api.github.com/repositories/785342744/releases/latest"
const DOWNLOAD_URL = "https://github.com/roblox-integrations/roblox-photoshop/releases/latest"
const TROUBLESHOOT_URL = "https://github.com/roblox-integrations/roblox-photoshop/blob/main/README.md" // TODO link to troubleshooting article
const App = () => {

    const downloadUrl = DOWNLOAD_URL
    const troubleshootUrl = TROUBLESHOOT_URL

    const _inputApi = useRef(null)
    const _inputId  = useRef(null)

    const [apiToken, setApiToken] = useState("");
    const [userId, setUserId] = useState("");
    const [resultAssetId, setResultAssetId] = useState("")

    const [editCredentials, setEditCredentials] = useState(false)

    const [newVersion, setNewVersion] = useState(false);



    const [message, setMessage] = useState("");
    const [status, setStatus] = useState({server: false, studio:false});
    const [sessionToDoc, setSessionToDoc] = useState({})

    const [credentials, setCredentials] = useState({})



    async function fetchSecureKey(key) {
      // We get the stored value from the secureStorage in the form of a uint8Array.
      const uintArray = await secureStorage.getItem(key);
      // We convert the uint8Array to a string to present it to the user.
      let secureKey = "";
      for (let i of uintArray) secureKey += String.fromCharCode(i);
      return secureKey
    }


   const checkForNewVersion = async  () => {
        try {
            console.log("Checking for new version")

            let checkNewVersionResponse = await fetch(VERSION_URL, {
                method: 'GET',
                headers: {
                    "Content-Type": "application/json"
                    }
            })
            if (checkNewVersionResponse.ok) {
                let json = await checkNewVersionResponse.json()
                console.log("new versions:", versions.plugin !== json.name, versions.plugin, json.name)

                setNewVersion(versions.plugin !== json.name)
            } else {
                setNewVersion(false)
            }
        } catch (e) {
            console.log("Can't fetch new version")
        }

    }
    useEffect(() => {
       let fetchCreds = async () => {

          const apiToken = await fetchSecureKey("ROBLOX_API_KEY")
          const userId = await fetchSecureKey("ROBLOX_USER_ID")
          console.log("set credentials from wild card effect: ", apiToken, userId)
          setEditCredentials(apiToken === "" || userId === "")
          setApiToken(apiToken)
          setUserId(userId)
          console.log("updated react model")
      }
      fetchCreds()
      checkForNewVersion()
    }, []);
    useEffect(() => {
            console.log("editCredentials ", editCredentials )
        }, [editCredentials])

    useEffect(() => {
    }, [sessionToDoc]);


    useEffect(() => {
        // This effect will run whenever the 'count' state changes
    }, [status]);


    const getBaseURL = () => {
        let baseUrl =  !process.env.BASE_URL ? "http://localhost:9531/" : process.env.BASE_URL
        return baseUrl
    }


    const heartbeat = async  () => {
        try {
            let heartbeatResponse = await fetch(getBaseURL() + 'heartbeat', {
                method: 'POST',
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({plugin: "photoshop"})
            })
            if (heartbeatResponse.ok) {
                let json = await heartbeatResponse.json()
                setStatus({studio: json.studio, server: true})
            } else {
                setStatus({studio: false, server: false})
            }

        } catch (e) {
            console.log("Can't fetch hearbeat")
            setStatus({studio: false, server: false})
        }

        await openAllActiveSessions()
        await PhotoshopAction.addNotificationListener(['save'], () => {console.log('document saved')})


        // cleanup sessions for closed docs
        //let keys = getSessions().keys()
    }


    useEffect(() => {
        let interval = setInterval(heartbeat,2000);
        return () => {
            clearInterval(interval)
        }
    }, [sessionToDoc]);

    useEffect(() => {
        let interval = setInterval(checkForNewVersion,3600000); // check every hour after the startup
        return () => {
            clearInterval(interval)
        }
    }, [newVersion]);

    const writeToFile = async (executionContext, descriptor) => {

        console.log("writeToFile ");
        const dataFolder = await fs.getDataFolder();
        let ms = new Date().getTime();

        // TODO Make compression a setting
        const file = await dataFolder.createFile("" + ms + ".png", {overwrite: true});

        await app.activeDocument.saveAs.png(file, {compression: 2, }, true);

        console.log("Data Folder: ", dataFolder.name, dataFolder.nativePath);
        let fileReadOk = "can read"
        try {
            let fileData = await file.read({ format: storage.formats.binary });
        } catch(e) {
            fileReadOk = "can't read"
        }
        console.log("Written to: " + file.nativePath + ', file: '  +fileReadOk);
        setMessage("file saved, uploading...");
        return file;
    }


    const saveCurrentSessionAsRobloxAsset = async() => {
        let sessionId
        let doc = app.activeDocument
        for (const [key, value] of Object.entries(sessionToDoc)) {
            if(value === doc._id) {
                sessionId = key;
            }
        }

        let assetId = -1;
        if(sessionId !== undefined) { // replacing existing assets in open place in Studio
            console.log('fetching details for sessionId', sessionId)
            let sessionDetailsResponse = await fetch(getBaseURL() + 'session?sessionId='+sessionId )
            if(!sessionDetailsResponse.ok) {
                console.error("can't fetch session details for sessionId ", sessionId)
                throw new Error("can't fetch session details for sessionId " +  sessionId)
            }
            console.log('saveCurrentSessionAsRobloxAsset: fetching session details json')
            let sessionDetailsJson = await sessionDetailsResponse.json()
            console.log('saveCurrentSessionAsRobloxAsset: parsed session details json')
            assetId = await saveAsRobloxAsset(sessionDetailsJson.asset)
            let newAsset = JSON.parse(JSON.stringify(sessionDetailsJson.asset))
            newAsset.assetId = assetId;
            sessionDetailsJson.outAsset = newAsset
            console.log('saveCurrentSessionAsRobloxAsset: updating the session with newly created asset')
            try {
                let sessionUpdateResponse = await fetch(getBaseURL() + 'session', {
                    method: 'POST',
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify(sessionDetailsJson)
                })
                if (!sessionUpdateResponse.ok) {
                    console.error("can't update session details for sessionId ", sessionId)
                }
                let sessionUpdateJson = await sessionUpdateResponse.json()
                console.log('saveCurrentSessionAsRobloxAsset: the session after update: ', sessionUpdateJson)
            } catch (e) {
                console.error("error updating the session", e)
            }
        } else { // upload new asset 
            console.log('Saving new asset w/o a session..')
            assetId = await saveAsRobloxAsset({})
            console.log('Saved new asset w/o a session, ', assetId)
        }


        



    }


    // fetch via hub as Windows UXP doesn't support gzip :)
    const getImageFromDecal = async (decalId) => {

        let url = getBaseURL() + 'imageIdFromAssetId/'+ decalId
            
        let  response = await fetch(url)
        if(!response.ok) {
            throw new Error('Cant fetch imageId')
        }
        let text = await response.text()

        const imageId = parseInt(text);
        if (typeof imageId != 'number') {
            throw new Error('Failed to parse imageId');
        }


        return imageId
    }

    const saveAsRobloxAsset = async(assetInfo) => {
        try {
            let file = await require("photoshop").core.executeAsModal(writeToFile, {})
            let fileData = await file.read({ format: storage.formats.binary });

            var data = new FormData()
            data.append('fileContent', fileData)
            data.append('fileContent', new Blob([fileData], {type: "image/png"}))

            // TODO: take the original's asset name and description into account

                // data.append('request', JSON.stringify({assetType: "decal",
                //     displayName: assetInfo.productInfo !== undefined ? assetInfo.productInfo.name : "image from Photoshop",
                //     description: assetInfo.productInfo !== undefined ? assetInfo.productInfo.description : "image from Photoshop",
                //     creationContext: { creator:
                //             {userId: userId }}}))
            data.append('request', JSON.stringify({assetType: "decal",
                displayName: "image from Photoshop",
                description: "image from Photoshop",
                creationContext: { creator:
                        {userId: userId }}}))

            console.log("about to send request", data)

            let url = 'https://apis.roblox.com/assets/v1/assets'
            let response = await fetch(url, {
                method: 'POST',
                headers: {
                    'x-api-key': apiToken,
                },
                body: data
            })

            if(!response.ok) {
                console.error('Save asset request failed')
                throw new Error('Save asset request failed')
            }
            let json = await response.json()
            console.log("Asset saving response", json)

            // wait until the asset operation is over
            let operationId = json.operationId
            let operationStatusMaxRetriesLeft = 10
            let resultingAssetId = -1;
            await new Promise((resolve) => {setTimeout(resolve, 400)})
            while (operationStatusMaxRetriesLeft > 0) {
                operationStatusMaxRetriesLeft--
                let operationUrl= 'https://apis.roblox.com/assets/v1/operations/' + operationId
                let operationResponse = await fetch(operationUrl, {method: 'GET',
                    headers: {'x-api-key': apiToken}})
                if(!response.ok)  {
                   console.log(response.status, operationUrl)
                   await new Promise((resolve) => {setTimeout(resolve, 200)})
                   continue
                }
                let operationJson = await operationResponse.json()
                if(operationJson.done) {
                    resultingAssetId  = operationJson.response.assetId
                    break
                }
                await new Promise((resolve) => {setTimeout(resolve, 400 + (10-operationStatusMaxRetriesLeft)*50)})
            }

            if(resultingAssetId === -1) {
                throw new Error("Unable to fetch assetid in time, please try again")
            }

            let imageAssetId = await getImageFromDecal(resultingAssetId)

            console.error('TODO Show assets information back to the user, allow to copy assetID')
            setMessage('Done, the image asset ID is ' + imageAssetId)
            setResultAssetId(imageAssetId)

            return imageAssetId
        } catch (e) {
            setMessage("Saving Error: " + e.code + ", " + e.message);
            console.error("Saving error: ", e);
        }
    }



    const save = async () => {
        try {
            let file = await require("photoshop").core.executeAsModal(writeToFile, {})
            console.log("returned file name", file)
        } catch (e) {
            setMessage("Saving Error: " + e.code + ", " + e.message);
            console.error("Saving error: ", e);
        }


    }
    const addNewDocument = async (executionContext, descriptor) => {
        console.error("in addNewDocument!", executionContext, descriptor);
        // const currentDocument = app.activeDocument;

        //
        // currentDocument.closeWithoutSaving();

        // read file
        const pluginFolder = await fs.getPluginFolder(); // read-only access to the plugin's install folder
        const imageFile = await pluginFolder.getEntry("icons/test.bmp")

        const newDoc = await require('photoshop').app.open(imageFile);
        console.error("created new Doc!");
    }

    const openDocumentFromFile = async (file) => {
        try {
            const newDoc = await require('photoshop').app.open(file);
            console.error("created new Doc from file", newDoc);
            return newDoc
        } catch (e) {
            console.log("error creating new doc", e);
        }
    }




    const openNewDocument = async () => {
        try {
            await require("photoshop").core.executeAsModal(addNewDocument, {})
            } catch (e) {
             setMessage("Error opening a document; " + e.code + ", " + e.message);
             console.error("error opening file: ", e);
        }
    }

    const openNewDocumentFromAssetId = async (assetId) => {
        try {
            let url = getBaseURL() + 'assetImage/'+ assetId
            const image = await fetch(url);
            console.log("image request ", image.ok, image.status);
            const dataFolder = await fs.getDataFolder();
            const img = await image.arrayBuffer();
            let ext = (image.headers.get('content-type').includes('png')) ? '.png' : '.jpg';
            let ms = new Date().getTime();
            const file = await dataFolder.createFile("" + ms + ext);
            await file.write(img);
            return await require('photoshop').core.executeAsModal(() => {return openDocumentFromFile(file)}, {})
        } catch (e) {
            setMessage("Error fetching asset info, Hub is not running? " + e.code + ", " + e.message);
            console.error("URL: " + url)
            console.error("error opening file from server: ", e);
        }
    }

    const copySessionToDoc = (sessionToDoc) => {
        let result = {}
        for(var k in sessionToDoc) result[k]=sessionToDoc[k];
        return result

    }
    const openAllActiveSessions = async () => {
        try {
            let url = getBaseURL() + 'sessions'
            const response = await fetch(url);

            if(!response.ok) {
                res.status(response.status);
                console.error('error fetching the image', response.status);
                res.send("error fetching the image")
                return;
            }

            let json = await response.json()
            let sessionToDocCopy = copySessionToDoc(sessionToDoc)

            for(let i=0; i<json.length;i++) {
                let sess = json[i]
                const docId = sessionToDocCopy[sess.sessionId]
                if(docId !== undefined) {
                    console.log("already opened:", docId)
                    continue;
                }
                console.log("before adding the  mapping for sessionId", sessionToDocCopy)
                let newDoc = await openNewDocumentFromAssetId(sess.asset.assetId)
                console.log("newDoc._id", newDoc["_id"]);
                sessionToDocCopy[sess.sessionId] = newDoc["_id"]
                console.log("added mapping for sessionId", sessionToDocCopy[sess.sessionId])
            }
            setSessionToDoc(sessionToDocCopy)
        } catch (e) {
            setMessage("Error opening active sessions, Hub app is not running?" + e.code + ", " + e.message);
            console.error("error opening file from server: ", e);
        }
    }

    const saveCredentials = async () => {

        const apiToken = document.getElementById("inputApiToken").value
        const userId  = document.getElementById("inputUserId").value

        try {
            await secureStorage.setItem("ROBLOX_API_KEY", apiToken)
            await secureStorage.setItem("ROBLOX_USER_ID", userId)
            setApiToken(apiToken)
            setUserId(userId)
            console.log("Credentials saved!")
        } catch(e) {
            console.error("can't save credentials", e)
        }
    }


// curl --silent -m 10 --connect-timeout 5 "https://api.github.com/repositories/782732905/releases/latest" | jq -r .name
//   RELEASE_3.0.8



return (
        <>
            {newVersion ?

                  <sp-body class="well">
                    <sp-icon name="ui:InfoSmall" size="s"></sp-icon>
                        New version is available!
                        <sp-button  onClick={() => {shell.openExternal(downloadUrl)}}>Download from GitHub</sp-button>
                  </sp-body>

                 : <sp-body></sp-body>}


            <br/>
            {!editCredentials
                ?
                     <sp-button quiet variant="secondary" onClick={() => {
                        setEditCredentials(true)}}>Change Credentials</sp-button>
                :
                    <>
                        {/* the width is a workaround  for UXP bug with text field values being ellipsised   */}

                        <sp-textfield id="inputApiToken" width="450px" multiline value={apiToken}>
                            <sp-label slot="label">API Key</sp-label>
                        </sp-textfield>
                        <br/>
                        <sp-textfield id="inputUserId" type="input" value={userId}>
                             <sp-label slot="label">User ID</sp-label>
                        </sp-textfield>
                        <br/><br/>
                        <sp-button variant="primary" onClick={() => {saveCredentials(); setEditCredentials(false)}}>Save Credentials</sp-button>
                        <br/><br/>
                    </>
            }

            <sp-button variant="cta" onClick={() => saveCurrentSessionAsRobloxAsset()}>
                Save to Roblox<span slot="icon"></span>
            </sp-button>
            <br/>


            <sp-body size="S">{message}</sp-body>

            {resultAssetId 
                ? 
                <sp-button id="copyResultAssetIdBtn" variant="secondary" quiet onClick={()=>{ navigator.clipboard.setContent({"text/plain": ""+ resultAssetId})}}>Copy asset id</sp-button>
                : <></>

            }

            <sp-divider size="medium"></sp-divider>




            <br/>


            <div className="table">
                <div>
                  <sp-detail>Hub: </sp-detail>
                  <sp-body> {status.server ? 'on' :  <sp-link  onClick={() => {shell.openExternal(troubleshootUrl)}} >Off. Troubleshoot</sp-link> }</sp-body>
                </div>
                <div>
                  <sp-detail>Studio:</sp-detail>
                  <sp-body>
                    {status.studio ? 'on' : <sp-link  onClick={() => {shell.openExternal(troubleshootUrl)}} >Off. Troubleshoot</sp-link> }
                  </sp-body>
                </div>
                <div>
                  <sp-detail>version:</sp-detail>
                  <sp-body>{versions.plugin}</sp-body>
                </div>
                <div>
                  <sp-body>
                                          <sp-button variant="secondary" quiet onClick={() => openAllActiveSessions()}>
                                               Reopen all
                                          </sp-button>

                                          <sp-button variant="secondary" quiet onClick={() => {
                                              setSessionToDoc({})
                                              setMessage("Sessions reset")
                                          }}>Reset</sp-button>

                  </sp-body>
                </div>

              </div>




{/*             DEBUGGING CONTROLS */}
            {/*<sp-button variant="primary" onClick={() => openNewDocument()}>*/}
            {/*    Open <span slot="icon"><PlayIcon/></span>*/}
            {/*</sp-button>*/}
            {/*<sp-button variant="primary" onClick={() => openNewDocumentFromAssetId(14017889476)}>*/}
            {/*    Open From Server <span slot="icon"><PlayIcon/></span>*/}
            {/*</sp-button>*/}

            {/*<sp-button variant="primary" onClick={() => save()}>*/}
            {/*    Write <span slot="icon"><CopyIcon/></span>*/}
            {/*</sp-button>*/}
            {/*<sp-button variant="primary" onClick={() => saveAsRobloxAsset()}>*/}
            {/*    Save as asset <span slot="icon"><CopyIcon/></span>*/}
            {/*</sp-button>*/}

            {/*<sp-button variant="primary" onClick={() => alert('Not yet!')}>*/}
            {/*    Start a session from asset*/}
            {/*</sp-button>*/}



        </>


    );
}






export default App;
