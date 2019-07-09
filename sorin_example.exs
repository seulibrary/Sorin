# This file should be in .gitignore!
use Mix.Config

### Search
config :search,
  search_target: SorinWorldcat

### Search target
wskey =
  System.get_env("WSKEY") ||
    raise """
    environment variable WSKEY is missing.
    """
config :sorin_worldcat,
  wskey: wskey,
  result_format: "&recordSchema=info%3Asrw%2Fschema%2F1%2Fdc"

### Front end
config :frontend,
  settings: %{
    # Caution: these settings will be visible in the browser!
    app_name: "Sorin",  
    url: "https://your_url.edu",
    admin_email: "",
    api_port: 8080}

### File storage
access_key_id =
  System.get_env("ACCESS_KEY_ID") ||
    raise """
    environment variable ACCESS_KEY_ID is missing.
    """
secret_access_key =
  System.get_env("SECRET_ACCESS_KEY") ||
    raise """
    environment variable SECRET_ACCESS_KEY is missing.
    """
config :ex_aws,
  access_key_id: access_key_id,
  secret_access_key: secret_access_key,
  region: "REGIONNAME",
  bucket: "BUCKETNAME",
  link_root: "https://s3.amazonaws.com/your_bucket/",
  disk_quota: 1000000000 # 1 gigabyte

### Secret keys
secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """
config :api, ApiWeb.Endpoint,
  secret_key_base: secret_key_base
config :frontend, FrontendWeb.Endpoint,
  secret_key_base: secret_key_base
