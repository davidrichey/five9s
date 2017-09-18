defmodule Five9sWeb.Router do
  use Five9sWeb, :router

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

  scope "/", Five9sWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/status", PageController, :index
  end

  scope "/", Five9sWeb do
    pipe_through :api
    get "/status/uptime", UptimeController, :index
  end
end
