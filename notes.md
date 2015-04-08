### Nested objects is a bad idea

I'm using nested objects *a lot*, every route/event/error is nested into the session it belongs to. It's really powerful, until you realise the impact at index time. Elasticsearch doesn't update like a SQL server would do it. It removes the old document and creates a new one with updated values, and data is re-indexed. The whole document. Everytime. With all routes, all events, all errors. So, it's a bad idea.

### Elasticsearch is not always the right tool

It's killing me to say so, but when trying to get the pages with the biggest drop-offs, I realised that elasticsearch is not the right tool to do that.

[We can do it](https://github.com/marg51/foul/blob/a04a86e/elasticsearch/reports/bounce_after_event.coffee), but it's really not optimised and you can't extend it.

##### What I've done:

- aggregate per sessionId, so that I have buckets of routes of the same session
- take the last route of each buckets ( = last route of every session )
- with this result, I count the number of occurences of every state with node

##### What can we do ?

I tried to update my server, so that every route has a `nextRouteId`. Now, I can filter (instead of aggregating) the latest routes of every session. [Here is the new script](https://github.com/marg51/foul/blob/a047aa4/elasticsearch/reports/bounce_after_event.coffee)

It gives the same result, but there is a big difference: we can extend it. We can add any aggregation on top of it, add filters…

##### So, what's the problem ?

**I had to update my server** for this specific use case. It does work, ok, but what if I want the latest two states ? I will need to update my server again.

I need simplicity, and it isn't what I have right now.

##### Redis

I wonder if using elasticsearch and redis could help. Using the power of retrieving documents with redis and the power of search of elasticsearch sound powerful. I'll have to think about it.


