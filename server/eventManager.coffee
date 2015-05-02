_ = require('lodash')
ES = require('./elasticsearch')
sessionManager = require('./sessionManager')

# <Object({browser: String, browserVersion: Integer, appVersion: String})>data, <Object({foulSessionUID: String})>cookies
exports.create = (data, cookies) ->

    _.merge {}, data, {date: Date.now(), sessionId: cookies.foulSessionUID}
