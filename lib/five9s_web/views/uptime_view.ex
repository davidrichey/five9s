defmodule Five9sWeb.UptimeView do
  use Five9sWeb, :view

  def render("index.json", %{"pings" => all}) do
    %{uptimes: all}
  end
end
