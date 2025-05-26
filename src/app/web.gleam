import app/auth/token_auth
import sqlight
import wisp.{type Request, type Response}

pub type Context {
  Context(db: sqlight.Connection)
}

pub fn middleware(
  req: Request,
  handle_request: fn(Request) -> Response,
) -> Response {
  // Permit browsers to simulate methods other than GET and POST using the
  // `_method` query parameter.
  let req = wisp.method_override(req)

  // Log information about the request and response.
  use <- wisp.log_request(req)

  // Return a default 500 response if the request handler crashes.
  use <- wisp.rescue_crashes

  // Rewrite HEAD requests to GET requests and return an empty body.
  use req <- wisp.handle_head(req)

  // Handle auth of protected routes
  use req <- token_auth.handle_token_auth(req)

  handle_request(req)
}
