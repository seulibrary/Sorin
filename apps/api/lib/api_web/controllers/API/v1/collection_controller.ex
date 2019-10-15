defmodule ApiWeb.V1.CollectionController do
  use ApiWeb, :controller

  alias Core.Collections
  alias ApiWeb.{CollectionView, ErrorView}

  action_fallback ApiWeb.FallbackController

  def show(conn, %{"id" => id} = _params) do
    case List.first(Collections.get_permalink_view(id)) do
      nil ->
        conn
        |> put_status(404)
        |> put_view(ErrorView)
        |> render("404.json")

      collection ->
        conn
        |> put_view(CollectionView)
        |> render("collection.json", collection: collection)
    end
  end

  def show(conn, _params) do
    conn
    |> put_status(404)
    |> put_view(ErrorView)
    |> render("404.json")
  end

  def create(conn, %{"title" => title}) do
    user_id = conn.assigns.user_id

    case Core.Collections.new_collection(user_id, title) do
      {:ok, collection} ->
        FrontendWeb.Endpoint.broadcast!(
          "dashboard:#{user_id}",
          "add_collection_to_dashboard",
          CollectionView.render("dashboardCollection.json",
            collection: collection
          )
        )

        conn
        |> put_status(:created)
        |> put_view(CollectionView)
        |> render("dashboardCollection.json", collection: collection)

      _ ->
        conn
        |> put_status(500)
        |> put_view(ErrorView)
        |> render("500.json")
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(400)
    |> render(ErrorView, "400.json")
  end
end
