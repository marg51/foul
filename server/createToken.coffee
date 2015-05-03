redis = require('./redis')

redis.createToken().then (data) ->
    console.log data
