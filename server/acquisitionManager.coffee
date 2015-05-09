_ = require('lodash')
ES = require('./elasticsearch')
Promise = require("bluebird")


exports.create = (session, user, event) ->

    _.merge({}, {session: session._source}, {user: user._source}, {event: event})

exports.get = (id) ->
    ES.get('acquisition', id)
