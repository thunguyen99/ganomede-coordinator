nano = require 'nano'
restify = require 'restify'
expect = require 'expect.js'
#DB = require '../../src/challenges-api/db'
config = require '../config'
samples = require './sample-data'

clone = (obj) -> JSON.parse(JSON.stringify(obj))

#initDb = (noSampleData, callback) ->
#  if arguments.length == 1
#    callback = noSampleData
#    noSampleData = false
#
#  DB.initialize config.couch.name, config.type, config.couch.serverUri,
#  (err, db) ->
#    if (err)
#      return callback(err)
#
#    if (noSampleData)
#      return callback(null, db)
#
#    db.db.bulk {docs: samples.docs}, (err) ->
#      callback(err, db)
#
#dropDb = (callback) ->
#  nano(config.couch.serverUri).db.destroy(config.couch.name, callback)
#
#module.exports =
#  initDb: initDb
#  dropDb: dropDb
#
#  expectToEqlExceptSecondsToEnd: (left, right) ->
#    arrLeft = clone(if Array.isArray(left) then left else [left])
#    arrRight = clone(if Array.isArray(right) then right else [right])
#    arrLeft.forEach (item) -> delete item.secondsToEnd
#    arrRight.forEach (item) -> delete item.secondsToEnd
#    expect(arrLeft).to.eql(arrRight)
#
#  mocks:
#    rules:
#      post:
#        '/substract-game/v1/games': (payload, callback) ->
#          callback null, {}, {statusCode: 200},
#            clone(samples.newEntry.initialState)
#
#        '/substract-game/v1/moves': (game, callback) ->
#          code = 200
#          error = null
#          game.gameData.total -= game.moveData.number
#          game.gameData.nMoves += 1
#
#          if game.gameData.total < 0
#            error = new restify.RestError({restCode: 'InvalidMove'})
#            code = 400
#          else if game.gameData.total == 0
#            game.status = 'gameover'
#            game.scores = [game.gameData.nMoves * 10]
#
#          delete game.moveData
#          body = if error then error.body else game
#          callback(error, {}, {statusCode: code}, body)
module.exports = {}
