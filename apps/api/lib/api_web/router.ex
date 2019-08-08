defmodule ApiWeb.Router do
  use ApiWeb, :router
  require Ueberauth

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :auth do
    plug ApiWeb.AuthToken
  end

  pipeline :browser_auth do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
    plug ApiWeb.Auth
  end

  scope "/api", ApiWeb do
    pipe_through [:api]

    get "/search", V1.SearchController, :search
    get "/collection/:id", V1.CollectionController, :show        

    scope "/" do
      pipe_through [:browser_auth]

      post "/file/:id", V1.FileController, :get_file
      resources "/token", V1.TokenController, only: [:index, :create, :delete]
    end

    scope "/" do
      pipe_through [:auth]

      resources "/resource", V1.ResourceController, only: [:create]
      resources "/collection", V1.CollectionController, only: [:create]
    end
  end
end
