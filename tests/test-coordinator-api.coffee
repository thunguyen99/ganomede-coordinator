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

describe "CoordinatorApi", ->
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

  describe "POST /games", ->
    it 'should be tested', ->
      #go()
      #  .post endpoint("/auth/alice-token/rules/v1/games")

  describe "GET /active-games", ->
    it 'fetches the list of active games', (done) ->
      go()
        .get endpoint("/auth/p1-token/rule/v1/active-games")
        .expect 200
        .end (err, res) ->
          expect(err).to.be(null)
          expect(res.body[0].rev).not.to.be(null)
          expect(res.body[1].rev).not.to.be(null)
          rev0 = res.body[0].rev
          rev1 = res.body[1].rev
          expect(res.body).to.eql([{
            id: '0000000000000000001'
            rev: rev0
            type: 'rule/v1'
            players: [ 'p1', 'p2' ]
            url: 'http://fovea.cc'
          }, {
            id: '0000000000000000002'
            rev: rev1
            type: 'rule/v1'
            players: [ 'p3', 'p1' ]
            url: 'http://fovea.cc'
          }])
          done()

# vim: ts=2:sw=2:et:
