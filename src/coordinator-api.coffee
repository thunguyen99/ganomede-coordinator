postGame = (req, res, next) ->
  res.send ok:true
  next()

postMove = (req, res, next) ->
  res.send ok:true
  next()

addRoutes = (prefix, server) ->
  server.post "/#{prefix}/games", postGame
  server.post "/#{prefix}/moves", postMove

coordinatorApi = (options = {}) ->
  return addRoutes: addRoutes

module.exports =
  create: coordinatorApi

# vim: ts=2:sw=2:et:
