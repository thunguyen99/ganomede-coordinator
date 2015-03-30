config = require "../config"

# TODO (eventually)
# ping the servers, select one with a low ping
# code from registry can be reused

module.exports =
  random: ->
    rnd = Math.floor(Math.random() * 999999)
    config.gameServers[rnd % config.gameServers.length]

# vim: ts=2:sw=2:et:
