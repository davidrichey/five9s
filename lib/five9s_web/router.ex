defmodule Five9sWeb.Router do
  use Five9sWeb, :router
  import Five9sWeb.Plugs.Admin

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :admin do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:verfy_admin_request)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", Five9sWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/status", PageController, :index)
  end

  scope "/", Five9sWeb do
    pipe_through(:admin)
    get("/status/admin/services", Admin.ServiceController, :index)
    post("/status/admin/services", Admin.ServiceController, :update)
    post("/status/admin/service", Admin.ServiceController, :create)

    get("/status/admin/incidents", Admin.IncidentController, :index)
    post("/status/admin/incident/resolve", Admin.IncidentController, :update)
    post("/status/admin/incident", Admin.IncidentController, :create)
    delete("/status/admin/incident", Admin.IncidentController, :delete)

    get("/status/admin/maintenance", Admin.MaintenanceController, :index)
    post("/status/admin/maintenance", Admin.MaintenanceController, :create)
  end

  scope "/", Five9sWeb do
    pipe_through(:api)
    get("/status/uptime", UptimeController, :index)
  end
end
