defmodule Five9sWeb.PageView do
  use Five9sWeb, :view

  def render("status.json", %{status: status}) do
    %{status: status}
  end
end
