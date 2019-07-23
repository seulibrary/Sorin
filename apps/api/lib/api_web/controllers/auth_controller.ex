defmodule ApiWeb.AuthController do
    use ApiWeb, :controller

    plug Ueberauth

    alias Core.Accounts.User
    alias Core.Repo
    alias Ueberauth.Strategy.Helpers

    action_fallback ApiWeb.FallbackController


    def request(conn, _params) do
      # matches for any non existing auth paths.
      conn
      |> redirect(to: "/")
    end

    def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
      fullname = auth.info.first_name <> " " <> auth.info.last_name
      user_params = %{fullname: fullname, email: auth.info.email}
      changeset = User.changeset(%User{}, user_params)
  
      create(conn, changeset, params["state"])
    end

    def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
      conn
      |> put_flash(:error, "Failed to authenticate.")
      |> redirect(to: "/")
    end

    def delete(conn, _params) do
      conn
      |> configure_session(drop: true)
      |> redirect(to: "/")
    end

    defp create(conn, changeset, url_state) do
      case insert_or_update_user(changeset) do
        {:ok, user} ->
          user_id_token = Phoenix.Token.sign(conn, "user_id", user.id)

          Api.GoogleToken.save_auth_token(user, conn.assigns.ueberauth_auth.extra.raw_info.token)
          
          url = ((url_state |> Jason.decode!)["url"]) || "/"

          conn
          |> put_session(:user_id, user_id_token)
          |> configure_session(renew: true)
          |> redirect(to: url)
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
