{ api } = require './es'
{ getEvents } = require './hotkey-data'
moment = require 'moment'

exports.handler = (event, context) ->
  now = moment.utc()
  indexLine = JSON.stringify
    index:
      _index: "hotkeys-#{now.format 'YYYY.MM.DD'}"
      _type: "hotkey"
  indexLine += '\n'
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
