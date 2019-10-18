defmodule Five9s.S3 do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  def all(path) do
    GenServer.call(__MODULE__, {:all, path})
  end

  def insert(path, record) do
    object = record |> Map.from_struct() |> Map.drop([:__meta__])
    GenServer.call(__MODULE__, {:insert, path, object})
  end

  def delete(path, record_id) do
    GenServer.call(__MODULE__, {:delete, path, record_id})
  end

  def update(path, record) do
    object = record |> Map.from_struct() |> Map.drop([:__meta__])
    GenServer.call(__MODULE__, {:update, path, object})
  end

  @impl true
  def handle_call({:all, path}, _from, state) do
    current = state[path] || []
    {:reply, current, state}
  end

  @impl true
  def handle_call({:insert, path, object}, _from, state) do
    current = state[path] || []
    {:reply, [object | current], Map.merge(state, %{path => [object | current]})}
  end

  @impl true
  def handle_call({:delete, path, object_id}, _from, state) do
    current = state[path] || []
    remaining = Enum.reject(current, fn c -> c.id == object_id end)
    state = Map.merge(state, %{path => remaining})
    {:reply, remaining, state}
  end

  @impl true
  def handle_call({:update, path, object}, _from, state) do
    current = state[path] || []

    updated =
      case Enum.find_index(current, fn o -> o.id == object.id end) do
        nil -> current
        index -> current |> List.replace_at(index, object)
      end

    {:reply, updated, Map.merge(state, %{path => updated})}
  end
end
