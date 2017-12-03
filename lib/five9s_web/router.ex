defmodule Five9sWeb.Router do
  use Five9sWeb, :router
  import Five9sWeb.Plugs.Admin

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :verfy_admin_request
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
    pipe_through :admin
    get "/status/admin/services", AdminController, :services
    post "/status/admin/services", AdminController, :update_service

    get "/status/admin/incidents", AdminController, :incidents
    post "/status/admin/incident/resolve", AdminController, :resolve_incident
    post "/status/admin/incident", AdminController, :new_incident
  end

  scope "/", Five9sWeb do
    pipe_through :api
    get "/status/uptime", UptimeController, :index
  end
end
