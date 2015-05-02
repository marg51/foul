sourcemap = require('./sourcemap')
_ = require('lodash')
ES = require('./elasticsearch')
sessionManager = require('./sessionManager')
Promise = require("bluebird")


exports.create = (data, cookies) ->
    errors = {}

    if(data.type is "javascript")
        errors = sourcemap.consum(data.data, data.message)


    # we create our object that we will save into elasticsearch
    object = {}

    _.merge object, _.omit(data,"data"),
        message: data.message
        data: errors,
        sessionId: cookies.foulSessionUID
        date: Date.now()

    if errors.stack && errors.stack.length > 0
        _.merge object,
            file: errors.stack[0].source
            line: errors.stack[0].line
            column: errors.stack[0].column
            functionName: errors.stack[0].functionName,

    return object

exports.get = (id) ->
    ES.get('error', id)
