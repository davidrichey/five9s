defmodule Five9sWeb.PageController do
  use Five9sWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
