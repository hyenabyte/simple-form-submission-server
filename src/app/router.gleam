import app/routes/admin
import app/routes/ping
import app/routes/signup
import app/web
import gleam/string_tree
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: web.Context) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    [] ->
      "<h1>Cool you found me, you are not supposed to be here</h1>"
      |> string_tree.from_string
      |> wisp.html_response(200)
    ["ping"] -> ping.handle_route(req)
    ["signup"] -> signup.handle_route(req, ctx)
    ["admin"] -> admin.handle_route(req, ctx)
    _ -> wisp.not_found()
  }
}
