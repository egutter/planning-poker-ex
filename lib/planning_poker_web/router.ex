defmodule PlanningPokerWeb.Router do
  use PlanningPokerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PlanningPokerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PlanningPokerWeb do
    pipe_through :browser

    post "/sign_in", UserController, :create
    delete "/sign_out", UserController, :destroy

    live "/", CasinoLive.Index
    live "/login", LoginLive.Index
    live "/game/:game_name", GameLive.Index
    live "/game/:game_name/estimate/:story_name", GameLive.Estimate
  end

  # Other scopes may use custom stacks.
  # scope "/api", PlanningPokerWeb do
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
      live_dashboard "/dashboard", metrics: PlanningPokerWeb.Telemetry
    end
  end
end
