defmodule ApiWeb.V1.CollectionController do
  use ApiWeb, :controller

  alias Core.Dashboard
  alias Core.Collections
  alias ApiWeb.CollectionView

  action_fallback ApiWeb.FallbackController

  def show(conn, %{"id" => id} = _params) do
<<<<<<< HEAD
    case List.first(Collections.get_permalink_view(id)) do
=======
    case List.first(Core.Collections.get_permalink_view(id)) do
>>>>>>> 3f0900e... move files to branch
      nil -> 
        conn
        |> put_status(404)
        |> render(ApiWeb.ErrorView, "404.json")

<<<<<<< HEAD
      collection ->
        conn
        |> put_view(CollectionView)
        |> render("collection.json", collection: collection)
=======
      collection -> 
        conn
        |> render(CollectionView, "collection.json", collection: collection)
>>>>>>> 3f0900e... move files to branch
    end
  end

  def show(conn, _params) do
    conn
    |> put_status(404)
<<<<<<< HEAD
    |> put_view(ApiWeb.ErrorView)
    |> render("404.json")
  end

  def create(conn, %{"title" => title}) do
    user_id = conn.assigns.user_id

    case Dashboard.Collections.new_collection(user_id, title) do
      {:ok, collection} ->
        FrontendWeb.Endpoint.broadcast!(
          "dashboard:#{user_id}",
          "add_collection_to_dashboard",
          ApiWeb.CollectionView.render("dashboardCollection.json",
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
        |> put_view(ApiWeb.ErrorView)
        |> render("500.json")
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(400)
    |> render(ApiWeb.ErrorView, "400.json")
  end

  #TODO: Waiting on Casey to merge his changes in before continued work to reduce any duplicate work or changes

#  def update(conn, %{"id" => id, "collection" => collection} = _params) do
#    IO.inspect _params
#
#    with collection_struct when is_map(collection_struct) <- Collections.get_collection!(id),
#         {:ok, updated_collection} <- Collections.update_collection(collection_struct, collection) do
#
#
#      ## need way to update colelction with one call? Or should I do what channel does? Can structs be nested?
#
#
#      FrontendWeb.Endpoint.broadcast!(
#        "collection:#{id}",
#        "updated_collection",
#        ApiWeb.CollectionView.render("dashboardCollection.json", collection: updated_collection)
#      )
#
#      conn
#      |> put_view(CollectionView)
#      |>render("collection.json", collection: updated_collection)
#    end
#  end
#
#  def delete(conn, %{"id" => id}) do
#    collection = Collections.get_collection!(id)
#
#    with {:ok, %Collections.Collection{}} <- Collections.delete_collection(collection) do
#      send_resp(conn, :no_content, "")
#    end
#  end
end
=======
    |> render(ApiWeb.ErrorView, "404.json")
  end

  # def create(conn, %{"title" => title}) do
  #   case Core.Dashboard.Collections.new_collection(Guardian.Plug.current_resource(conn).id, title) do
  #     {:ok, collection} ->
  #       conn
  #       |> render(CollectionView, "dashboardCollection.json", collection: collection)
  #     _ ->
  #       conn
  #       |> put_status(400)
  #       |> render(ApiWeb.ErrorView, "400.json")    
  #   end
  # end

  def create(conn, %{"title" => title}) do
    with {:ok, %Collections.Collection{} = collection} <- 
      Dashboard.Collections.new_collection(Guardian.Plug.current_resource(conn).id, title) do
        conn
        |> put_status(:created)
        |> render(CollectionView, "dashboardCollection.json", collection: collection)
      end
  end
end



#   def create(conn, %{"dog" => dog_params}) do
#     with {:ok, %Dog{} = dog} <- Animal.create_dog(dog_params) do
#       conn
#       |> put_status(:created)
#       |> put_resp_header("location", Routes.dog_path(conn, :show, dog))
#       |> render("show.json", dog: dog)
#     end
#   end


#   def update(conn, %{"id" => id, "dog" => dog_params}) do
#     dog = Animal.get_dog!(id)

#     with {:ok, %Dog{} = dog} <- Animal.update_dog(dog, dog_params) do
#       render(conn, "show.json", dog: dog)
#     end
#   end

#   def delete(conn, %{"id" => id}) do
#     dog = Animal.get_dog!(id)

#     with {:ok, %Dog{}} <- Animal.delete_dog(dog) do
#       send_resp(conn, :no_content, "")
#     end
#   end
# end

>>>>>>> 3f0900e... move files to branch
