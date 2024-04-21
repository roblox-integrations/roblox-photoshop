(
    function() {
        
        const dotenv = require("dotenv")
        dotenv.config()

        const express = require("express");
        const cors = require("cors");
        const routes = require("./src/routes.js");


        const app = express();

        app.use(cors());
        app.use(
        express.urlencoded({
            extended: false,
        })
        );
        app.use(express.json());
        app.use("/", routes);

        let port = process.env.PORT || 9531
        app.listen(port, () => {
            console.log(`App listening on port ${port}`);
        });
        

}()
);