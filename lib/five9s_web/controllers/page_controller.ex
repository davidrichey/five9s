defmodule Five9sWeb.PageController do
  use Five9sWeb, :controller

  def index(conn, _params) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    maintenance = get_in(config, ["maintenance"]) || []
    relevant_maintenance = Enum.filter(maintenance, fn x -> !x["active"] end)
    active_maintenance = Enum.filter(maintenance, fn x -> x["active"] end)

    incidents = get_in(config, ["incidents"]) || []
    external_services = get_in(config, ["external_services"]) || []

    previous_incidents =
      Enum.filter(incidents, fn x -> !x["active"] end)
      |> Enum.take(5)

    active_incidents = Enum.filter(incidents, fn x -> x["active"] end)

    pings = (get_in(config, ["pings"]) || []) != []

    status =
      case {length(active_maintenance), length(active_incidents)} do
        {0, 0} -> "ok"
        _ -> "warn"
      end

    render(
      conn,
      "index.html",
      name: get_in(config, ["page", "statusPageName"]),
      image: get_in(config, ["page", "image"]),
      favicon: get_in(config, ["page", "favicon"]),
      description: get_in(config, ["page", "statusPageDescription"]),
      incidents: previous_incidents,
      external_services: external_services,
      active_incidents: active_incidents,
      maintenance: relevant_maintenance,
      active_maintenance: active_maintenance,
      pings: pings,
      status: status
    )
  end

  def maintenance(conn, params) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    maintenances = get_in(config, ["maintenance"]) || []
    incidents = get_in(config, ["incidents"]) || []
    active_incidents = Enum.filter(incidents, fn x -> x["active"] end)
    active_maintenance = Enum.filter(maintenances, fn x -> x["active"] end)

    status =
      case {length(active_maintenance), length(active_incidents)} do
        {0, 0} -> "ok"
        _ -> "warn"
      end

    case maintenances |> Enum.find(fn m -> m["id"] == params["id"] end) do
      nil ->
        conn
        |> Plug.Conn.put_status(401)
        |> Phoenix.Controller.render(Five9sWeb.ErrorView, "not_found.html")

      maintenance ->
        render(conn, "maintenance.html", %{
          maintenance: maintenance,
          status: status,
          image: get_in(config, ["page", "image"])
        })
    end
  end
end
