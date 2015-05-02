_ = require('lodash')
ES = require('./elasticsearch')
sessionManager = require('./sessionManager')

# <Object({name: String, type: String, duration: Integer})>data, <Object({foulSessionUID: String})>cookies
exports.create = (data, cookies) ->

    _.merge {}, data, {date: Date.now(), sessionId: cookies.foulSessionUID}
