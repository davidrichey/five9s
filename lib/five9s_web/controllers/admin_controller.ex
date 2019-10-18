defmodule Five9sWeb.AdminController do
  use Five9sWeb, :controller

  def new(conn, _params) do
    {module, _resource} = module(conn)

    render(conn, "new.html", changeset: module.changeset(struct(module), %{}))
  end

  def create(conn, params) do
    {module, resource} = module(conn)

    {:ok, _record} =
      module.changeset(struct(module), params[Inflex.singularize(resource)])
      |> Five9s.Repo.insert()

    # Five9s.S3.append(resource, record)

    redirect(conn, to: "/admin/#{resource}")
  end

  def index(conn, _params) do
    {module, _resource} = module(conn)
    render(conn, "index.html", resources: Five9s.Repo.all(module))
  end

  def show(conn, _params) do
    {module, _resource} = module(conn)
    render(conn, "show.html", resource: Five9s.Repo.get(module, conn.path_params["id"]))
  end

  defp module(conn) do
    case conn.request_path |> String.split("/", trim: true) |> Enum.drop(1) do
      ["incidents" | _] -> {Five9s.Incident, "incidents"}
    end
  end
end
