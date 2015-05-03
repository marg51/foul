redis = require('redis')
client = redis.createClient()
Promise = require("bluebird")
utils = require('./utils')
async = require('async')

exports.getToken = (key) ->
    resolver = Promise.pending()
    client.get 'foul:token:'+key, (err, data) ->
        if err or !data
            resolver.reject err
        else
            resolver.resolve JSON.parse data

    resolver.promise


exports.createToken = (params) ->
    resolver = Promise.pending()

    tokens = {private: utils.generateBigId('key_private'), public: utils.generateId('key_public')}
    async.parallel [
        (callback) -> client.set('foul:token:'+tokens.private, JSON.stringify({type: "private", index: "foul"}), callback)
    , (callback) -> client.set('foul:token:'+tokens.public, JSON.stringify({type: "public", index: "foul"}), callback)
    ], (err, results) ->
        return resolver.reject err if err
        return resolver.resolve tokens if !err


    resolver.promise
