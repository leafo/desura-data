import Model, enum from require "lapis.db.model"

class DailyViews extends Model
  @primary_key: {"object_type", "object_id", "date"}

  @object_types: enum {
    game: 1
  }


