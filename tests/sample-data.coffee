createGame = (id) ->
  _id: id
  type: "rule/v1",
  players: [ "p1", "p2" ]
  status: "inactive"

docs = [
  createGame "game:1"
  createGame "game:2"
]

module.exports =
  docs: docs
# vim: ts=2:sw=2:et:
