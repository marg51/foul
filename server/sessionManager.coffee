_ = require('lodash')
ES = require('./elasticsearch')

# <Object({browser: String, browserVersion: Integer, appVersion: String})>data, <Object({foulSessionUID: String})>cookies
exports.createSession = (data, cookies) ->

	object = {}

	_.merge object, data, {date: Date.now(), previousSessionId: cookies.foulSessionUID}

	# return promsie
	ES.post('session', object)

exports.updateUserId = (sessionId, userId) ->
	exports.getSession(sessionId).then (data) ->
		data.userId = userId

		ES.put('session',sessionId,data)


exports.getSession = (sessionId) ->
	ES.get('session', sessionId)
