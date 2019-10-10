defmodule Five9sWeb.StatusLive do
  use Phoenix.LiveView

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
    # if connected?(socket), do: :timer.send_interval(10_000, self(), :update)

    {:ok, assign(socket, status: "ok")}
  end

  # def handle_info(:update, socket) do
  #   {:noreply, assign(socket, :temperature, 101)}
  # end

  def handle_event("inc", _value, socket) do
    {:noreply, assign(socket, temperature: socket.assigns.temperature + 5)}
  end
end
