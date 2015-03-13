exports.hash = (e) ->
	"#{e.stack[0].source}:#{e.stack[0].functionName}:#{e.error}"

exports.strongHash = (e) ->
	"#{e.stack[0].source}:#{e.stack[0].line}:#{e.stack[0].column}:#{e.stack[0].functionName}:#{e.error.replace(/[^a-zA-Z0-9]/,'-')}"
	