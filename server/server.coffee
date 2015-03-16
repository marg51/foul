restify = require('restify')
_ = require('lodash')
log = require('./log').displayFiles
ES = require('./elasticsearch')
sessionManager = require('./sessionManager')

server = restify.createServer
	name:'Foul'
	version: '0.0.1'

server.use restify.acceptParser(server.acceptable)
server.use restify.queryParser()
server.use restify.bodyParser()

# server.use restify.CORS({origins: ["https://.com","https://www..com"]})

sourcemap = require('./sourcemap')

server.post '/create-session', (req, res, next) ->
	sessionManager.createSession(req.params).then (data) ->
		res.send {sessionId: data._id}

	next()

server.post '/identify', (req, res, next) ->
	sessionManager.updateUserId(req.params.sessionId,req.params.userId)
	res.send()
	next()

server.post '/route', (req, res, next) ->
	routeManager.createRoute(req.params).then (data) ->
		res.send {routeId: data._id}
	next()

server.post '/error', (req, res, next) ->
	errorManager.createError(req.params).then (data) ->
		log(data)

	res.send()
	next()

server.post '/event', (req, res, next) ->
	eventManager.createEvent(req.params)
	res.send()
	next()


server.post '/errors', (req, res, next) ->
	# retrieve list of errors with original filename/line, we send the error message as well
	# @todo message should not be passed here
	errors = sourcemap.consum(req.params.data, req.params.message)

	# realtime terminal visualisation, only for debug purpose
	log errors

	# we create our object that we will save into elasticsearch
	data = {}

	_.merge data, _.omit(req.params,"data"),
		file: errors.stack[0].source
		line: errors.stack[0].line
		column: errors.stack[0].column
		message: errors.message
		functionName: errors.stack[0].functionName,
		data: errors

	# persist into elasticsearch
	ES.save data 

	res.send "ok"

server.post '/routes', (req, res, next) ->
	ES.save req.params

	res.send "ok"

Cors = (req, res, next) ->
	res.header('Access-Control-Allow-Credentials', true);
	res.header('Access-Control-Allow-Headers', 'authorizationData, Authorization, Content-Type, Accept-Encoding, Accept-Language');
	res.header('Access-Control-Allow-Methods', '*');
	res.header('Access-Control-Allow-Origin', '*');

	return res.send(204);

server.opts '/errors', Cors
server.opts '/routes', Cors

server.listen 3001, ->
	console.log 'localhost:'+3001