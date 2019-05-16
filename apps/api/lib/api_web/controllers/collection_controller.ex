defmodule ApiWeb.CollectionController do
  use ApiWeb, :controller

  action_fallback ApiWeb.FallbackController

  def show(conn, %{"id" => id} = _params) do
    case List.first(Core.Collections.get_permalink_view(id)) do
      nil -> 
        conn
        |> put_status(404)
        |> render(ApiWeb.ErrorView, "404.json")

      collection -> 
        conn
        |> render("collection.json", collection: collection)
    end
    
  end

  def show(conn, _params) do
    conn
    |> put_status(404)
    |> render(ApiWeb.ErrorView, "404.json")
  end
end
