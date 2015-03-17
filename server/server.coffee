restify = require('restify')
_ = require('lodash')
log = require('./log').displayFiles
ES = require('./elasticsearch')
sessionManager = require('./sessionManager')
errorManager = require('./errorManager')
routeManager = require('./routeManager')
eventManager = require('./eventManager')
CookieParser= require('restify-cookies')

server = restify.createServer
	name:'Foul'
	version: '0.0.1'

server.use restify.acceptParser(server.acceptable)
server.use restify.queryParser()
server.use restify.bodyParser()
server.use CookieParser.parse

# server.use restify.CORS({origins: ["https://.com","https://www..com"]})

sourcemap = require('./sourcemap')

server.post '/create-session', (req, res, next) ->
	sessionManager.createSession(req.params, req.cookies).then (data) ->
		res.setCookie "foulSessionUID", data._id
		res.send('ok')

	next()

server.post '/identify', (req, res, next) ->
	sessionManager.updateUserId(req.cookies.foulSessionUID,req.params.userId)
	res.send()
	next()

server.post '/create-route', (req, res, next) ->
	routeManager.createRoute(req.params, req.cookies).then (data) ->
		res.setCookie "foulLastRouteUID", data._id
		res.send('ok')
	next()

server.post '/create-error', (req, res, next) ->
	errorManager.createError(req.params, req.cookies).then((data) ->
		res.setCookie "foulLastErrorUID", data._id

		if(data.type is "javascript")
			log(data)

	).catch((data) ->
		console.log data
	).finally ->
		res.send('ok')

	next()

server.post '/create-event', (req, res, next) ->
	eventManager.createEvent(req.params, req.cookies)
	res.send("ok")
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