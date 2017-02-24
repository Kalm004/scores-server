'use strict';

let orm = require("orm");

module.exports = () => {
    let opts = {
        database : "scores_db",
        protocol : "postgres",
        host     : "127.0.0.1",
        port     : 5432,         // optional, defaults to database default
        user     : "scores_role",
        password : "scores_pass",
    };
    return new Promise(function (resolve, reject) {
        orm.connect(opts, function (err, db) {
            if (err) {
                //There was an error connection to the database
                reject(err);
            } else {
                let Game = db.define('scores_schema.tm_game', {
                    id: Number,
                    name: String,
                    api_key: String,
                    created: Date,
                    modified: Date
                }, {
                    methods: {
                        fullName: function () {
                            return this.name;
                        }
                    }
                });

                resolve(Game);
            }
        });
    });
};



