_ = require('lodash')

module.exports = (data) ->
	c = []
	traverse = (element, key) ->
		if(element.value && element.value.buckets.length > 0)
			return _.map element.value.buckets, (e) -> traverse(e, key+'#'+e.key)
		else c.push key+','+element.doc_count


	_.map data.value.buckets,(e)->
		traverse(e,e.key)

	return c.join('\n')