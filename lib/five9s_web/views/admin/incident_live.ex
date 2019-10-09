defmodule Five9sWeb.Admin.IncidentLive do
  use Phoenix.LiveView

  alias Five9s.Incident.Update

  def mount(session, socket) do
    {:ok,
     assign(socket, %{
       resource: session.resource
     })}
  end

  def render(assigns), do: Five9sWeb.Admin.IncidentView.render("live.html", assigns)

  def handle_event("update", %{"update" => %{"description" => desc}}, socket) do
    {:ok, update} =
      Update.changeset(%Update{}, %{description: desc})
      |> Five9s.Repo.apply()

    record = Five9s.Repo.get(Five9s.Incident, socket.assigns.resource.id)
    IO.inspect("TODO: Start back her, there is not changeset for records in Five9s.Incident")
    IO.inspect(record)

    {:ok, record} =
      Five9s.Incident.changeset(record, %{updates: [update | record.updates]})
      |> Five9s.Repo.update()

    {:noreply, assign(socket, :resource, record)}
  end

  def handle_event("resolve", %{"resolution" => %{"description" => desc}}, socket) do
    {:ok, resolution} =
      Update.changeset(%Update{}, %{description: desc})
      |> Five9s.Repo.as_map()

    resource = socket.assigns.resource
    resource = Map.merge(resource, %{resolution: resolution})
    Five9s.S3.update("incidents", resource)
    {:noreply, assign(socket, :resource, resource)}
  end
end
