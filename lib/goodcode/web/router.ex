defmodule GC.Web.Router do
  use GC.Web, :router

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

  scope "/", GC.Web do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/tag/:tag", PageController, :tag
    get "/tags", PageController, :tags
    get "/archives", PageController, :archives
    get "/:folder/:id/:title", PageController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", GC.Web do
  #   pipe_through :api
  # end
end
