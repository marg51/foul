_ = require('lodash')
ES = require('./elasticsearch')
sessionManager = require('./sessionManager')

# <Object({browser: String, browserVersion: Integer, appVersion: String})>data, <Object({foulSessionUID: String})>cookies
exports.createRoute = (data, cookies) ->
    object = {}
    lastRoute = undefined
    _.merge object, data, {date: Date.now(), sessionId: cookies.foulSessionUID}



    exports.get(cookies.foulLastRouteUID).then( (_lastRoute) ->

        if cookies.foulSessionUID == _lastRoute._source.sessionId and not _lastRoute._source.nextRouteId?
            lastRoute = _lastRoute
            object.sessionRouteIndex = lastRoute._source.sessionRouteIndex+1

        return object

    ).catch(->
        return object
    ).then ->
        if not object.sessionRouteIndex
            object.sessionRouteIndex = 1
        promise = ES.post('route', object).then (data) ->
            data._source = object

            return data

        # once the object is saved, update lastRoute with current route id, if lastRoute exist
        promise.then (data) ->
            object = data
            if lastRoute?
                lastRoute._source.nextRouteId = data._id
                ES.put('route', lastRoute._id, lastRoute._source).finally ->
                    return data
            else
                return data

        sessionManager.addNested(cookies.foulSessionUID, 'routes', promise).then ->
            return object

exports.get = (routeId) ->
    ES.get('route', routeId)
