use Mix.Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: "CLIENT_ID_GOES_HERE",
  client_secret: "CLIENT_SECRET_GOES_HERE"