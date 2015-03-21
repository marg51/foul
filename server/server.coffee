restify = require('restify')
_ = require('lodash')
log = require('./log').displayFiles
ES = require('./elasticsearch')

server = restify.createServer
    name:'Foul'
    version: '0.0.1'

server.use restify.acceptParser(server.acceptable)
server.use restify.queryParser()
server.use restify.bodyParser()

# server.use restify.CORS({origins: ["https://.com","https://www..com"]})

sourcemap = require('./sourcemap')
server.post '/errors', (req, res, next) ->
    res.header('Access-Control-Allow-Credentials', true);
    res.header('Access-Control-Allow-Headers', 'authorizationData, Authorization, Content-Type, Accept-Encoding, Accept-Language');
    res.header('Access-Control-Allow-Methods', '*');
    res.header('Access-Control-Allow-Origin', '*');
    
    # retrieve list of errors with original filename/line, we send the error message as well
    # @todo message should not be passed here
    errors = sourcemap.consum(req.params.data, req.params.message)

    # realtime terminal visualisation, only for debug purpose
    log errors

    # we create our object that we will save into elasticsearch
    data = {}

    _.merge data, _.omit(req.params,"data"),
        message: String(errors.message).substr(0,100)
        data: errors

    if errors.stack.length

        _.merge data, 
            file: errors.stack[0].source
            line: errors.stack[0].line
            column: errors.stack[0].column
            functionName: errors.stack[0].functionName


    

    # persist into elasticsearch
    console.log JSON.stringify data, null, 4
    ES.save data 

    res.send "ok"

Cors = (req, res, next) ->
    res.header('Access-Control-Allow-Credentials', true);
    res.header('Access-Control-Allow-Headers', 'authorizationData, Authorization, Content-Type, Accept-Encoding, Accept-Language');
    res.header('Access-Control-Allow-Methods', '*');
    res.header('Access-Control-Allow-Origin', '*');

    return res.send(204);

server.opts '/errors', Cors



server.listen 3001, ->
    console.log 'localhost:'+3001