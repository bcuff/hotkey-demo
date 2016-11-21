{
  region
  es_endpoint
} = require './env.json'

Promise = require 'bluebird'
AWS = require 'aws-sdk'
endpoint = new AWS.Endpoint es_endpoint

getCreds = Promise.fromCallback (cb) ->
  new AWS.CredentialProviderChain([
    -> new AWS.EnvironmentCredentials('AWS')
    -> new AWS.EnvironmentCredentials('AMAZON')
    -> new AWS.SharedIniFileCredentials()
    -> new AWS.EC2MetadataCredentials()
  ]).resolve cb

exports.get = (path) ->
  exports.api 'get', path

# Send a signed AWS ES request and promise the parsed response
exports.api = (method, path, body) ->
  buildRequest(method, path, body)
  .then(signRequest)
  .then(doRequest)
  .then ({statusCode, text}) ->
    if statusCode < 200 or statusCode >= 300
      try
        console.log "HTTP response:", JSON.parse(text)
      catch error
        console.log "Raw HTTP response:", text
      throw new Error "#{statusCode} response received from ES."
    JSON.parse text

# Prepare HTTP request to ES endpoint
buildRequest = (method, path, body) ->
  req = new AWS.HttpRequest endpoint
  req.method = method.toUpperCase()
  req.path = path
  req.region = region
  req.headers['presigned-expires'] = false
  req.headers.Host = endpoint.host
  req.body = body
  Promise.resolve req

# Sign the request as me, for service code 'es'
signRequest = (req) ->
  getCreds.then (creds) ->
    signer = new AWS.Signers.V4 req, 'es'
    signer.addAuthorization creds, new Date
  .return req

doRequest = (req) -> new Promise (resolve, reject) ->
  # issue request and wait for response
  send = new AWS.NodeHttpClient
  send.handleRequest req, null, (response) ->
    if response.error
      return reject response.error

    body = ''
    response.on 'data', (chunk) ->
      body += chunk
    response.on 'end', ->
      resolve
        statusCode: response.statusCode
        text: body
