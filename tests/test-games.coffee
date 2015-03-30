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
          collection = games.activeGames "my-username"
          expect(collection.db).to.be(12345)
          done()

  describe 'GameModel', () ->

    it 'should fetch content from the database', (done) ->
      games = new Games
      model = null
      vasync.waterfall [
        (cb) ->
          games.initialize callback: (err) -> cb(err)
        (cb) ->
          model = games.newModel id:samples.docs[0]._id
          model.fetch cb
      ], (err, results) ->
        expect(err).to.be(null)
        expect(model.type).to.be(samples.docs[0].type)
        expect(model.players[1]).to.be(samples.docs[0].players[1])
        expect(model.status).to.be(samples.docs[0].status)
        done()

    it 'should save entries to the DB', (done) ->
      games = new Games
      model = null
      rev = null
      vasync.waterfall [
        (cb) ->
          games.initialize callback: (err, instance) ->
            expect(err).to.be(null)
            cb err
        (cb) ->
          model = games.newModel
            data: 12345
          model.save (err) -> cb(err)
        (cb) ->
          expect(model.id).not.to.be(null)
          expect(model.rev).not.to.be(null)
          model.data = 54321
          model.save (err) -> cb(err)
          rev = model.rev
      ], (err, results) ->
        expect(err).to.be(null)
        expect(model.rev).not.to.be(rev)
        expect(model.data).to.be(54321)
        done()

  describe 'GameCollection', () ->
    it 'should fetch content from the database', (done) ->
      games = new Games
      collection = null
      vasync.waterfall [
        (cb) ->
          games.initialize callback: (err) -> cb(err)
        (cb) ->
          collection = games.activeGames("rule/v1", "p1")
          collection.fetch cb
      ], (err, results) ->
        expect(err).to.be(null)
        expect(collection.models.length).to.equal(2)
        expect(collection.models[0].id).to.equal("game:1")
        expect(collection.models[1].id).to.equal("game:2")
        done()
      null

# vim: ts=2:sw=2:et:
