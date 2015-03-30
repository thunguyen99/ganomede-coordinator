log = require "./log"
authdb = require "authdb"
restify = require "restify"
config = require '../config'

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

    #
    # API Calls
    #

    getActiveGames = (req, res, next) =>
      type = "#{req.params.type}/#{req.params.version}"
      collection = @game.activeGames type, req.params.user.username
      collection.fetch (err) ->
        if err
          return sendError err, next
        res.send collection.models.toCouch()
        next()

    postGame = (req, res, next) =>
      res.send ok:true
      next()

    root = "/#{prefix}/auth/:authToken/:type/:version"
    server.get "#{root}/active-games", authMiddleware, getActiveGames
    server.post "/#{root}/games", authMiddleware, postGame

module.exports =
  create: (options = {}) -> new CoordinatorApi(options)

# vim: ts=2:sw=2:et:
