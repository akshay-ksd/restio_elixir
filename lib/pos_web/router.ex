defmodule PosWeb.Router do
  use PosWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PosWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api", PosWeb do
    pipe_through :api

    post "/restaurentRegistration", RestController, :restaurentRegistration
    post "/authentication", StaffController, :authentication
    post "/getRestaurentDetails", RestController, :getRestaurentDetails
    post "/addAdmin", RestController, :addAdmin
  end

  scope "/" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: PosWeb.Schema,
      interface: :simple,
      context: %{pubsub: CommunityWeb.Endpoint}
  end

  # Other scopes may use custom stacks.
  # scope "/api", PosWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: PosWeb.Telemetry
    end
  end
end
