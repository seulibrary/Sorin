# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

################ CORE ####################
database_username =
  System.get_env("PROD_DATABASE_USERNAME") ||
    raise """
    environment variable PROD_DATABASE_USERNAME is missing.
    """
database_password =
  System.get_env("PROD_DATABASE_PASSWORD") ||
    raise """
    environment variable PROD_DATABASE_PASSWORD is missing.
    """
database_name =
  System.get_env("PROD_DATABASE_NAME") ||
    raise """
    environment variable PROD_DATABASE_NAME is missing.
    """
database_hostname =
  System.get_env("PROD_DATABASE_HOSTNAME") ||
    raise """
    environment variable PROD_DATABASE_HOSTNAME is missing.
    """
database_pool_size =
  System.get_env("PROD_DATABASE_POOL_SIZE") ||
    raise """
    environment variable PROD_DATABASE_POOL_SIZE is missing.
    """
config :core, Core.Repo,
  username: database_username,
  password: database_password,
  database: database_name,
  hostname: database_hostname,
  pool_size: String.to_integer(database_pool_size)
