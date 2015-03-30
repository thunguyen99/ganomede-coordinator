# Views
views = do () ->
  result = {}
  funcs =
    'active_games':
      map: (doc) ->
        if doc.status == 'active' and doc.players?.length
          for player in doc.players
            emit [doc.type, player, doc._id],
              id: doc._id
              type: doc.type
              players: doc.players
              url: doc.url

  for own view, mapReduce of funcs
    result[view] =
      map: String(mapReduce.map)

  return result

module.exports = views
# vim: ts=2:sw=2:et:
