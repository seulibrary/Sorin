# This file should be in .gitignore!
use Mix.Config

config :search,
  search_target: SorinWorldcat
  
config :frontend,
  settings: %{
    # Caution: these settings will be visible in the browser!
    app_name: "Sorin",  
    url: "https://your_url.edu",
    admin_email: "",
    api_port: 8080}

config :sorin_worldcat,
  wskey: "WSKEYGOESHERE",
  result_format: "&recordSchema=info%3Asrw%2Fschema%2F1%2Fdc"

config :ex_aws,
  access_key_id: "ACCESSKEYIDGOESHERE",
  secret_access_key: "SECRETACCESSKEY",
  region: "REGIONNAME",
  bucket: "BUCKETNAME",
  link_root: "https://s3.amazonaws.com/your_bucket/",
  disk_quota: 1000000000 # 1 gigabyte

### Secret keys

secret_key_base = ""

config :api, ApiWeb.Endpoint,
  secret_key_base: secret_key_base

config :frontend, FrontendWeb.Endpoint,
  secret_key_base: secret_key_base
