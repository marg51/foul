var app = angular.module('foul');

// http://blog.gospodarets.com/track_javascript_angularjs_and_jquery_errors_with_google_analytics/
app.factory('parseExceptionService', function() {
    var exports = {};
    exports.get = function(belowFn) {
        var oldLimit = Error.stackTraceLimit;
        Error.stackTraceLimit = Infinity;

        var dummyObject = {};

        var v8Handler = Error.prepareStackTrace;
        Error.prepareStackTrace = function(dummyObject, v8StackTrace) {
            return v8StackTrace;
        };
        Error.captureStackTrace(dummyObject, belowFn || exports.get);

        var v8StackTrace = dummyObject.stack;
        Error.prepareStackTrace = v8Handler;
        Error.stackTraceLimit = oldLimit;

        return v8StackTrace;
    };

    exports.parse = function(err) {
        if (!err.stack) {
            return [];
        }

        var self = this;
        var lines = err.stack.split('\n').slice(1);

        return lines
            .map(function(line) {
                if (line.match(/^\s*[-]{4,}$/)) {
                    return self._createParsedCallSite({
                        fileName: line,
                        lineNumber: null,
                        functionName: null,
                        typeName: null,
                        methodName: null,
                        columnNumber: null,
                        'native': null,
                    });
                }

                var lineMatch = line.match(/at (?:(.+)\s+)?\(?(?:(.+?):(\d+):(\d+)|([^)]+))\)?/);
                if (!lineMatch) {
                    return;
                }

                var object = null;
                var method = null;
                var functionName = null;
                var typeName = null;
                var methodName = null;
                var isNative = (lineMatch[5] === 'native');

                if (lineMatch[1]) {
                    var methodMatch = lineMatch[1].match(/([^\.]+)(?:\.(.+))?/);
                    object = methodMatch[1];
                    method = methodMatch[2];
                    functionName = lineMatch[1];
                    typeName = 'Object';
                }

                if (method) {
                    typeName = object;
                    methodName = method;
                }

                if (method === '<anonymous>') {
                    methodName = null;
                    functionName = '';
                }

                var properties = {
                    fileName: lineMatch[2] || null,
                    lineNumber: parseInt(lineMatch[3], 10) || null,
                    functionName: functionName,
                    typeName: typeName,
                    methodName: methodName,
                    columnNumber: parseInt(lineMatch[4], 10) || null,
                    'native': isNative,
                };

                return self._createParsedCallSite(properties);
            })
            .filter(function(callSite) {
                return !!callSite;
            });
    };

    exports._createParsedCallSite = function(properties) {
        var methods = {};
        for (var property in properties) {
            var prefix = 'get';
            if (property === 'native') {
                prefix = 'is';
            }
            var method = prefix + property.substr(0, 1).toUpperCase() + property.substr(1);

            (function(property) {
                methods[method] = function() {
                    return properties[property];
                }
            })(property);
        }

        var callSite = Object.create(methods);
        for (var property in properties) {
            callSite[property] = properties[property];
        }

        return callSite;
    };

    return exports;
  });

  app.config(function ($provide) {
    if(/Chrome/.test(navigator.userAgent) && /Google Inc/.test(navigator.vendor)) {
        $provide.decorator("$exceptionHandler", function ($delegate, parseExceptionService, $injector) {
            return function (exception, cause) {
                var $http = $injector.get('$http'),
                    User = $injector.get('UserReference');
                $http.post('https://yourserver/errors', {message: exception.message, data:parseExceptionService.parse(exception), version: "1.7.4"} );
            };
        });
    }
});