defmodule ApiWeb.V1.TokenController do
  use ApiWeb, :controller

  alias Core.AuthTokens

  def index(conn, %{"user" => user}) do
    case Phoenix.Token.verify(conn, "user_id", user) do
      {:ok, user_id} ->
        conn
        |> put_status(200)
        |> render(ApiWeb.API.TokenView,
          data: AuthTokens.get_auth_tokens_by_user_id(user_id, "api")
        )

      {:error, _reason} ->
        conn
        |> put_status(400)
        |> json(%{message: "ERROR: Something Went Wrong!"})
    end
  end

  def create(conn, %{"user" => user}) do
    case Phoenix.Token.verify(conn, "user_id", user) do
      {:ok, user_id} ->
        token = Phoenix.Token.sign(conn, "user_id", user_id)

        with {:ok, %AuthTokens.AuthToken{}} <-
               AuthTokens.create_auth_token(%{token: %{key: token}, user_id: user_id, type: "api"}) do
          conn
          |> put_status(200)
          |> json(%{token: token})
        end

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)

      _ ->
        conn
        |> put_status(400)
        |> json(%{message: "ERROR: Something Went Wrong!"})
    end
  end

  def delete(conn, %{"user" => user, "id" => id}) do
    case Phoenix.Token.verify(conn, "user_id", user) do
      {:ok, _user_id} ->
        # TODO: Move the Core.Repo function to AuthTokens and create a function.
        # TODO: Talk with Casey on new schema / table for auth_tokens for his branch for merge.
        # TODO: Token table should also have a label field for human readabiliy.
        with token when is_map(token) <- AuthTokens.get_auth_token(%{key: id}),
             {:ok, %AuthTokens.AuthToken{}} <- AuthTokens.delete_auth_token(token) do
          conn
          |> put_status(200)
          |> json(%{message: "Token deleted."})
        else
          _ ->
            conn
            |> put_status(400)
            |> json(%{message: "Token not deleted."})
        end

      {:error, _} ->
        conn
        |> put_status(:unauthorized)
    end
  end
end
