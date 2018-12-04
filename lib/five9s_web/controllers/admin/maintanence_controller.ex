defmodule Five9sWeb.Admin.MaintenanceController do
  use Five9sWeb, :controller
  require Logger

  def index(conn, %{"key" => k, "verifier" => v}) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    maintenance = get_in(config, ["maintenance"]) || []
    render(conn, "index.html", %{maintenance: maintenance, key: k, verifier: v})
  end

  def create(conn, %{"form" => obj}) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    maintenance = get_in(config, ["maintenance"]) || []

    mtnce =
      Map.take(obj, ["name", "description", "start_time", "end_time", "severity", "components"])

    mtnce = Map.merge(mtnce, %{"timestamp" => DateTime.utc_now() |> DateTime.to_string()})

    maintenance =
      (maintenance ++ [mtnce])
      |> Enum.uniq()
      |> Enum.sort_by(fn i -> i["start_time"] end)
      |> Enum.reverse()
      |> Enum.map(fn i ->
        now = DateTime.utc_now()
        {:ok, st, _} = DateTime.from_iso8601(i["start_time"])
        {:ok, et, _} = DateTime.from_iso8601(i["end_time"])
        stc = DateTime.compare(st, now)
        etc = DateTime.compare(et, now)

        Map.merge(i, %{
          "active" => Enum.member?([:lt, :eq], stc) && Enum.member?([:gt, :eq], etc),
          "relevant" => Enum.member?([:gt, :eq], stc) || Enum.member?([:gt, :eq], etc)
        })
      end)

    Logger.debug("Incidents now include: #{inspect(mtnce)}; #{inspect(maintenance)}")

    json = %{"maintenance" => maintenance}
    Process.send(Five9s.Workers.Fetcher, {:update, json}, [])
    Five9s.S3.put_object(%{json: json, name: "maintenance"})

    render(conn, "index.html", %{
      maintenance: maintenance,
      key: obj["key"],
      verifier: obj["verifier"]
    })
  end
end
