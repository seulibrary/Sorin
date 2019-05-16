defmodule FrontendWeb.Router do
  use FrontendWeb, :router
  require Ueberauth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug ApiWeb.Auth
  end
  
  # Auth Routes
  # * Defined in Frontend, but functions are located in API
  # * This is because Auth is required in API too.
  scope "/auth", ApiWeb do
    pipe_through :browser

    get "/signout", AuthController, :delete
    post "/signout", AuthController, :delete
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :new
  end

  # Frontend Routes
  # * Routes are defined here instead of being defined by React.
  # * This is so there is more control in the back end. And, let's us
  # * Set up routes for API too if needed.
  scope "/", FrontendWeb do
    pipe_through [:browser, :auth]

    get "/*path", PageController, :index
  end
end
