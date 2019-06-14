defmodule ApiWeb.AuthController do
    use ApiWeb, :controller

    plug Ueberauth

    alias Core.Accounts.User
    alias Core.Repo
    alias Ueberauth.Strategy.Helpers

    def request(conn, _params) do
      render(conn, "request.html", callback_url: Helpers.callback_url(conn))
    end

    def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
      fullname = auth.info.first_name <> " " <> auth.info.last_name
      user_params = %{fullname: fullname, email: auth.info.email}
      changeset = User.changeset(%User{}, user_params)

      create(conn, changeset)
    end

    def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
      conn
      |> put_flash(:error, "Failt to authenticate.")
      |> redirect(to: "/")
    end

    def delete(conn, _params) do
      conn
      |> configure_session(drop: true)
      |> redirect(to: "/")
    end

    defp create(conn, changeset) do
      case insert_or_update_user(changeset) do
        {:ok, user} ->
          user_id_token = Phoenix.Token.sign(conn, "user_id", user.id)

          Api.GoogleToken.save_auth_token(user, conn.assigns.ueberauth_auth.extra.raw_info.token)

          conn
          |> put_session(:user_id, user_id_token)
          |> configure_session(renew: true)
          |> redirect(to:  "/")
        {:error, reason} ->
          conn
          |> put_flash(:error, reason)
          |> redirect(to: "/")
      end
    end

    defp insert_or_update_user(changeset) do
      case Repo.get_by(User, email: changeset.changes.email) do
        nil ->
          {:error, "You must be a member of the community to login."}
        user ->
          {:ok, user}
      end
    end 
  end
