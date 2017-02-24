/**
 * Created by Kalm004 on 18/02/2017.
 */

function searchGameByApiKey(Game, apiKey) {
    return new Promise((resolve, reject) => {
        Game.find({api_key: apiKey}, 1, function (err, games) {
            if (games && games.length > 0) {
                resolve(games[0]);
            }
            resolve(null);
        });
    });
}

module.exports = {
    searchGameByApiKey: searchGameByApiKey
};