use Mix.Config

################ CORE ####################
# Configure your database
config :core, Core.Repo,
  username: "postgres",
  password: "postgres",
  database: "core_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

################ META ####################
# Print only warnings and errors during test
config :logger, level: :warn
