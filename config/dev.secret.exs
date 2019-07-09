# In this file, we load development configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

ueberauth_client_id =
  System.get_env("UEBERAUTH_CLIENT_ID") ||
    raise """
    environment variable UEBERAUTH_CLIENT_ID is missing.
    """

ueberauth_client_secret =
  System.get_env("UEBERAUTH_CLIENT_SECRET") ||
    raise """
    environment variable UEBERAUTH_CLIENT_SECRET is missing.
    """

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: ueberauth_client_id,
  client_secret: ueberauth_client_secret
