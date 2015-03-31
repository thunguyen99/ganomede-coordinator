assert = require "assert"
vasync = require 'vasync'
expect = require 'expect.js'
supertest = require 'supertest'

config = require '../config'
fakeAuthdb = require './fake-authdb'
helpers = require './helpers'
samples = require './sample-data'
server = require '../src/server'
Games = require '../src/games'

coordinatorApi = require "../src/coordinator-api"

go = supertest.bind(supertest, server)

endpoint = (path) ->
  return "/#{config.routePrefix}#{path || ''}"

describe "Coordinator API", ->

  authdb = fakeAuthdb.createClient()

  before (done) ->
    for own username, data of samples.users
      authdb.addAccount data.token, data.account

    games = new Games
    games.initialize callback: (err) ->
      api = coordinatorApi.create
        authdbClient: authdb
        games: games
      api.addRoutes(endpoint(), server)
      server.listen 1337, ->
        helpers.initDb (err, db_) ->
          db = db_
          done(err)

  after (done) ->
    server.close ->
      helpers.dropDb(done)

  describe "GET /games/:id", ->
    it 'returns a game the player is playing', (done) ->
      go()
        .get endpoint("/auth/p1-token/games/0000000000000000001")
        .expect 200
        .end (err, res) ->
          expect(err).to.be(null)
          res.body._id = res.body.id
          delete res.body.id
          expect(res.body).to.eql(samples.docs[0])
          done()

    it "won't return a game the player isn't playing", (done) ->
      go()
        .get endpoint("/auth/p1-token/games/0000000000000000003")
        .expect 401, done

  describe "GET /active-games", ->
    it 'fetches the list of active games', (done) ->
      go()
        .get endpoint("/auth/p1-token/rule/v1/active-games")
        .expect 200
        .end (err, res) ->
          expect(err).to.be(null)
          expect(res.body).to.eql([{
            id: '0000000000000000001'
            type: 'rule/v1'
            players: [ 'p1', 'p2' ]
            url: 'http://fovea.cc'
          }, {
            id: '0000000000000000002'
            type: 'rule/v1'
            players: [ 'p3', 'p1' ]
            url: 'http://fovea.cc'
          }])
          done()

  describe "POST /games", ->
    it 'adds games to the list', (done) ->
      go()
        .post endpoint("/auth/p1-token/rule/v1/games")
        .send samples.postGame
        .expect 200
        .end (err, res) ->
          expect(err).to.be(null)
          samples.postGameRes.id = res.body.id
          expect(res.body).to.eql(samples.postGameRes)
          done()

  describe "POST /games/:id/activation", ->

    it 'allows only waiting players to activate', (done) ->
      id = samples.postGameRes.id
      go()
        .post endpoint("/auth/p3-token/games/#{id}/activation")
        .expect 401, done

    it 'allows waiting players to activate', (done) ->
      id = samples.postGameRes.id
      samples.postGameRes2.id = id
      go()
        .post endpoint("/auth/p2-token/games/#{id}/activation")
        .expect 200
        .end (err, res) ->
          expect(err).to.be(null)
          expect(res.body).to.eql(samples.postGameRes2)
          done()

# vim: ts=2:sw=2:et:
