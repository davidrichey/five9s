defmodule Five9sWeb.OutageLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
      <h2>Outages</h2>
      <div class="outageLive">
        <%= for {date, incidents} <- assigns[:by_date] do %>
          <div class="date <%= if Enum.count(incidents) > 0, do: "outage" %> tooltip">
            <div class="tip">
              <h5><%= date %></h5>
              <%= if Enum.count(incidents) > 0 do %>
                Partial outage reported
              <% else %>
                No outages reported
              <% end %>
            </div>
          </div>
        <% end %>
      </div>
      <div class="timeline">
        <div class="left"><%= Enum.count(assigns[:by_date]) %> days ago</div>
        <div class="right">Today</div>
      </div>
    """
  end

  def mount(%{}, socket) do
    if connected?(socket), do: :timer.send_interval(24 * 60 * 60_000, self(), :check)

    {:ok, assign(socket, by_date: incidents_by_dates())}
  end

  def handle_info(:check, socket) do
    {:noreply, assign(socket, by_date: incidents_by_dates())}
  end

  defp dates do
    DateTime.utc_now()
    zone = Application.get_env(:five9s, :timezone) || "UTC"
    today = DateTime.utc_now() |> Timex.Timezone.convert(zone) |> DateTime.to_date()
    Enum.map(0..29, fn i -> Date.add(today, -1 * i) end)
  end

  defp incidents do
    Five9s.Repo.all(Five9s.Incident)
  end

  defp incidents_by_dates do
    zone = Application.get_env(:five9s, :timezone) || "UTC"
    dates = dates()
    incidents = incidents()

    Enum.map(dates, fn date ->
      on =
        Enum.filter(incidents, fn i ->
          time = i.created_at |> Timex.Timezone.convert(zone)

          time.day == date.day &&
            time.month == date.month &&
            time.year == date.year
        end)

      {date, on}
    end)
    |> Enum.reverse()
  end
end
