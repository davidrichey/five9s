defmodule Five9sWeb.ServiceController do
  use Five9sWeb, :controller
  import Five9sWeb.Helper
  import Ecto.Query

  def show(conn, _params) do
    incident =
      Five9s.Repo.get(Five9s.Service, conn.path_params["id"] |> String.replace(".json", ""))

    render(conn, "show.#{render_type(conn)}", incident: incident)
  end

  def index(conn, params) do
    query =
      case params["name"] do
        nil -> Five9s.Service
        name -> from s in Five9s.Service, where: s.name == ^name
      end

    services =
      Five9s.Repo.all(query)
      |> Enum.sort_by(fn %_{name: name} -> name end)

    render(conn, "index.#{render_type(conn)}", services: services)
  end
end
