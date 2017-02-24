let express = require('express');
let app = express();
let databaseInitializer = require('./config/initializers/database.js');
let game = require('./game.js');

databaseInitializer().then((GameTable) => {
    app.get('/game/:api_key', (req, res) => {
        game.searchGameByApiKey(GameTable, req.params.api_key).then((gameRes) => {
            res.send(gameRes);
        });
    });

    app.listen(3000, function () {
        console.log('Example app listening on port 3000!')
    });
});