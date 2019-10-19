defmodule Five9sWeb.OpenIncidentsLive do
  use Phoenix.LiveView
  import Ecto.Query

  def render(assigns) do
    ~L"""
      <%= if assigns[:open_incidents] |> Enum.count() > 0 do %>
        <h2>Open Incidents</h2>
        <%= for incident <- assigns[:open_incidents] do %>
          <div class="incident <%= if is_nil(incident.resolution), do: "open", else: "resolved" %>">
            <div class="name"><%= incident.name %></div>
            <div class="description"><%= incident.description %></div>
            <%= if !is_nil(incident.resolution) do %>
              <div class="resolution">Resolved at <%= incident.resolution.created_at %>: <%= incident.resolution.description %></div>
            <% end %>
            <%= if incident.updates |> Enum.count() > 0 do %>
              <div class="updates">
                <%= for update <- incident.updates do %>
                  <div class="updateHeader">Update</div>
                  <div class="update">
                    <%= update.description %>
                    <%= update.updated_at %>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        <% end %>
      <% end %>
    """
  end

  def mount(%{}, socket) do
    if connected?(socket), do: :timer.send_interval(10_000, self(), :check)
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
