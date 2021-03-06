use Mix.Config

################ API ####################
# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.
#
# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :api, ApiWeb.Endpoint,
  http: [:inet6, port: 8080],
  url: [host: "localhost", port: 8080], # This is critical for ensuring web-sockets properly authorize.
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Application.spec(:api, :vsn)

################ FRONTEND ####################
# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.
#
# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :frontend, FrontendWeb.Endpoint,
  http: [:inet6, port: 4000],
  url: [host: "localhost", port: 4000], # This is critical for ensuring web-sockets properly authorize.
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Application.spec(:frontend, :vsn)

################ META ####################
# Do not print debug messages in production
config :logger, level: :info

# Import prod.secret.exs, which loads secrets and
# configuration from environment variables.
import_config "prod.secret.exs"
