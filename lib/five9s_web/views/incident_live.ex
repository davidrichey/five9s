defmodule Five9sWeb.IncidentLive do
  use Phoenix.LiveView
  import Ecto.Query

  def mount(session, socket) do
    if connected?(socket), do: :timer.send_interval(60_000, self(), :check)

    {:ok,
     assign(socket, %{
       admin: false,
       resource: session.resource
     })}
  end

  def render(assigns), do: Five9sWeb.Admin.IncidentView.render("live.html", assigns)

  def handle_info(:check, socket) do
    {:noreply, assign(socket, :open_incidents, open_incidents())}
  end

  defp open_incidents do
    Five9s.Repo.all(from i in Five9s.Incident, where: is_nil(i.resolution))
    |> Enum.sort_by(fn %_{created_at: created_at} ->
      {created_at.year, created_at.month, created_at.day}
    end)
  end
end
