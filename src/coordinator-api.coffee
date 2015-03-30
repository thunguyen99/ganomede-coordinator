log = require "./log"
authdb = require "authdb"
restify = require "restify"
config = require '../config'

sendError = (err, next) ->
  log.error err
  next err

postGame = (req, res, next) ->
  res.send ok:true
  next()

addRoutes = (prefix, server) ->
  server.post "/#{prefix}/games", postGame

coordinatorApi = (options = {}) ->

  # configure authdb client
  authdbClient = options.authdbClient || authdb.createClient(
    host: config.authdb.host
    port: config.authdb.port)

  # the games collection
  games = options.games

  return addRoutes: addRoutes

module.exports =
  create: coordinatorApi

# vim: ts=2:sw=2:et:
