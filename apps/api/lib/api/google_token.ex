defmodule Api.GoogleToken do
  @moduledoc """
  Google Auth Token Management.
  """

  require Logger

  @doc """
  return Google auth token from user and save/update it as needed. This should be called on initial login.
  """
  def save_auth_token(user, auth_token) do
    token = Core.AuthTokens.get_login_token_by_user_id(user.id, "login")

    if token do
      Logger.info "> User Login #{user.email}"

      update_user_auth_token(token, update_token(token, auth_token |> Map.from_struct))
    else
      Logger.info "> New User Login #{user.email}"

      create_user_auth_token(user, auth_token |> Map.from_struct)
    end
  end

  @doc """
  return Google auth token, and handle refreshing if needed.
  """
  def auth_token(user) do
    case get_token(user) do
      {:ok, token} -> {:ok, token}
      {:error, msg} -> {:error, msg}
    end
  end

  @doc """
  Revoke app permissions from Google. This allows you to force the geneartion of a refresh token the next time the user logs in.
  """
  def revoke_token(access_token) do
    "https://accounts.google.com/o/oauth2/revoke?token=#{access_token}"
    |> HTTPoison.post(
      "", [
        {"Content-type", "application/x-www-form-urlencoded"}
      ])
    |> handle_request()
  end

  defp create_user_auth_token(user, auth_token) do
    Core.AuthTokens.create_auth_token(%{token: auth_token, type: "login", user_id: user.id})

    {:ok, auth_token}
  end

  defp update_user_auth_token(auth_token_struct, token) do
    Core.AuthTokens.update_auth_token(auth_token_struct, token: token)

    {:ok, token}
  end

  defp refresh_token(user) do
    response = "https://www.googleapis.com/oauth2/v4/token?" <>
      "client_id=" <> Application.get_env(:ueberauth, Ueberauth.Strategy.Google.OAuth)[:client_id] <>
      "&client_secret=" <> Application.get_env(:ueberauth, Ueberauth.Strategy.Google.OAuth)[:client_secret] <>
      "&refresh_token=" <> user.auth_token["refresh_token"] <>
      "&grant_type=refresh_token"
      |> HTTPoison.post("",  [])

    case handle_request(response) do
      {:ok, body} ->
        Logger.info "> User #{user.email} token refresh"

        updated_token = user.auth_token
        |> update_refresh_token(body)

        {:ok, update_user_auth_token(user, updated_token)}
      {:error, body} ->
        Logger.info"> Token Not Refeshed #{user.auth_tokn} #{IO.inspect body}"

        {:error, body}
    end
  end

  defp update_token(auth_token, new_token) do
    auth_token
    |> update_token_field(:access_token, new_token.access_token)
    |> update_token_field(:expires_at, new_token.expires_at)
    |> update_token_field(:refresh_token, new_token.refresh_token)
  end

  defp update_refresh_token(auth_token, refreshedToken) do
    auth_token
    |> update_token_field("access_token", refreshedToken["access_token"])
    |> update_token_field("expires_at", refreshedToken["expires_in"] + (DateTime.utc_now |> DateTime.to_unix))
  end

  defp update_token_field(auth_token, _field, nil), do: auth_token

  defp update_token_field(auth_token, field, data) do
    Map.put(auth_token, field, data)
  end

  defp get_token(user) do
    case check_expiration(user.auth_token["expires_at"]) do
      :expired ->
        Logger.info "> Refresh token"

        case refresh_token(user) do
          {:ok, token} -> 
            {:ok, token["access_token"]}
          {:error, msg} -> {:error, %{msg: msg}}
        end
      _ ->
        Logger.info "> Get user token."
        {:ok, user.auth_token["access_token"]}
    end
  end

  defp check_expiration(expiration) do
    if DateTime.utc_now |> DateTime.to_unix > expiration, do: :expired
  end

  defp handle_request({:ok, %{status_code: 200, body: body}}) do
    {:ok, Jason.decode!(body)}
  end

  defp handle_request({:ok, %{status_code: _, body: body}}) do
    {:error, Jason.decode!(body)}
  end

  defp handle_request(_params) do
    Logger.error "> Something Bad Happened."
    {:error, "ERROR ERROR ERROR"}
  end
end
