_ = require('lodash')
ES = require('./elasticsearch')
Promise = require("bluebird")


exports.create = (session, user, event) ->

    _.merge({}, session._source, {user: user._source}, event._source)

exports.get = (id) ->
    ES.get('acquisition', id)
