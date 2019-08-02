defmodule ApiWeb.AuthToken do
    import Plug.Conn

    alias Core.Repo
    alias Core.Accounts.User

    def init(opts), do: opts

    def call(conn, params) do
      case get_auth_token(conn) do
        {:ok, token} ->
          conn
          |> assign(:token, token.token)
          |> assign(:user_id, token.user_id)
        error ->
          conn
          |> put_status(:unauthorized)
          |> Phoenix.Controller.render(ApiWeb.ErrorView, "401.json")
          |> halt
      end
    end

    defp get_auth_token(conn) do
      case extract_token(conn) do
        {:ok, token} -> verify_token(token)
        error -> error
      end
    end

    defp extract_token(conn) do
      case Plug.Conn.get_req_header(conn, "authorization") do
        [auth_header] -> get_token_from_header(auth_header)
        _ -> {:error, :missing_auth_header}
      end
    end

    defp get_token_from_header(auth_header) do
      {:ok, reg} = Regex.compile("Bearer\:?\s+(.*)$", "i")
      case Regex.run(reg, auth_header) do
        [_, match] -> {:ok, String.trim(match)}
        _ -> {:error, :unauthorized}
      end
    end

    defp verify_token(token) do
      case Core.AuthTokens.get_auth_token(%{key: token}) do
        nil ->
          {:error, :unauthorized}
        token_struct ->
          #TODO Add use / logs into a new token use database

          Core.AuthTokens.update_auth_token(token_struct, %{count: token_struct.use_count + 1})
          {:ok, token_struct}
      end
    end
end
