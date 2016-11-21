{ api } = require './es'
{ getEvents } = require './hotkey-data'
moment = require 'moment'

now = moment.utc()

indexLine = JSON.stringify
  index:
    _index: "hotkeys-#{now.format 'YYYY.MM.DD'}"
    _type: "hotkey"
indexLine += '\n'

exports.handler = (event, context) ->
  body = ''
  for doc in getEvents(now.toISOString())
    body += indexLine
    body += JSON.stringify doc
    body += '\n'
  api 'POST', '/_bulk', body
    .then ->
      context.succeed()
    .catch (e) ->
      console.log "ERROR: #{e}\n#{e.stack}"
      context.fail()
exports.handler(null,
  succeed: () -> console.log "Success!"
  fail: () -> console.log "Failed!"
)
