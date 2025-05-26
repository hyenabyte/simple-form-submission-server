import app/db
import app/web.{type Context}
import gleam/http
import gleam/json
import gleam/list
import wisp.{type Request, type Response}

pub fn handle_route(req: Request, ctx: Context) -> Response {
  case req.method {
    http.Get -> get_response(req, ctx)
    _ -> wisp.method_not_allowed(allowed: [http.Get])
  }
}

fn get_response(_req: Request, ctx: Context) -> Response {
  case db.get_all_form_submissions(ctx.db) {
    Error(_) -> wisp.no_content()
    Ok(data) -> {
      data
      |> list.map(fn(entry) {
        let entry_data = entry.1
        [
          #("id", json.int(entry.0)),
          #("name", json.string(entry_data.name)),
          #("email", json.string(entry_data.email)),
          #("phone", json.string(entry_data.phone)),
          #("count", json.int(entry_data.count)),
          #("lunch", json.bool(entry_data.lunch)),
          #("dinner", json.bool(entry_data.dinner)),
          #("breakfast", json.bool(entry_data.breakfast)),
          #("info", json.string(entry_data.info)),
        ]
      })
      |> json.array(of: json.object)
      |> json.to_string_tree
      |> wisp.json_response(200)
    }
  }
}
