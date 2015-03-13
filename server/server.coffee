restify = require('restify')
_ = require('lodash')
log = require('./log').displayFiles
ES = require('./elasticsearch')

server = restify.createServer
	name:'API ready'
	version: '0.0.1'

server.use restify.acceptParser(server.acceptable)
server.use restify.queryParser()
server.use restify.bodyParser()

# server.use restify.CORS({origins: ["https://tailster.com","https://www.tailster.com"]})

sourcemap = require('./sourcemap')
server.post '/errors', (req, res, next) ->
	errors = sourcemap.consum(_.filter(req.params.data, (e) ->
			e.fileName.match(new RegExp("/app.js"))
		), req.params.message)

	log errors
	ES.save errors, {user: req.params.user+"", version: req.params.version+"", prod: !!req.params.prod}

	res.send errors

server.opts '/errors', (req, res, next) ->
	res.header('Access-Control-Allow-Credentials', true);
	res.header('Access-Control-Allow-Headers', 'authorizationData, Authorization, Content-Type, Accept-Encoding, Accept-Language');
	res.header('Access-Control-Allow-Methods', '*');
	res.header('Access-Control-Allow-Origin', '*');

	return res.send(204);

server.listen 3001, ->
	console.log 'localhost:'+3001