defmodule ApiWeb.Auth do
    import Plug.Conn

    alias Core.Repo
    alias Core.Accounts.User

    def init(opts), do: opts

    def call(conn, params) do
      IO.inspect conn
      IO.inspect params

      if conn.assigns[:user] do
        conn
      else
        case Phoenix.Token.verify("ElNO1SCiwmTp7Oxd9gkkv77FQutRdSMOTJvF8UBvT7hW2HrxZorkiPiXYY0xSmFN", "user_id", token, max_age: :infinity) do
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
