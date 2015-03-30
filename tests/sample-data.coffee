createGame = (id, p1, p2) ->
  _id: id
  type: "rule/v1",
  players: [ p1, p2 ]
  status: "active"
  url: "http://fovea.cc"

docs = [
  createGame "game:1", "p1", "p2"
  createGame "game:2", "p3", "p1"
  createGame "game:3", "p2", "p3"
]

module.exports =
  docs: docs
# vim: ts=2:sw=2:et:
