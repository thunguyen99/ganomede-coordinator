log = require "./log"
aboutApi = require "./about-api"
pingApi = require "./ping-api"
coordinatorApi = require "./coordinator-api"
Games = require "./games"
games = new Games()

addRoutes = (prefix, server) ->
  log.info "adding routes to #{prefix}"

  # Platform Availability
  pingApi.addRoutes prefix, server

  # About
  aboutApi.addRoutes prefix, server

  # Coordinator
  api = coordinatorApi.create
    games: games
  api.addRoutes prefix, server

initialize = (callback) ->
  log.info "initializing backend"

  games.initialize
    callback: callback

destroy = ->
  log.info "destroying backend"

module.exports =
  initialize: initialize
  destroy: destroy
  addRoutes: addRoutes
  log: log

# vim: ts=2:sw=2:et:
