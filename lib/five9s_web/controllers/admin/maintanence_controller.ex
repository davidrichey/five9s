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

    mtnce =
      mtnce
      |> Map.merge(%{
        "id" => Five9s.Application.random_string(),
        "start_time" => time_from_select(mtnce["start_time"]),
        "end_time" => time_from_select(mtnce["end_time"])
      })

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

    redirect(conn, to: maintenance_path(conn, :index, key: obj["key"], verifier: obj["verifier"]))
  end

  defp time_from_select(t) do
    year = t["year"]
    month = t["month"] |> String.pad_leading(2, "0")
    day = t["day"] |> String.pad_leading(2, "0")
    hour = t["hour"] |> String.pad_leading(2, "0")
    minute = t["minute"] |> String.pad_leading(2, "0")
    "#{year}-#{month}-#{day} #{hour}:#{minute}:00Z"
  end
end
