angular.element(document).ready(function InitAngular() {
    zone.fork(Zone.longStackTraceZone).fork({
        '+onError':function onZoneError(exception){
            setTimeout(function(){
                window.x = _.filter(_.map(_.union(errorHandler.parse(exception), errorHandler.parse({stack:this.getLongStacktrace()})),function(e) {
                    return transformAngularError(e)
                }), function(e) {
                    return String(e.fileName).match('/app.js') || e.native
                });
                Zone.reset()
            }.bind(this),0)
        }
    }).run(function() {
        angular.bootstrap(document.querySelector('html'), ['app']);
    })
});

function transformAngularError(error) {
    switch(error.typeName) {
        case 'ngEventDirectives':
            return {
                columnNumber: null,
                fileName: null,
                functionName: "[[DOM Event]]",
                methodName: null,
                native: true,
                typeName: 'ngEventDirectives'
            }
            break;
        case '$get': 
            return {
                columnNumber: null,
                fileName: null,
                functionName: "[[HTTP Event]]",
                methodName: null,
                native: true,
                typeName: '$http'
            }
        default: return error;
    }
}

// we have to throw it so that zone.js has access to it
app.config(function ($provide, $httpProvider) {
    $provide.decorator("$exceptionHandler", function () {
        return function (exception, cause) {
            throw exception;
        };
    });
});