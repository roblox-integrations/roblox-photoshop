(
    function(){
            const express = require("express")
            const {createSession, getSessions, model, setHeartbeat, updateSession} = require("./Model.js");
            const nodeFetch = require("node-fetch");

            

            const router = express.Router();

            router.get("/", async (req, res) => {
            let sessionsHtml= "";
            getSessions().forEach((value) => {

                sessionsHtml  = sessionsHtml +  '<div>' + JSON.stringify(value)+'</br>' +
                    '<img width="100"  src="/assetImage/'+ value.asset.assetId +'"/> ---> <img width="100"  src="/assetImage/'+ ((value.outAsset !== undefined) ? value.outAsset.assetId  : '') +'"/></div>'
            })
            if(sessionsHtml === "") sessionsHtml = "No active sessions"
            res.send('<html><body>' + sessionsHtml + '</body></html>');
            });

            // Image
            router.get("/assetImage/:assetId", async (req, res) => {
                // sample assetId: 14017889476
                let url = "https://assetdelivery.roblox.com/v1/asset/?id=" + req.params.assetId
                const response = await nodeFetch(url);
                if(!response.ok) {
                    res.status(response.status);
                    console.error("error fetching the image", response.status);
                    res.send("error fetching the image")
                    return;
                }
                const buffer = await response.buffer();
                //res.setHeader('content-type', response.headers.get('content-type'))
                res.setHeader('content-type', 'image/png') // force the content type for corrupted assets
                res.end(buffer)
            });
            // const upload = multer({dest: 'uploads/'})



            // router.post("/assetImage/", upload.single(), async (req, res) => {
            //     // sample assetId: 14017889476
            //     console.log("hello")
            //     //reg.file contains the image
            //     console.log("assetRequest", req.body.request)

            //     res.status(200)

            //     res.send("Hallo")
            // });


            const DECAL_CAPTURE_REGEX = new RegExp(
                '<Content name="Texture">\\s*<url>[^0-9]+(\\d+)</url>\\s*</Content>',
            );
        
            const getImageFromDecal = async (decalId) => {
                let  response = await fetch('https://assetdelivery.roblox.com/v1/asset/?id='+ decalId)
                if(!response.ok) {
                    throw new Error('Cant fetch decal')
                }
                
                let text = await response.text()
                console.log("fetched..", text)
                const match = DECAL_CAPTURE_REGEX.exec(text);
                if (match == null) {
                    throw new Error('Failed to get contentId from asset' + text);
                }
                console.log("mateched..")
                const imageId = parseInt(match[1]);
                if (typeof imageId != 'number') {
                    console.log("failed to parse", imageId)
                    throw new Error('Failed to parse imageId');
                }
                return imageId
            }

            router.get("/imageIdFromAssetId/:assetId", async(req, res) => {
                const result = await getImageFromDecal(req.params.assetId)
                console.log("image id = ", result)
                res.status(200)
                res.send(""+result)    

            })
            // Heartbeat
            router.get("/heartbeat", async (req, res) => {
                res.json(model().hearbeat)
            });

            router.post("/heartbeat", async (req, res) => {
            console.log("Set for plugin: ", req.body.plugin, "User-agent: ", req.headers['user-agent'])
            if (!(req.body.plugin === "photoshop") && !(req.body.plugin === "studio") ) {
                res.status(400);
            }
            setHeartbeat(req.body.plugin)
            res.send(model().hearbeat);
            });



            // Sessions
            router.get("/sessions", async (req, res) => {
                res.json(getSessions());
            });

            router.post("/sessions", async (req, res) => {

                /// TODO REMOVE!!111
                if(req.body.instanceId === undefined || req.body.asset === undefined) {
                    res.status(400)
                    res.end()
                    return
                }
                let session = createSession({instanceId: req.body.instanceId, asset: req.body.asset})
                res.send(session)
                console.log('REMOVE THIS ENDPOINT, USE POST /session')


            });



            router.get("/session/", async (req, res) => {
                let sessionId = req.query.sessionId
                let session = getSessions().filter((s) => {
                    return s.sessionId === sessionId
                });
                if (session.length === 0) {
                    console.log('session not found')
                    res.status(404)
                    //res.end('\'session not found\'')
                    res.send()
                    return
                }
                console.log( new Date().toUTCString(), 'returning a session', req.headers["user-agent"])
                res.status(200)
                res.send(session[0])
            });

            router.get("/closeSession/", async (req, res) => {
                let sessionId = req.query.sessionId
                let session = getSessions().filter((s) => {
                    return s.sessionId === sessionId
                });
                if (session.length === 0) {
                    console.log('session not found')
                    res.status(404)
                    //res.end('\'session not found\'')
                    res.send()
                    return
                }
                console.log( new Date().toUTCString(), 'closing the sessions a session', req.headers["user-agent"])
                res.status(200)

                removeSession(sessionId)
                res.send(getSessions())
            });

            router.post("/session/", async (req, res) => {
                if(req.body.instanceId === undefined || req.body.asset === undefined) {
                    res.status(400)
                    res.end()
                    console.log('invalid request for session update')
                    return
                }
                let session
                if(req.body.sessionId === undefined) {
                    session = createSession({instanceId: req.body.instanceId, asset: req.body.asset})
                    console.log('create new session')
                }
                else {
                    session = updateSession(req.body)
                    console.log('update a session session')
                }

                res.send(session)
            });


    module.exports = router;

    }()
);
