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
              rev: doc._rev
              type: doc.type
              players: doc.players
              url: doc.url
              status: "active"
        if doc.status == 'gameover' and doc.viewers?.length
          for player in doc.viewers
            emit [doc.type, player, doc._id],
              id: doc._id
              rev: doc._rev
              type: doc.type
              players: doc.players
              url: doc.url
              status: "gameover"

  for own view, mapReduce of funcs
    result[view] =
      map: String(mapReduce.map)

  return result

module.exports = views
# vim: ts=2:sw=2:et:
