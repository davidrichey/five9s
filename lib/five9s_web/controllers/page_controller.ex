defmodule Five9sWeb.PageController do
  use Five9sWeb, :controller

  def index(conn, _params) do
    config = Five9s.Supervisors.FetchSupervisor.fetch()
    IO.inspect get_in(config, ["incidents"]) || []
    render conn, "index.html",
           name: get_in(config, ["page", "statusPageName"]),
           description: get_in(config, ["page", "statusPageDescription"]),
           incidents: get_in(config, ["incidents"]) || [],
           maintenance: get_in(config, ["maintenance"]) || []
  end
end
