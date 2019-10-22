defmodule Five9sWeb.Admin.ServiceLive do
  use Phoenix.LiveView

  def mount(session, socket) do
    if connected?(socket), do: :timer.send_interval(60_000, self(), :check)

    {:ok,
     assign(socket, %{
       admin: session.admin,
       resource: session.resource,
       changeset: Five9s.Service.changeset(session.resource, %{})
     })}
  end

  def render(assigns), do: Five9sWeb.Admin.ServiceView.render("live.html", assigns)

  def handle_info(:check, socket) do
    record = Five9s.Repo.get(Five9s.Service, socket.assigns.resource.id)
    {:noreply, assign(socket, :resource, record)}
  end

  def handle_event("status", %{"service" => %{"status" => status}}, socket) do
    record = Five9s.Repo.get(Five9s.Service, socket.assigns.resource.id)

    # TODO: Add API key
    {:ok, record} =
      Five9s.Service.changeset(record, %{status: status, source: %{type: "manual"}})
      |> Five9s.Repo.update()

    {:noreply, assign(socket, :resource, record)}
  end
end
