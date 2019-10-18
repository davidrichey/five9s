defmodule Five9s.Repo do
  import Ecto.{Changeset, Query}

  def all(query = %Ecto.Query{}) do
    %_{source: {_, module}} = query.from
    all = all(module)

    all
    |> Enum.filter(fn record ->
      Enum.map(query.wheres, fn where ->
        case where do
          %_{expr: {:==, _, _}, params: params} ->
            [{value, {_, key}} | _] = params
            Map.get(record, key) == value

          %_{expr: {:is_nil, _, [{{_, _, [_, field]}, _, _}]}} ->
            is_nil(Map.get(record, field))

          %_{expr: {:not, _, [{:is_nil, _, [{{_, _, [_, field]}, _, _}]}]}} ->
            !is_nil(Map.get(record, field))

          %{expr: {:>, [], [{{_, _, [{_, _, _}, field]}, _, _}, _]}, params: [{greater, {_, _}}]} ->
            case greater do
              %DateTime{} -> DateTime.compare(greater, Map.get(record, field)) == :gt
              _ -> greater < Map.get(record, field)
            end
        end
      end)
      |> Enum.uniq() == [true]
    end)
  end

  def all(module) do
    path = path(module.__struct__.__meta__)

    Five9s.S3.all(path)
    |> Enum.map(fn json -> struct(module, json) end)
  end

  def get(module, id) do
    all(from r in module, where: r.id == ^id)
    |> Enum.at(0)
  end

  def insert(changeset, _opts \\ []) do
    case changeset.valid? do
      false ->
        {:error, changeset.errors}

      _ ->
        record = changeset |> apply_changes()
        path = path(record.__meta__)
        module = record.__struct__

        Five9s.S3.insert(path, record)
        |> Enum.map(fn r -> struct(module, r) end)

        {:ok, record}
    end
  end

  def update(changeset, _opts \\ []) do
    case changeset.valid? do
      false ->
        {:error, changeset.errors}

      _ ->
        record = changeset |> apply_changes()
        path = path(record.__meta__)
        module = record.__struct__

        all =
          Five9s.S3.update(path, record)
          |> Enum.map(fn r -> struct(module, r) end)

        {:ok, record}
    end
  end

  def delete(module, id) do
    path = path(module.__struct__.__meta__)

    all =
      Five9s.S3.delete(path, id)
      |> Enum.map(fn r -> struct(module, r) end)

    {:ok}
  end

  @chars "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
         |> String.split("", trim: true)

  def hex(length \\ 32) do
    Enum.reduce(1..length, [], fn _i, acc ->
      [Enum.random(@chars) | acc]
    end)
    |> Enum.join("")
  end

  def uuid do
    "#{hex(8)}-#{hex(4)}-#{hex(4)}-#{hex(4)}-#{hex(12)}"
  end

  def as_map(changeset) do
    case changeset.valid? do
      false ->
        {:error, changeset.errors}

      _ ->
        {:ok,
         changeset
         |> apply_changes()
         |> Map.from_struct()
         |> Map.drop([:__meta__])}
    end
  end

  def apply(changeset) do
    case changeset.valid? do
      false ->
        {:error, changeset.errors}

      _ ->
        {:ok, changeset |> apply_changes()}
    end
  end

  def cast_defaults(changeset) do
    changeset
    |> cast_id()
    |> cast_timestampes()
  end

  def cast_id(changeset) do
    case get_field(changeset, :id) do
      nil -> cast(changeset, %{id: hex(15)}, [:id])
      _ -> changeset
    end
  end

  def cast_timestampes(changeset) do
    case get_field(changeset, :created_at) do
      nil ->
        cast(changeset, %{created_at: DateTime.utc_now(), updated_at: DateTime.utc_now()}, [
          :created_at,
          :updated_at
        ])

      _ ->
        cast(changeset, %{updated_at: DateTime.utc_now()}, [:updated_at])
    end
  end

  def path(meta) do
    [_, _, _, _, path, _] = meta |> Map.values()
    path
  end

  def module(path) do
    case modules() |> Enum.find(fn {_, table} -> path == table end) do
      nil -> nil
      {module, _} -> module
    end
  end

  def modules() do
    {:ok, modules} = :application.get_key(:five9s, :modules)

    Enum.map(modules, fn m ->
      try do
        [_, _, _, _, path, _] = m.__struct__.__meta__ |> Map.values()

        {m, path}
      rescue
        _ -> nil
      end
    end)
    |> Enum.reject(fn m -> is_nil(m) end)
  end

  defmodule SchemaError do
    def validation_message(error) do
      keys = Keyword.keys(error)
      message_for(keys, error, [])
    end

    def message_for([k | t], kl, errors) do
      {message, _} = kl[k]
      message_for(t, kl, ["#{k} #{message}" | errors])
    end

    def message_for([], _, errors), do: Enum.reverse(errors) |> Enum.join(", ")
    defexception message: "Schema Error"
  end
end
