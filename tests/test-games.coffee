vasync = require 'vasync'
expect = require 'expect.js'
nano = require 'nano'
samples = require './sample-data'
Games = require '../src/games'
helpers = require './helpers'

describe 'Games', () ->

  before (done) ->
    # (Easiest thing to do is to just test it right here.)
    helpers.initDb (err, db_) ->
      db = db_
      done(err)

  after (done) ->
    helpers.dropDb(done)

  describe 'Module', () ->
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

  describe 'GameModel', () ->
    it 'should fetch content from the database', (done) ->
      done()

# vim: ts=2:sw=2:et:
