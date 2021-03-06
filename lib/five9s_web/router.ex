defmodule Five9sWeb.Router do
  use Five9sWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Five9sWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/incidents/:id", IncidentController, :show
  end

  scope "/", Five9sWeb do
    pipe_through :api

    get "/incidents/:id", IncidentController, :show
    get "/incidents.json", IncidentController, :index
    get "/status.json", PageController, :status
    get "/services.json", ServiceController, :index
  end

  scope "/admin", Five9sWeb do
    pipe_through :admin

    get "/incidents/new", Admin.IncidentController, :new
    post "/incidents", Admin.IncidentController, :create
    get "/incidents", Admin.IncidentController, :index
    get "/incidents/:id", Admin.IncidentController, :show

    get "/services/new", Admin.ServiceController, :new
    post "/services", Admin.ServiceController, :create
    get "/services", Admin.ServiceController, :index
  end
end
