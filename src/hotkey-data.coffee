Enumerable = require 'linq'
Chance = require 'chance'

hostChance = new Chance(73636)

randHex = () ->
  result = "#{hostChance.integer({ min: 0, max: 255}).toString(16)}"
  if result.length is 1
    result = "0#{result}"
  result

randHost = () -> "i-#{randHex()}#{randHex()}#{randHex()}#{randHex()}"

chance = new Chance()
rand = (min, max) -> chance.integer({ min: min, max: max})
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
        count: -> rand(4, 10)
        size: -> 1024
        totalCount: memcachedGetTotalCount
      }
      {
        key: -> "user.-1"
        count: -> rand(1, 4)
        size: -> 2934
        totalCount: memcachedGetTotalCount
      }
      {
        key: -> "user.#{rand(1000, 1000000000)}"
        count: -> rand(4, 10)
        size: -> 1024
        totalCount: memcachedGetTotalCount
      }
      {
        key: -> "user.#{rand(1000, 1000000000)}"
        count: -> rand(4, 8)
        size: -> 1024
        totalCount: memcachedGetTotalCount
      }
      {
        key: -> "user.#{rand(1000, 1000000000)}"
        count: -> rand(3, 6)
        size: -> 1024
        totalCount: memcachedGetTotalCount
      }
      {
        key: -> "user.#{rand(1000, 1000000000)}"
        count: -> rand(2, 5)
        size: -> 1024
        totalCount: memcachedGetTotalCount
      }
      {
        key: -> "user.#{rand(1000, 1000000000)}"
        count: -> rand(1, 3)
        size: -> 1024
        totalCount: memcachedGetTotalCount
      }
      {
        key: -> "user.#{rand(1000, 1000000000)}"
        count: -> rand(1, 2)
        size: -> 1024
        totalCount: memcachedGetTotalCount
      }
    ]
    'memcached-size': [
      {
        key: -> "user-achievements.#{rand(1000, 1000000000)}"
        count: -> rand(1, 3)
        size: -> 1000000000
        totalCount: memcachedSizeTotalCount
      }
      {
        key: -> "user-achievements.#{rand(1000, 1000000000)}"
        count: -> 1
        size: -> 72000000
        totalCount: memcachedSizeTotalCount
      }
      {
        key: -> "user-achievements.#{rand(1000, 1000000000)}"
        count: -> 1
        size: -> 64000000
        totalCount: memcachedSizeTotalCount
      }
      {
        key: -> "user-achievements.#{rand(1000, 1000000000)}"
        count: -> rand(1, 3)
        size: -> 27000000
        totalCount: memcachedSizeTotalCount
      }
    ]

  records = []
  for category, hotKeys of categories
    for hotKey in hotKeys
      count = hotKey.count()
      size = hotKey.size() * count # this is the cumulative size so multiply by count
      records.push
        app: app
        host: host
        timestamp: timestamp
        topkey_category: category
        topkey_key: hotKey.key()
        topkey_count: count
        topkey_size: size
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
