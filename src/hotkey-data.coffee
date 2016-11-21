Enumerable = require 'linq'
Chance = require 'chance'

hostChance = new Chance(73636)

randHex = () ->
  result = "#{hostChance.integer({ min: 0, max: 255}).toString(16)}"
  if result.length is 1
    result = "0#{result}"
  result

randHost = () -> "i-#{randHex()}#{randHex()}#{randHex()}#{randHex()}"

rand = (min, max) ->
  Math.floor(Math.random() * (max - min)) + min
mil = 1000000000

apps =
  dice: Enumerable.range(1, 80).select(randHost).toArray()
  wheel: Enumerable.range(1, 20).select(randHost).toArray()

getRecords = (timestamp, host, app) ->
  memcachedGetTotalCount = rand(2000, 4000)
  memcachedSizeTotalCount = rand(80 * mil, 120 * mil)
  categories = 
    'memcached-get': [
      {
        key: -> "user.0"
        count: -> rand(500, 2000)
        totalCount: memcachedGetTotalCount
      }
      {
        key: -> "user.#{rand(1000, 1000000000)}"
        count: -> rand(4, 10)
        totalCount: memcachedGetTotalCount
      }
      {
        key: -> "user.#{rand(1000, 1000000000)}"
        count: -> rand(4, 8)
        totalCount: memcachedGetTotalCount
      }
      {
        key: -> "user.#{rand(1000, 1000000000)}"
        count: -> rand(3, 6)
        totalCount: memcachedGetTotalCount
      }
      {
        key: -> "user.#{rand(1000, 1000000000)}"
        count: -> rand(2, 5)
        totalCount: memcachedGetTotalCount
      }
      {
        key: -> "user.#{rand(1000, 1000000000)}"
        count: -> rand(1, 3)
        totalCount: memcachedGetTotalCount
      }
      {
        key: -> "user.#{rand(1000, 1000000000)}"
        count: -> rand(1, 2)
        totalCount: memcachedGetTotalCount
      }
    ]
    'memcached-size': [
      {
        key: -> "user-achievements.3726112"
        count: -> rand(1, 3) * 1000000000
        totalCount: memcachedSizeTotalCount
      }
      {
        key: -> "user-achievements.2334455"
        count: -> rand(1, 3) *  720000000
        totalCount: memcachedSizeTotalCount
      }
      {
        key: -> "user-achievements.7823422"
        count: -> rand(1, 3) *  720000000
        totalCount: memcachedSizeTotalCount
      }
    ]

  records = []
  for category, hotKeys of categories
    for hotKey in hotKeys
      count = hotKey.count()
      records.push
        app: app
        host: host
        timestamp: timestamp
        topkey_category: category
        topkey_key: hotKey.key()
        topkey_count: count
        topkey_totalCount: hotKey.totalCount
        topkey_frequency: count / hotKey.totalCount
  records

exports.getEvents = (timestamp) ->
  results = []
  for app, hosts of apps
    for host in hosts
      for record in getRecords(timestamp, host, app)
        results.push record
  results
