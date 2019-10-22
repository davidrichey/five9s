defmodule Five9sWeb.IncidentController do
  use Five9sWeb, :controller

  def show(conn, _params) do
    incident = Five9s.Repo.get(Five9s.Incident, conn.path_params["id"])

    render(conn, "show.html", incident: incident)
  end
end
