_ = require('lodash')
ES = require('./elasticsearch')
sessionManager = require('./sessionManager')
Promise = require("bluebird")


exports.createUser = (data) ->
    console.log "create user", data
    object = {
        signup: Date.now(),
        first_visit: Date.now() # we should check the device and set the date of the first session of this device
    }

    object = _.merge({}, data, object)

    promise = ES.post('user', object, {id: 'user_'+data.user.id}).then (data) ->
        data._source = object

        return data

exports.getOrCreate = (userId, data) ->
    console.log "get or create user", data
    exports.get(userId).catch ->
        exports.createUser(data)

exports.identify = (userId, session) ->
    exports.get(userId).then (user) ->
        user._source.lastLogin = Date.now()
        exports.update(user)
        session._source.user = _.merge({},user._source);
        session._source.user.esId = user._id

exports.get = (id) ->
    ES.get('user', id)

exports.update = (user) ->
    ES.put(user, user._id, user._source)
