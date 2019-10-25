defmodule Five9sWeb.IncidentController do
  use Five9sWeb, :controller
  import Five9sWeb.Helper
  import Ecto.Query

  def show(conn, _params) do
    incident =
      Five9s.Repo.get(Five9s.Incident, conn.path_params["id"] |> String.replace(".json", ""))

    render(conn, "show.#{render_type(conn)}", incident: incident)
  end

  def index(conn, _params) do
    incidents =
      Five9s.Repo.all(from i in Five9s.Incident, where: is_nil(i.resolution))
      |> Enum.sort_by(fn %_{created_at: created_at} ->
        {created_at.year, created_at.month, created_at.day}
      end)

    render(conn, "index.#{render_type(conn)}", incidents: incidents)
  end
end
