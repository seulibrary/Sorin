use Mix.Config

################ CORE ####################
config :core, Core.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "core_dev",
  hostname: "localhost",
  pool_size: 10
