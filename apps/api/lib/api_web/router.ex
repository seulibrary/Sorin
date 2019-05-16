defmodule ApiWeb.Router do
  use ApiWeb, :router
  require Ueberauth

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug ApiWeb.Auth
  end

  scope "/api", ApiWeb do
    pipe_through [:api]

    resources "/collection", CollectionController, only: [:show]

    # post "/collection", CollectionController, :get_collection
    post "/file/:id", FileController, :get_file
  end
end
