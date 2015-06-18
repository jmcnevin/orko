# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for third-
# party users, it should be done in your mix.exs file.

# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

config :orko, Orko.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "orko_development"

config :orko, Orko.Bot,
  weather_url: "https://api.forecast.io/forecast/1d1054585405ccbe9288707b6a4072da/44.96623,-93.34575",
  chuck_norris_url: "http://api.icndb.com/jokes/random",
  random_number_url: "https://qrng.anu.edu.au/API/jsonI.php?length=1&type=uint16"

