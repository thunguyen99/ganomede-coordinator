gameID = 1
nextGameID = () -> "game:#{gameID++}"

createGame = () ->
  _id: nextGameID()
  type: "rule/v1",
  players: [ "p1", "p2" ]
  status: "inactive"

docs = [
  createGame()
  createGame()
]

module.exports =
  docs: docs
# vim: ts=2:sw=2:et:
