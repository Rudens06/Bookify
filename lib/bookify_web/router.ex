defmodule BookifyWeb.Router do
  use BookifyWeb, :router
  import BookifyWeb.Plugs.Auth

  alias BookifyWeb.Plugs.Api.V1.AuthenticateApi

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BookifyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated_api do
    plug AuthenticateApi
  end

  scope "/api/v1", BookifyWeb.Api.V1 do
    pipe_through [:api, :authenticated_api]

    resources "/authors", AuthorController, except: [:new, :edit]
    resources "/users", UserController, only: [:update, :index]
    get "/users/current", UserController, :current

    get "/books", BookController, :index
    get "/books/:isbn", BookController, :show
    post "/books/:isbn", BookController, :create
    patch "/books/:isbn", BookController, :update
    delete "/books/:isbn", BookController, :delete

    get "/books/:isbn/reviews", ReviewController, :index
    get "/books/:isbn/reviews/:id", ReviewController, :show
    post "/books/:isbn/reviews", ReviewController, :create
    patch "/books/:isbn/reviews/:id", ReviewController, :update
    delete "/books/:isbn/reviews/:id", ReviewController, :delete
  end

  scope "/", BookifyWeb do
    pipe_through :browser

    live_session :mount_current_user,
      on_mount: [{BookifyWeb.Plugs.Auth, :mount_current_user}] do
      live "/", BookLive.Index
    end
  end

  scope "/", BookifyWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{BookifyWeb.Plugs.Auth, :require_authenticated_user}] do
    end

    delete "/accounts/logout", UserSessionController, :delete
  end

  scope "/", BookifyWeb do
    pipe_through [:browser, :redirect_if_authenticated]

    live_session :redirect_if_authenticated,
      on_mount: [{BookifyWeb.Plugs.Auth, :redirect_if_authenticated}] do
      live "/accounts/register", AccountLive.Register
      live "/accounts/login", AccountLive.Login
    end

    post "/accounts/login", UserSessionController, :create
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:bookify, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BookifyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
