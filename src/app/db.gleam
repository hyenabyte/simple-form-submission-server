import envoy
import gleam/dynamic/decode
import gleam/result
import gleam/time/calendar
import gleam/time/timestamp
import sqlight

pub type FormSubmission {
  FormSubmission(
    name: String,
    email: String,
    phone: String,
    count: Int,
    lunch: Bool,
    dinner: Bool,
    breakfast: Bool,
    info: String,
  )
}

pub fn form_submission_decoder() -> decode.Decoder(FormSubmission) {
  use name <- decode.field("name", decode.string)
  use email <- decode.field("email", decode.string)
  use phone <- decode.optional_field("phone", "n/a", decode.string)
  use count <- decode.field("count", decode.int)
  use lunch <- decode.optional_field("lunch", False, decode.bool)
  use dinner <- decode.optional_field("dinner", False, decode.bool)
  use breakfast <- decode.optional_field("breakfast", False, decode.bool)
  use info <- decode.optional_field("info", "n/a", decode.string)

  decode.success(FormSubmission(
    name:,
    email:,
    phone:,
    count:,
    lunch:,
    dinner:,
    breakfast:,
    info:,
  ))
}

fn db_entry_decoder() -> decode.Decoder(#(Int, FormSubmission)) {
  use id <- decode.field(0, decode.int)
  use name <- decode.field(1, decode.string)
  use email <- decode.field(2, decode.string)
  use phone <- decode.field(3, decode.string)
  use count <- decode.field(4, decode.int)
  use lunch <- decode.field(5, sqlight.decode_bool())
  use dinner <- decode.field(6, sqlight.decode_bool())
  use breakfast <- decode.field(7, sqlight.decode_bool())
  use info <- decode.field(8, decode.string)

  decode.success(#(
    id,
    FormSubmission(
      name:,
      email:,
      phone:,
      count:,
      lunch:,
      dinner:,
      breakfast:,
      info:,
    ),
  ))
}

pub fn create_database() {
  let database_url =
    envoy.get("DATABASE_URL")
    |> result.unwrap(":memory:")

  let assert Ok(conn) = sqlight.open(database_url)

  let sql =
    "
    CREATE TABLE IF NOT EXISTS main.form_submission (
      id integer primary key,
      name text,
      email text,
      phone text,
      count integer,
      lunch integer,
      dinner integer,
      breakfast integer,
      info text,
      createdAt string
    );
    "

  let assert Ok(Nil) = sqlight.exec(sql, conn)

  conn
}

pub fn get_all_form_submissions(connection: sqlight.Connection) {
  "select * from main.form_submission;"
  |> sqlight.query(connection, [], db_entry_decoder())
}

pub fn insert_form_submission(
  data: FormSubmission,
  connection: sqlight.Connection,
) {
  let _ = echo connection
  "
    insert into main.form_submission (name, email, phone, count, lunch, dinner, breakfast, info, createdAt) values
    (
      ?,
      ?,
      ?,
      ?,
      ?,
      ?,
      ?,
      ?,
      ?
    );
  "
  |> sqlight.query(
    connection,
    [
      sqlight.text(data.name),
      sqlight.text(data.email),
      sqlight.text(data.phone),
      sqlight.int(data.count),
      sqlight.bool(data.lunch),
      sqlight.bool(data.dinner),
      sqlight.bool(data.breakfast),
      sqlight.text(data.info),
      sqlight.text(
        timestamp.system_time() |> timestamp.to_rfc3339(calendar.utc_offset),
      ),
    ],
    decode.success(Nil),
  )
}
