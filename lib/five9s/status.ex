defmodule Five9s.Status do
  use Agent

  # @impl true
  # def init(_) do
  #   {:ok, }
  # end

  def start_link(_) do
    Agent.start_link(fn -> %{"incidents" => [], "status" => "ok"} end, name: __MODULE__)
  end

  def set(field, value) do
    Agent.update(__MODULE__, fn state ->
      Map.merge(state, %{field => value})
      |> calculate_status()
    end)
  end

  def all(field) do
    Agent.get(__MODULE__, fn state ->
      state[field] || []
    end)
  end

  def get(field, id) do
    all(field) |> Enum.find(fn r -> r.id == id end)
  end

  defp calculate_status(state) do
    active_incidents =
      Enum.filter(state["incidents"], fn i ->
        case i do
          %{resolution: %{id: _}} -> false
          _ -> true
        end
      end)

    status =
      case active_incidents |> Enum.count() do
        0 -> "ok"
        _ -> "degraded"
      end

    Map.merge(state, %{"status" => status})
  end
end
