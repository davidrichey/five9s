defmodule Five9sWeb.AdminController do
  use Five9sWeb, :controller
  require Logger

  def services(conn, %{"key" => k, "verifier" => v}) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    external_services = get_in(config, ["external_services"]) || []
    render conn, "services.html", %{external_services: external_services, key: k, verifier: v}
  end

  def update_service(conn, params = %{"service" => s, "value" => v}) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    external_services = get_in(config, ["external_services"]) || []
    services = Enum.map(external_services, fn(%{"name" => n, "status" => st}) ->
      case n == s do
        true -> %{"name" => n, "status" => v}
        _ -> %{"name" => n, "status" => st}
      end
    end)
    Logger.debug "External Services updated: #{inspect services}"
    json = %{"external_services" => services}
    Process.send(Five9s.Workers.Fetcher, {:update, json}, [])
    Five9s.S3.put_object(%{json: json, name: "external_services"})

    render conn, "services.html", %{external_services: services, key: params["key"], verifier: params["verifier"]}
  end


  def incidents(conn, %{"key" => k, "verifier" => v}) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    incidents = get_in(config, ["incidents"]) || []
    render conn, "incidents.html", %{incidents: incidents, key: k, verifier: v}
  end
  def resolve_incident(conn, params = %{"timestamp" => timestamp}) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    incidents = get_in(config, ["incidents"]) || []

    incidents = Enum.map(incidents, fn(i = %{"timestamp" => ts}) ->
      case timestamp == ts do
        true -> Map.merge(i, %{"resolution_at" => DateTime.utc_now() |> DateTime.to_iso8601(), "resolution" => "Resolved"})
        _ -> i
      end
    end)
    incidents = incidents
                |> Enum.map(fn(i) ->
                  Map.merge(i, %{ "active" => i["resolution_at"] == nil })
                end)
    Logger.debug "Incidents updated: #{inspect incidents}"
    json = %{"incidents" => incidents}
    Process.send(Five9s.Workers.Fetcher, {:update, json}, [])
    Five9s.S3.put_object(%{json: json, name: "incidents"})


    render conn, "incidents.html", %{incidents: incidents, key: params["key"], verifier: params["verifier"]}
  end

  def new_incident(conn, obj = %{"form" => %{"title" => t, "description" => desc}}) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    incidents = get_in(config, ["incidents"]) || []
    incident = obj["form"] |> Map.take(["title", "description"])
    incident = Map.merge(incident, %{"timestamp" => DateTime.utc_now() |> DateTime.to_string()})
    incidents = (incidents ++ [incident])
                |> Enum.uniq()
                |> Enum.sort_by(fn(i) -> i["timestamp"] end)
                |> Enum.reverse()
                |> Enum.map(fn(i) ->
                  Map.merge(i, %{ "active" => i["resolution_at"] == nil })
                end)
    Logger.debug "Incidents now include: #{inspect incident}; #{inspect incidents}"

    json = %{"incidents" => incidents}
    Process.send(Five9s.Workers.Fetcher, {:update, json}, [])
    Five9s.S3.put_object(%{json: json, name: "incidents"})


    render conn, "incidents.html", %{incidents: incidents, key: obj["form"]["key"], verifier: obj["form"]["verifier"]}
  end
end
