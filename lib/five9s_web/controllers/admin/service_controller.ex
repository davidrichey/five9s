defmodule Five9sWeb.Admin.ServiceController do
  use Five9sWeb, :controller
  alias Five9sWeb.AdminController

  def new(conn, params), do: AdminController.new(conn, params)
  def create(conn, params), do: AdminController.create(conn, params)
  def index(conn, params), do: AdminController.index(conn, params)
  def show(conn, params), do: AdminController.show(conn, params)
end
