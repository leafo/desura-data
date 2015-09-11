
config = require "lapis.config"

config "development", ->
  postgres {
    database: "desura_data"
  }

