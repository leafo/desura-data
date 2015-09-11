db = require "lapis.db"
schema = require "lapis.db.schema"

import add_column, create_index, drop_index, drop_column, create_table from schema

{
  :serial, :boolean, :varchar, :integer, :text, :foreign_key, :double, :time,
  :numeric, :enum, :date
} = schema.types

import run_migrations from require "lapis.db.migrations"

{
  =>
    run_migrations require "moonscrape.migrations"

  =>
    create_table "daily_views", {
      {"object_type", enum}
      {"object_id", integer}
      {"date", date}
      {"count", integer}

      "PRIMARY KEY (object_type, object_id, date)"
    }

  =>
    create_table "games", {
      {"id", serial}

      {"remote_id", varchar}
      {"title", varchar}

      "PRIMARY KEY (id)"
    }
}

