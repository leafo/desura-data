db = require "lapis.db"

-- bulk_insert Users, {"username", "age"}, {{"hello", 10}, {"world", 12}}
bulk_insert = (model, keys, tuples) ->
  assert next(keys), "missing keys for bulk insert"
  return 0 unless next tuples

  key_list = table.concat [db.escape_identifier key for key in *keys], ", "

  buffer = {
    "insert into #{db.escape_identifier model\table_name!} "
    "(#{key_list}) VALUES"
  }

  {insert: i} = table
  n_tuples = #tuples
  for t_idx=1,n_tuples
    tuple = tuples[t_idx]
    i buffer, " ("
    k = #tuple
    for idx=1,k
      i buffer, db.escape_literal tuple[idx]
      unless idx == k
        i buffer, ", "

    if t_idx == n_tuples
      i buffer, ")"
    else
      i buffer, "), "

  q = table.concat buffer
  res = db.query q
  res and res.affected_rows or 0

{ :bulk_insert }
