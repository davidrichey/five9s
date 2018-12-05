defmodule Five9sWeb.Admin.IncidentController do
  use Five9sWeb, :controller
  require Logger

  def create(conn, obj = %{"form" => %{"title" => _, "description" => _}}) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    incidents = get_in(config, ["incidents"]) || []
    incident = obj["form"] |> Map.take(["title", "description"])
    incident = Map.merge(incident, %{"timestamp" => DateTime.utc_now() |> DateTime.to_string()})

    incidents =
      (incidents ++ [incident])
      |> Enum.uniq()
      |> Enum.sort_by(fn i -> i["timestamp"] end)
      |> Enum.reverse()
      |> Enum.map(fn i ->
        Map.merge(i, %{"active" => i["resolution_at"] == nil})
      end)

    Logger.debug("Incidents now include: #{inspect(incident)}; #{inspect(incidents)}")
    json = %{"incidents" => incidents}
    Process.send(Five9s.Workers.Fetcher, {:update, json}, [])

    Five9s.S3.put_object(%{json: json, name: "incidents"})

    render(conn, "index.html", %{
      incidents: incidents,
      key: obj["form"]["key"],
      verifier: obj["form"]["verifier"]
    })
  end

  def index(conn, %{"key" => k, "verifier" => v}) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    incidents = get_in(config, ["incidents"]) || []
    render(conn, "index.html", %{incidents: incidents, key: k, verifier: v})
  end

  def show(conn, %{"id" => id, "key" => k, "verifier" => v}) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)

    case (get_in(config, ["incidents"]) || []) |> Enum.find(fn i -> i["timestamp"] == id end) do
      nil ->
        render(conn, Five9sWeb.ErrorView, "404.html")

      incident ->
        render(conn, "show.html", %{incident: incident, key: k, verifier: v})
    end
  end

  def delete(conn, params = %{"id" => timestamp}) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    incidents = get_in(config, ["incidents"]) || []

    incidents =
      incidents
      |> Enum.filter(fn i ->
        i["timestamp"] != timestamp
      end)

    Logger.debug("Incidents updated: #{inspect(incidents)}")
    json = %{"incidents" => incidents}
    Process.send(Five9s.Workers.Fetcher, {:update, json}, [])
    Five9s.S3.put_object(%{json: json, name: "incidents"})

    redirect(
      conn,
      to: incident_path(conn, :index, key: params["key"], verifier: params["verifier"])
    )
  end

  def resolve(conn, params = %{"id" => timestamp, "form" => %{"description" => description}}) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    incidents = get_in(config, ["incidents"]) || []

    incidents =
      Enum.map(incidents, fn i = %{"timestamp" => ts} ->
        case timestamp == ts do
          true ->
            Map.merge(i, %{
              "resolution_at" => DateTime.utc_now() |> DateTime.to_iso8601(),
              "resolution" => description || "Resolved"
            })

          _ ->
            i
        end
      end)

    incidents =
      incidents
      |> Enum.map(fn i ->
        Map.merge(i, %{"active" => i["resolution_at"] == nil})
      end)

    Logger.debug("Incidents updated: #{inspect(incidents)}")
    json = %{"incidents" => incidents}
    Process.send(Five9s.Workers.Fetcher, {:update, json}, [])
    Five9s.S3.put_object(%{json: json, name: "incidents"})

    redirect(
      conn,
      to:
        incident_path(
          conn,
          :index,
          key: params["form"]["key"],
          verifier: params["form"]["verifier"]
        )
    )
  end

  def update(conn, params = %{"id" => timestamp, "form" => %{"description" => description}}) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    incidents = get_in(config, ["incidents"]) || []

    update = %{
      "update_at" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "update" => description
    }

    incidents =
      Enum.map(incidents, fn i = %{"timestamp" => ts} ->
        case timestamp == ts do
          true ->
            updates = i["updates"] || []
            Map.merge(i, %{"updates" => updates ++ [update]})

          _ ->
            i
        end
      end)

    Logger.debug("Incident has an update: #{inspect(update)} #{inspect(incidents)}")
    json = %{"incidents" => incidents}
    Process.send(Five9s.Workers.Fetcher, {:update, json}, [])
    Five9s.S3.put_object(%{json: json, name: "incidents"})

    redirect(
      conn,
      to:
        incident_path(
          conn,
          :show,
          timestamp,
          key: params["form"]["key"],
          verifier: params["form"]["verifier"]
        )
    )
  end
end
