defmodule ApiWeb.Router do
  use ApiWeb, :router
  require Ueberauth

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end
  
  pipeline :auth do
    plug ApiWeb.Auth
  end

  scope "/api", ApiWeb do
    pipe_through [:api]

    post "/token", V1.TokenController, :manage_tokens

    scope "/" do
      pipe_through [:auth]

      resources "/collection", V1.CollectionController, only: [:create]
      post "/file/:id", FileController, :get_file
    end
  end
end
