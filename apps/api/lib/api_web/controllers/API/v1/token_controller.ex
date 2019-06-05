defmodule ApiWeb.V1.TokenController do
  use ApiWeb, :controller

  alias Core.Auth

  def create_token(conn, %{"user" => user}) do
    case Phoenix.Token.verify(conn, "user_id", user) do
      {:ok, user_id} ->
        token = Phoenix.Token.sign("ElNO1SCiwmTp7Oxd9gkkv77FQutRdSMOTJvF8UBvT7hW2HrxZorkiPiXYY0xSmFN", "user_id", user_id)

        Auth.create_auth_token(%{
              token: token,
              user_id: user_id,
              type: "api"})

        conn
        |> json(%{token: token})

      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{error: reason})

      _ ->
        conn
        |> put_status(400)
        |> json(%{message: "ERROR: Something Went Wrong!"})
    end
  end

  def delete_token(conn, %{"token" => token}) do
    conn
#    Auth.delete_auth_token(
#      Auth.get_auth_token!(token)
#    )
  end

  def manage_tokens(conn, %{"user" => user}) do
    conn
# case Phoenix.Token.verify(conn, "user_id", user) do
# :ok, user_id} ->
#  secret_key = Phoenix.Token.sign(ApiWeb.Endpoint, "Punch it.", user_id, key_length: 256)
#
#  {_status, token, claims} = Guardian.encode_and_sign(%{id: user}, %{})
#
#  Core.Accounts.update_user(
#    Core.Repo.get_by!(Core.Accounts.User, id: user_id),
#    %{token: secret_key})
#
#  conn
#  |> json(%{token: token, claims: claims})
#  ->
#  conn
#  |> put_status(400)
#  |> json(%{message: "ERROR: User Not Verified"})
#
  end

  def manage_tokens(conn, %{"token" => token, "refresh" => true}) do
    conn
 #   case ApiWeb.Guardian.refresh(token) do
 #     {:ok,  _old_stuff, {new_token, new_claims}} ->
 #       conn
 #       |> json(%{new_token: new_token, claims: new_claims})
 #     {:error, reason} ->
 #       conn
 #       |> put_status(400)
 #       |> json(%{error: reason})
 #   end
  end

  def refresh_token() do
    {:ok, "refreshed"}
  end
end
