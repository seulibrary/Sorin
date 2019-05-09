defmodule FrontendWeb.PageController do
  use FrontendWeb, :controller

  def index(conn, _params) do
    user_id = case Phoenix.Token.verify(conn, "user_id", get_session(conn, :user_id), max_age: 86400) do
      {:ok, _} -> get_session(conn, :user_id)
      {:error, :expired} -> nil
      {:error, _} -> nil
    end
    
    render conn, "index.html", token: get_csrf_token(), current_user: user_id
  end
end
