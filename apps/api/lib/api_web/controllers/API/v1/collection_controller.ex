defmodule ApiWeb.V1.CollectionController do
  use ApiWeb, :controller

  alias Core.Dashboard
  alias Core.Collections
  alias ApiWeb.CollectionView

  action_fallback ApiWeb.FallbackController

  def show(conn, %{"id" => id} = _params) do
    case List.first(Core.Collections.get_permalink_view(id)) do
      nil -> 
        conn
        |> put_status(404)
        |> render(ApiWeb.ErrorView, "404.json")

      collection -> 
        conn
        |> render(CollectionView, "collection.json", collection: collection)
    end
  end

  def show(conn, _params) do
    conn
    |> put_status(404)
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

