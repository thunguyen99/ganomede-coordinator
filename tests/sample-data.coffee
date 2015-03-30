createGame = (id, p1, p2) ->
  _id: id
  type: "rule/v1",
  players: [ p1, p2 ]
  status: "active"
  url: "http://fovea.cc"

docs = [
  createGame "0000000000000000001", "p1", "p2"
  createGame "0000000000000000002", "p3", "p1"
  createGame "0000000000000000003", "p2", "p3"
]

module.exports =
  docs: docs

  users:
    p1:
      token: 'p1-token'
      account: {username: 'p1'}

    p2:
      token: 'p2-token'
      account: {username: 'p2'}

# vim: ts=2:sw=2:et:
