defmodule Five9sWeb.OpenIncidentsLive do
  use Phoenix.LiveView
  import Ecto.Query

  def render(assigns) do
    ~L"""
      <%= if assigns[:open_incidents] |> Enum.count() > 0 do %>
        <h2>Open Incidents</h2>
        <%= for incident <- assigns[:open_incidents] do %>
          <%= Phoenix.HTML.Link.link to: "/incidents/#{incident.id}" do %>
            <%= live_render(@socket, Five9sWeb.IncidentLive, id: incident.id, session: %{admin: false, resource: incident}) %>
          <% end %>
        <% end %>
      <% end %>
    """
  end

  def mount(%{}, socket) do
    if connected?(socket), do: :timer.send_interval(60_000, self(), :check)
    {:ok, assign(socket, open_incidents: open_incidents())}
  end

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
