vasync = require 'vasync'
expect = require 'expect.js'
nano = require 'nano'
samples = require './sample-data'
Games = require '../src/games'

describe 'Games', () ->
  it 'creates models and collections linked with the database', (done) ->
    games = new Games
    games.initialize
      db: 12345
      callback: (err, instance) ->
        expect(instance).to.be(games)
        expect(err).to.be(null)
        model = games.newModel {}
        expect(model.db).to.be(12345)
        collection = games.newCollection "my-username"
        expect(collection.db).to.be(12345)
        done()

# vim: ts=2:sw=2:et:
