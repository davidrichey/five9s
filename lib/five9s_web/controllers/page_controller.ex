defmodule Five9sWeb.PageController do
  use Five9sWeb, :controller
  import Ecto.Query

  def index(conn, _params) do
    open_incidents = Five9s.Repo.all(from i in Five9s.Incident, where: is_nil(i.resolution))
    days = 5
    days_ago = DateTime.utc_now() |> DateTime.add(60 * 60 * 24 * days, :second)

    past_incidents =
      Five9s.Repo.all(
        from i in Five9s.Incident,
          where: not is_nil(i.resolution),
          where: i.created_at > ^days_ago
      )

    services =
      Five9s.Repo.all(Five9s.Service)
      |> Enum.sort_by(fn s -> s.name end)

    render(conn, "index.html",
      days: days,
      open_incidents: open_incidents,
      past_incidents: past_incidents,
      services: services
    )
  end

  def status(conn, _) do
    open_incidents = Five9s.Repo.all(from i in Five9s.Incident, where: is_nil(i.resolution))
    status = if Enum.count(open_incidents) == 0, do: "ok", else: "degraded"
    render(conn, "status.json", %{status: status})
  end
end
