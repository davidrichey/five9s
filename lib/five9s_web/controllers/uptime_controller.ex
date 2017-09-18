defmodule Five9sWeb.UptimeController do
  use Five9sWeb, :controller

  def index(conn, _params) do
    state = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Ping)
    pings = state["ping"]
    structured = organize(Map.keys(pings), pings)
    render conn, "index.json", %{"pings" => structured}
  end

  defp organize([key | tail], pings) do
    data = Enum.reverse(pings[key])
               |> Enum.take(60)
               |> Enum.reverse
    res = Map.merge(pings, %{key => data})
    organize(tail, res)
  end

  defp organize([], data), do: data
end
