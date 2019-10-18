defmodule Five9sWeb.StatusLive do
  use Phoenix.LiveView
  import Ecto.Query

  def render(assigns) do
    ~L"""
      <div class="systemStatus status<%=assigns[:status]%>">
        <%= case assigns[:status] do
          "ok" -> "All systems go"
          "degraded" -> "Degraded Performance"
        end %>
      </div>
    """
  end

  def mount(%{}, socket) do
    if connected?(socket), do: :timer.send_interval(10_000, self(), :check)

    {:ok, assign(socket, status: status())}
  end

  def handle_info(:check, socket) do
    {:noreply, assign(socket, :status, status())}
  end

  defp status do
    open_incidents = Five9s.Repo.all(from i in Five9s.Incident, where: is_nil(i.resolution))
    if Enum.count(open_incidents) == 0, do: "ok", else: "degraded"
  end
end
