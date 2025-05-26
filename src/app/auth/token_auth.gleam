import envoy
import gleam/http/request
import wisp.{type Request, type Response}

pub fn handle_token_auth(
  req: Request,
  handle_request: fn(Request) -> Response,
) -> Response {
  case wisp.path_segments(req) {
    ["admin"] ->
      case check_token(req) {
        False -> wisp.response(403)
        True -> handle_request(req)
      }
    _ -> handle_request(req)
  }
}

fn check_token(req: Request) -> Bool {
  let token = request.get_header(req, "Authorization")
  let token_cmp = envoy.get("ADMIN_TOKEN")

  case token, token_cmp {
    Ok(token), Ok(token_cmp) -> {
      token == { "Bearer " <> token_cmp }
    }
    _, _ -> False
  }
}
