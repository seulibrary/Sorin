defmodule ApiWeb.AuthController do
    use ApiWeb, :controller

    plug Ueberauth

    alias Core.Accounts.User
    alias Core.Repo

    def new(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
      fullname = auth.info.first_name <> " " <> auth.info.last_name
      user_params = %{fullname: fullname, email: auth.info.email}
      changeset = User.changeset(%User{}, user_params)

      create(conn, changeset)
    end

    def new(conn, _params) do
      conn
      |> redirect(to: "/")
    end

    def create(conn, changeset) do
      case insert_or_update_user(changeset) do
        {:ok, user} ->
          user_id_token = Phoenix.Token.sign(conn, "user_id", user.id)
          
          Api.GoogleToken.save_auth_token(user, conn.assigns.ueberauth_auth.extra.raw_info.token)

          conn
          |> put_session(:user_id, user_id_token)
          |> redirect(to:  "/")
        {:error, reason} ->
          conn
          |> put_flash(:error, reason)
          |> redirect(to: "/")
      end
    end

    def delete(conn, _params) do
      conn
      |> configure_session(drop: true)
      |> redirect(to: "/")
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
