uuid = require('node-uuid')

exports.hash = (e) ->
    "#{e.stack[0].source}:#{e.stack[0].functionName}:#{e.error}"

exports.strongHash = (e) ->
    "#{e.stack[0].source}:#{e.stack[0].line}:#{e.stack[0].column}:#{e.stack[0].functionName}:#{e.error.replace(/[^a-zA-Z0-9]/,'-')}"

exports.sanitize = (e) ->
    String(e).replace(/[^a-zA-Z0-9]/g, '');

exports.generateId = (type = 'any') ->
    type+'_'+uuid.v4()

exports.generateBigId = (type = 'any') ->
    type+'_'+uuid.v4()+uuid.v1()
