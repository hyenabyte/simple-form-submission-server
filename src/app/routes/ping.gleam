import gleam/http
import gleam/json
import gleam/string_tree
import wisp.{type Request, type Response}

pub fn handle_route(req: Request) -> Response {
  case req.method {
    http.Get -> get_response()
    _ -> wisp.method_not_allowed(allowed: [http.Get])
  }
}

fn get_response() {
  json.object([
    #("status", json.string("ok")),
    #("message", json.string("pong")),
  ])
  |> json.to_string
  |> string_tree.from_string
  |> wisp.json_response(200)
}
