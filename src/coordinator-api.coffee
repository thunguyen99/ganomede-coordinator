log = require "./log"
authdb = require "authdb"
restify = require "restify"
config = require '../config'
gameServers = require './game-servers'

sendError = (err, next) ->
  log.error err
  next err

class CoordinatorApi
  constructor: (options = {}) ->

    # configure authdb client
    @authdbClient = options.authdbClient || authdb.createClient(
      host: config.authdb.host
      port: config.authdb.port)

    # games collection
    @games = options.games

    @gameServers = options.gameServers || gameServers

  addRoutes: (prefix, server) ->

    #
    # Middlewares
    #

    # Populates req.params.user with value returned from authDb.getAccount()
    authMiddleware = (req, res, next) =>
      authToken = req.params.authToken
      if !authToken
        err = new restify.InvalidContentError('invalid content')
        return sendError(err, next)

      @authdbClient.getAccount authToken, (err, account) ->
        if err || !account
          err = new restify.UnauthorizedError('not authorized')
          return sendError(err, next)

        req.params.user = account
        next()

    # Populates req.params.game with the GameModel of ID given by req.params.id
    gameMiddleware = (req, res, next) =>
      game = @games.newModel id:req.params.id
      game.fetch (err) ->
        if err
          log.error err
          return sendError err, next
        username = req.params.user.username
        if !(true for p in game.players when p == username).length
          err = new restify.UnauthorizedError('not authorized')
          return sendError err, next
        req.params.game = game
        next()

    #
    # API Calls
    #

    # GET /active-games
    getActiveGames = (req, res, next) =>
      type = "#{req.params.type}/#{req.params.version}"
      collection = @games.activeGames type, req.params.user.username
      collection.fetch (err) ->
        if err
          return sendError err, next
        res.send (m.toJSON() for m in collection.models)
        next()

    # GET /games/:id
    getGame = (req, res, next) =>
      res.send req.params.game.toJSON()
      next()

    # POST /games
    postGame = (req, res, next) =>
      body = req.body
      hasPlayers = body?.players?.length
      username = req.params.user.username
      if (!hasPlayers or body.players[0] != username)
        err = new restify.InvalidContentError('invalid content')
        return sendError err, next
      model = @games.newModel
        status: "inactive"
        url: @gameServers.random()
        type: "#{req.params.type}/#{req.params.version}"
        players: req.body.players
        waiting: (p for p in body.players when p != username)
      model.save (err) ->
        if err
          return sendError(err, next)
        res.send model.toJSON()
        next()

    # POST /games/:id/activation
    postActivation = (req, res, next) =>
      username = req.params.user.username
      game = req.params.game
      isInactive = (game.status == "inactive")
      isWaiting = (true for p in game.waiting when p == username).length
      if !isInactive or !isWaiting
        err = new restify.InvalidContentError('invalid content')
        return sendError err, next
      game.waiting = (p for p in game.waiting when p != username)
      if game.waiting.length == 0
        delete game.waiting
        game.status = "active"
      game.save (err) ->
        if err
          return sendError(err, next)
        res.send game.toJSON()
        next()
        # TODO: Send notification

    server.get "#{prefix}/auth/:authToken/games/:id",
      authMiddleware, gameMiddleware, getGame

    server.post "#{prefix}/auth/:authToken/games/:id/activation",
      authMiddleware, gameMiddleware, postActivation

    root = "/#{prefix}/auth/:authToken/:type/:version"
    server.get "#{root}/active-games", authMiddleware, getActiveGames
    server.post "#{root}/games", authMiddleware, postGame

module.exports =
  create: (options = {}) -> new CoordinatorApi(options)

# vim: ts=2:sw=2:et:
