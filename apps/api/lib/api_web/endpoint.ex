defmodule ApiWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :api

  socket "/socket", ApiWeb.UserSocket,
    websocket: true,
    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :api,
    gzip: true,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_sorin_key",
    signing_salt: "UWttxbZF"

  #plug CORSPlug, origin: ["http://localhost:4000", "http://localhost:8000"] Close access
  # plug Corsica, origins: ~r{^(.*.?)localhost(.*.?)$}
  plug Corsica, origins: "*", allow_headers: ["accept", "content-type", "x-csrf-token"], expose_headers: ["x-filename",], log: [accepted: :debug, rejected: :info, invalue: :debug], allow_credentials: true

  plug ApiWeb.Router
end
