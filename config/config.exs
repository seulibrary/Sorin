# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

################ API ####################
config :api,
  namespace: Api

# Configures the endpoint
config :api, ApiWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ApiWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Api.PubSub, adapter: Phoenix.PubSub.PG2]

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [
      prompt: "select_account",
      access_type: "offline",
      include_granted_scopes: true,
      default_scope: "email profile https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/drive.appdata"
      ]},
    identity: {Ueberauth.Strategy.Identity, [scrub_params: false, callback_methods: ["POST"]]}
  ]

################ META ####################
# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import configuration from sorin.exs
import_config "sorin.exs"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
