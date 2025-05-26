import app/db
import app/web
import gleam/dynamic/decode
import gleam/http
import gleam/json
import gleam/result
import gleam/string_tree
import wisp.{type Request, type Response}

pub fn handle_route(req: Request, ctx: web.Context) -> Response {
  case req.method {
    http.Post -> get_response(req, ctx)
    _ -> wisp.method_not_allowed(allowed: [http.Post])
  }
}

fn get_response(req: Request, ctx: web.Context) -> Response {
  use json_data <- wisp.require_json(req)
  use <- wisp.require_method(req, http.Post)

  let result = {
    use person <- result.try(decode.run(json_data, db.form_submission_decoder()))

    // FIXME: error handling
    let _ = db.insert_form_submission(person, ctx.db)

    Ok(person)
  }

  case result {
    Ok(_) ->
      json.object([#("status", json.string("ok"))])
      |> json.to_string
      |> string_tree.from_string
      |> wisp.json_response(200)
    Error(_) -> wisp.unprocessable_entity()
  }
}
