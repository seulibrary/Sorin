defmodule ApiWeb.Auth do
    import Plug.Conn

    alias Core.Repo
    alias Core.Accounts.User

    def init(opts), do: opts

    def call(conn, params) do
      if conn.assigns[:user] do
        conn
      else
        case Phoenix.Token.verify(conn, "user_id", get_session(conn, :user_id), max_age: 86400) do
          {:ok, id} ->
            cond do
              user = id && Repo.get(User, id) ->
                conn
                |> assign(:user, user)
                |> assign(:user_id, Phoenix.Token.sign(conn, "user_id", user.id))
              true ->
                conn
                |> assign(:user, nil)
            end
          {_, _} -> 
            assign(conn, :user, nil)
        end
      end
    end
end
