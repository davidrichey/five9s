defmodule Five9sWeb.ServiceView do
  use Five9sWeb, :view

  def render("show.json", %{service: service}) do
    %{service: service}
  end

  def render("index.json", %{services: services}) do
    %{services: services}
  end
end
