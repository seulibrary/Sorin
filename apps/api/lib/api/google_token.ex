defmodule Api.GoogleToken do
  @moduledoc """
  Google Auth Token Management.
  """

  require Logger

  alias Core.AuthTokens

  @doc """
  Receives a user struct and auth token after initial login.

  Retrieves token stored in database. If retreived token does not exist
  create a token. If it does, update the DB with the new token.
  """
  def save_auth_token(user, auth_token) do
    token = AuthTokens.get_login_token_by_user_id(user.id)

    if token do
      Logger.info("> User Login #{user.email}")
      updated_token = update_token(token, auth_token |> Map.from_struct())
      update_user_auth_token(token, updated_token)
    else
      Logger.info("> New User Login #{user.email}")

      create_user_auth_token(user, auth_token |> Map.from_struct())
    end
  end

  @doc """
  Retrieve Auth token in DB.
  """
  def auth_token(user) do
    case get_token(user) do
      {:ok, token} -> {:ok, token}
      {:error, msg} -> {:error, msg}
    end
  end

  @doc """
  Revokes the app (Sorin) permissions from Google on the behalf of a user.
  
  This allows you to force Google to send a refresh token the next time the user
  logs in. This function is helpful while developing, or if there are new
  permissions needed for the applications.
  
  Caution: It also makes the user Accept app permsions on the next login too. 
  """
  def revoke_token(access_token) do
    "https://accounts.google.com/o/oauth2/revoke?token=#{access_token}"
    |> HTTPoison.post("", [
      {"Content-type", "application/x-www-form-urlencoded"}
    ])
    |> handle_request()
  end

  defp create_user_auth_token(user, auth_token) do
    AuthTokens.create_auth_token(%{token: auth_token, type: "login", user_id: user.id})

    {:ok, auth_token}
  end

  defp update_user_auth_token(auth_token_struct, token) do
    AuthTokens.update_auth_token(auth_token_struct, %{token: token})

    {:ok, token}
  end

  @doc """
  Request a new refreshed token on behalf of the user.

  Makes a POST request with the users refresh token, and the applications
  Ueberauth credentials.

  On sucess, update the token in the DB with the newly updated token.
  """
  defp refresh_token(user) do
    token = AuthTokens.get_login_token_by_user_id(user.id)

    response =
      ("https://www.googleapis.com/oauth2/v4/token?" <>
         "client_id=" <>
         Application.get_env(:ueberauth, Ueberauth.Strategy.Google.OAuth)[:client_id] <>
         "&client_secret=" <>
         Application.get_env(:ueberauth, Ueberauth.Strategy.Google.OAuth)[:client_secret] <>
         "&refresh_token=" <>
         token.token["refresh_token"] <>
         "&grant_type=refresh_token")
      |> HTTPoison.post("", [])

    case handle_request(response) do
      {:ok, body} ->
        Logger.info("> User #{user.email} token refresh")

        updated_token =
          token.token
          |> update_refresh_token(body)

        {:ok, update_user_auth_token(user, updated_token)}

      {:error, body} ->
        Logger.info("> Token Not Refeshed #{user.auth_tokn} #{IO.inspect(body)}")

        {:error, body}
    end
  end

  @doc """
  Update the field in the token map.

  The token store in the DB is a map. This is so the field can be flexible and
  be used for other tokens. Plus, it allows us to store multiple fields in one 
  field in the DB.
  """
  defp update_token(auth_token, new_token) do
    auth_token.token
    |> update_token_field("access_token", new_token.access_token)
    |> update_token_field("expires_at", new_token.expires_at)
    |> update_token_field("refresh_token", new_token.refresh_token)
  end

  defp update_refresh_token(auth_token, refreshedToken) do
    auth_token.token
    |> update_token_field("access_token", refreshedToken["access_token"])
    |> update_token_field(
      "expires_at",
      refreshedToken["expires_in"] + (DateTime.utc_now() |> DateTime.to_unix())
    )
  end

  @doc """
  If no field, and the data is nil, return token as-is.
  """
  defp update_token_field(auth_token, _field, nil), do: auth_token

  @doc """
  Update auth_token map with field and data passed in.
  """
  defp update_token_field(auth_token, field, data) do
    Map.put(auth_token, field, data)
  end

  @doc """
  Get token by user_id. 

  If token is expired, refresh the token.
  """
  defp get_token(user) do
    auth_token = AuthTokens.get_login_token_by_user_id(user.id)

    case check_expiration(auth_token.token["expires_at"]) do
      :expired ->
        Logger.info("> Refresh token")

        case refresh_token(user) do
          {:ok, token} ->
            {:ok, token["access_token"]}

          {:error, msg} ->
            {:error, %{msg: msg}}
        end

      _ ->
        Logger.info("> Get user token.")
        {:ok, auth_token.token["access_token"]}
    end
  end

  @doc """
  A helper function that checks if the time passed in is expired.
  """
  defp check_expiration(expiration) do
    if DateTime.utc_now() |> DateTime.to_unix() > expiration, do: :expired
  end

  @doc """
  A helper function that decodes the json body if the status code returned
  from the http request is 200. Returns an :ok tuple.
  """
  defp handle_request({:ok, %{status_code: 200, body: body}}) do
    {:ok, Jason.decode!(body)}
  end

  @doc """
  A helper function that decodes the json body if any other status code is
  returned. Retuns an :error tuple.
  """
  defp handle_request({:ok, %{status_code: _, body: body}}) do
    {:error, Jason.decode!(body)}
  end

  @doc """
  A helper function that returns an error if anything is returned in the request
  that does not match the above. Returns and :error tuple.
  """
  defp handle_request(_params) do
    Logger.error("> Something Bad Happened.")
    {:error, "ERROR ERROR ERROR"}
  end
end
