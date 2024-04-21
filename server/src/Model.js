(
    function(){
        let _model = {};


        function model() {
            return _model;
        }

        // Heartbeat
        let ms = new Date().getTime();
        const _heartbeat = {"studio": false, "studio-ts": ms, "photoshop" : false, "photoshop-ts": ms}
        const HEARTBEAT_TIMEOUT = 5000;


        const checkHeartbeat  = () => {
            let ms = new Date().getTime();
            if(ms - _heartbeat["studio-ts"] >= HEARTBEAT_TIMEOUT) {
                _heartbeat["studio"] = false;
            }
            if(ms - _heartbeat["photoshop-ts"] >= HEARTBEAT_TIMEOUT) {
                _heartbeat["photoshop"] = false;
            }
        }
        setInterval(checkHeartbeat,1000);
        _model.hearbeat = _heartbeat;


        function setHeartbeat(plugin) {
            _heartbeat[plugin] = true;
            _heartbeat[plugin+"-ts"] = new Date().getTime();
        }


        // Sessions
        let _sessions = {}

        function getSessions() {
            let result = []
            for (const [key, value] of Object.entries(_sessions)) {
                result.push(value)
            }
            return result;
        }


        function createSession(session) {
            let time = new Date().getTime()
            let sessionId = "" + time + "" + Math.random()

            session.sessionId = sessionId;
            _sessions[sessionId] = session;
            session.lastUpdated = time
            return session;
        }

        function updateSession(session) {
            session.lastUpdated = new Date().getTime()
            _sessions[session.sessionId] = session
            return session
        }

        function removeSession(sessionId) {

            const { a, ...b } = Object.fromEntries(
                Object.entries(_sessions).filter(([key]) =>
                    key !== sessionId));
            _sessions = b;
        }

        module.exports = {createSession, getSessions, model, setHeartbeat, updateSession} 
    }()
);



