var app = angular.module('app');

// app.constant('FOUL_URL', 'http://213.246.45.20:2994/v1/')
app.constant('FOUL_URL', '/foul/');


app.factory('foulEventLogger', function($http, foulManager) {
    return function(name, message, data, type) {
        if(!type) {type="success"}

        return foulManager.post('create-event', _.merge({},data,{name:name, type: type, message:message}));
    }
})

app.factory('foulManager', function($http, FOUL_URL, browserInfo, $timeout) {
    var $scope = {};
    var instance, queries = [], running;

    $scope.getSession = function() {
        if(instance) {
            return instance;
        }

        instance = $http.post(FOUL_URL+'create-session',
            _.merge(
                {},
                browserInfo,
                {
                    appVersion: APP_VER,
                    prod: APP_ENV=="PROD"
                }
            )
        ).then(function() {
            var attempt_count = 0;


            var retryLater = function() {
                if(performance && performance.timing.loadEventEnd) { return sendStats()}

                if(attempt_count>5){console.log('cant get timing'); return}
                attempt_count++;

                $timeout(function() {
                    retryLater()
                }, attempt_count*1000)

            }
            var sendStats = function() {
                // can't copy performance.timing as an object, so let's do it value after value
                var timing = _.pick(performance.timing,["connectEnd","connectStart","domComplete","domContentLoadedEventEnd","domContentLoadedEventStart","domInteractive","domLoading","domainLookupEnd","domainLookupStart","fetchStart","loadEventEnd","loadEventStart","navigationStart","redirectEnd","redirectStart","requestStart","responseEnd","responseStart","secureConnectionStart","unloadEventEnd","unloadEventStart"]);

                $scope.post('create-timing', {
                    name: "pageLoad",
                    type: "browserEvent",
                    duration: performance.timing.loadEventEnd - performance.timing.navigationStart ,
                    data: timing
                })
            }

            retryLater();

        })

        return instance;
    }

    $scope.post = function(name, data) {
        $scope.getSession().then(function() {

            var query = function() {
                console.log("running")
                return $http.post(FOUL_URL+name, data).catch(function(e) {
                    console.log("can't save a Foul query",e);
                }).finally(function() {
                    var next = queries.shift()
                    if(next) {
                        running = next()
                    } else {
                        running = undefined
                    }
                });
            }

            if(!running) {
                running = query();
            } else {
                queries.push(query);
            }

        }).catch(function() {
            console.log("can't use Foul",e);
        })
    }

    return $scope;
})


app.run(function($http, $rootScope, $state, $stateParams, foulManager, browserInfo, foulEventLogger) {
    // not used yet, but we should add it to check that events (route / error / event) come in the right order
    var event_number = 0;

    $rootScope.$on('user::loggedIn', function(event, User) {
        foulManager.post('identify', {
            userId: User.user.userID
        });
        foulEventLogger("login", null, {userId: User.user.userID});
    });

    var session = foulManager.getSession()

    var lastEventTime;
    $rootScope.$on('$stateChangeStart', function(event, toState, toParams) {
        lastEventTime = performance.now()
        session.then(function() {
            foulManager.post('create-route', {
                toState: toState.name,
                toParams: toParams
            });
        })
    });

    $rootScope.$on('$stateChangeSuccess', function(event, toState, toParams, fromState, fromParams) {
        if(angular.isFunction(performance.now)) {
            foulManager.post('create-timing', {name: toState.name, type: "state", duration: performance.now()-lastEventTime})
        }
    });

    $rootScope.$on('$stateChangeError', function(event, toState, toParams, fromState, fromParams, error) {
        session.then(function() {
            foulManager.post('create-error', {
                type: "state",
                toState: toState.name,
                toParams: toParams,
                message: error
            });
        })

    });

});

// log errors into Foul for easy debug
// Only on prod and for Chrome users right now

app.config(function ($provide, $httpProvider) {
    $httpProvider.interceptors.push('foulHttpInterceptor');
    $provide.decorator("$exceptionHandler", function ($delegate, $injector, parseExceptionService) {
        return function (exception, cause) {
            // if(browserInfo.name != "Chrome" || APP_ENV!="PROD") {
            //     return $delegate(exception);
            // }

            var $http = $injector.get('$http'),
                $state = $injector.get('$state'),
                foulManager = $injector.get('foulManager'),
                $stateParams = $injector.get('$stateParams');

            foulManager.post("create-error", {
                message: exception.message,
                data: _.filter(
                    parseExceptionService.parse(exception),
                    function(e){
                        return e.fileName.match(new RegExp("/app.js"))
                    }
                ),
                type:"javascript"
            });
        };
    });
});

app.factory('foulHttpInterceptor', function($q, $injector) {
    return {
        // be careful, it could end up with an infinite loop if the timing query is caught
        request: function(config) {
            if(config.url.match(/^\/api/)) {
                if(angular.isFunction(performance.now)) {
                    config._date = performance.now();
                }
            }

            return config
        },
        response: function(data) {
            if(data.config._date) {
                var duration=performance.now() - data.config._date;
                $injector.get('foulManager').post('create-timing', {
                    type: 'http',
                    name: data.config.url.replace(/\/[0-9]+/g,'/:id'),
                    url: data.config.url,
                    status: data.status,
                    method: data.config.method,
                    duration: duration
                })
            }

            return data;
        },
        responseError: function(data) {
            if(!data.config.url.match(/foul/)) {
                console.log(data)
                $injector.get('foulManager').post('create-error', {
                    type: 'http',
                    url: data.config.url,
                    method: data.config.method,
                    statusCode: data.status,
                    message: data.statusText
                })
            }

            return $q.reject(data);
        },

    }
});

// http://blog.gospodarets.com/track_javascript_angularjs_and_jquery_errors_with_google_analytics/
app.factory('parseExceptionService', function() {
    Error.stackTraceLimit = Infinity;
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

// http://stackoverflow.com/questions/5916900/how-can-you-detect-the-version-of-a-browser
app.factory('browserInfo', function() {
    var sayswho= (function(){
        var ua= navigator.userAgent, tem,
        M= ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
        if(/trident/i.test(M[1])){
            tem=  /\brv[ :]+(\d+)/g.exec(ua) || [];
            return 'IE '+(tem[1] || '');
        }
        if(M[1]=== 'Chrome'){
            tem= ua.match(/\bOPR\/(\d+)/)
            if(tem!= null) return 'Opera '+tem[1];
        }
        M= M[2]? [M[1], M[2]]: [navigator.appName, navigator.appVersion, '-?'];
        if((tem= ua.match(/version\/(\d+)/i))!= null) M.splice(1, 1, tem[1]);
        return M;
    })();

    return {
        browser: sayswho[0],
        browserVersion: sayswho[1]
    }
})
