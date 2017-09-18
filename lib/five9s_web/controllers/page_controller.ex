defmodule Five9sWeb.PageController do
  use Five9sWeb, :controller

  def index(conn, _params) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    maintenance = get_in(config, ["maintenance"]) || []
    relevant_maintenance = Enum.filter(maintenance, fn(x) -> !x["active"] end)
    active_maintenance = Enum.filter(maintenance, fn(x) -> x["active"] end)

    incidents = get_in(config, ["incidents"]) || []
    external_services = get_in(config, ["external_services"]) || []
    previous_incidents = Enum.filter(incidents, fn(x) -> !x["active"] end)
                         |> Enum.take(5)
    active_incidents = Enum.filter(incidents, fn(x) -> x["active"] end)

    pings = (get_in(config, ["pings"]) || []) != []

    status = case {length(active_maintenance), length(active_incidents)} do
      {0, 0} -> "ok"
      _ -> "warn"
    end

    render conn, "index.html",
           name: get_in(config, ["page", "statusPageName"]),
           image: get_in(config, ["page", "image"]),
           description: get_in(config, ["page", "statusPageDescription"]),
           incidents: previous_incidents,
           external_services: external_services,
           active_incidents: active_incidents,
           maintenance: relevant_maintenance,
           active_maintenance: active_maintenance,
           pings: pings,
           status: status
  end
end
