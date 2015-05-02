_ = require('lodash')
ES = require('./elasticsearch')
Promise = require("bluebird")


exports.create = (session, user, event) ->
    object = {}

    _.merge(object, session._source, {user: user._source}, event._source)

    ES.post('acquisition', object).then (data) ->
        data._source = object

        data

exports.get = (id) ->
    ES.get('acquisition', id)
