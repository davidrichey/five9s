defmodule Five9sWeb.IncidentView do
  use Five9sWeb, :view

  def render("show.json", %{incident: incident}) do
    %{incident: incident}
  end

  def render("index.json", %{incidents: incidents}) do
    %{incidents: incidents}
  end
end
