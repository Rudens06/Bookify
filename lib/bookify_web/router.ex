defmodule BookifyWeb.Router do
  use BookifyWeb, :router
  import BookifyWeb.Plugs.Auth
  alias BookifyWeb.Plugs.Api.V1.AuthenticateApi
  alias BookifyWeb.Plugs.Api.V1.RequireAdmin

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

  pipeline :authenticate_api do
    plug AuthenticateApi
  end

  pipeline :require_admin do
    plug RequireAdmin
  end

  scope "/api/v1", BookifyWeb.Api.V1 do
    pipe_through [:api, :authenticate_api]

    get "/authors", AuthorController, :index
    get "/authors/:id", AuthorController, :show

    patch "/users", UserController, :update
    get "/users/current", UserController, :current

    # Lists
    get "/users/:user_id/lists", ListController, :index
    post "/users/lists", ListController, :create
    delete "/users/lists/:list_id", ListController, :delete
    patch "/users/lists/:list_id", ListController, :update

    post "/users/lists/:list_id/:book_id", ListController, :add_book
    patch "/users/lists/:list_id/:book_id", ListController, :update_book
    delete "/users/lists/:list_id/:book_id", ListController, :remove_book

    # Books
    get "/books", BookController, :index
    get "/books/:isbn", BookController, :show

    # Reviews
    get "/books/:isbn/reviews", ReviewController, :index
    get "/books/:isbn/reviews/:id", ReviewController, :show
    post "/books/:isbn/reviews", ReviewController, :create
    patch "/books/:isbn/reviews/:id", ReviewController, :update
    delete "/books/:isbn/reviews/:id", ReviewController, :delete

    scope "/" do
      pipe_through :require_admin
      get "/users", UserController, :index

      post "/books", BookController, :create
      delete "/books/:isbn", BookController, :delete
      patch "/books/:isbn", BookController, :update

      post "/authors", AuthorController, :create
      delete "/authors/:id", AuthorController, :delete
      patch "/authors/:id", AuthorController, :update
    end
  end

  scope "/", BookifyWeb do
    pipe_through [:browser, :require_admin_user]

    live_session :require_admin_user,
      on_mount: [{BookifyWeb.Plugs.Auth, :require_admin_user}] do
      live "/authors/new", AuthorLive.Index, :new
      live "/authors/:id/edit", AuthorLive.Index, :edit
      live "/authors/:id/show/edit", AuthorLive.Show, :edit
    end
  end

  scope "/", BookifyWeb do
    pipe_through :browser

    live_session :mount_current_user,
      on_mount: [{BookifyWeb.Plugs.Auth, :mount_current_user}] do
      live "/", BookLive.Index
      live "/books/:isbn", BookLive.Show

      live "/authors", AuthorLive.Index, :index
      live "/authors/:id", AuthorLive.Show, :show

      live "/book_import", BookImportLive.Index
      live "/book_import/show", BookImportLive.Show
    end
  end

  scope "/", BookifyWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{BookifyWeb.Plugs.Auth, :require_authenticated_user}] do
      live "/accounts/show", AccountLive.Show

      live "/users", UserLive.Index
      live "/users/:public_id", UserLive.Show
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
end
