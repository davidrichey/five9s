defmodule Five9s.Incident do
  use Ecto.Schema
  import Ecto.Changeset
  alias Five9s.Incident.Update

  @primary_key false
  @derive {Jason.Encoder, except: [:__meta__]}
  schema "incidents" do
    field :id
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
    field :name
    field :description
    field :updates, {:array, Ecto.Types.Update}, default: []
    field :resolution, Ecto.Types.Update, default: nil
  end

  def changeset(incident, params) do
    incident
    |> cast(params, [:name, :description])
    |> cast_resolution(params)
    |> cast_updates(params)
    |> validate_required([:name])
    |> Five9s.Repo.cast_defaults()
  end

  def cast_resolution(changeset, params) do
    case params[:resolution] do
      nil ->
        changeset

      %Update{} ->
        changeset

      resolution ->
        case Update.changeset(%Update{}, resolution) |> Five9s.Repo.apply() do
          {:error, error} ->
            raise Five9s.Repo.SchemaError,
              message: Five9s.Repo.SchemaError.validation_message(error)

          {:ok, r} ->
            cast(changeset, %{resolution: r}, [:resolution])
        end
    end
  end

  def cast_updates(changeset, params) do
    updates = params[:updates] || []

    updates =
      Enum.map(updates, fn update ->
        case update do
          %Update{} ->
            update

          _ ->
            case Update.changeset(%Update{}, update) |> Five9s.Repo.apply() do
              {:error, error} ->
                raise Five9s.Repo.SchemaError,
                  message: Five9s.Repo.SchemaError.validation_message(error)

              {:ok, updates} ->
                updates
            end
        end
      end)

    case updates do
      [] -> changeset
      _ -> cast(changeset, %{updates: updates}, [:updates])
    end
  end
end

# %{
#   name: "Incident name",
#   updates: [
#     %Update{
#       description: "We are....",
#       id: "j0892je801892je",
#       created_at: "2019-01-01T00:00:00Z",
#       updated_at: "2019-01-01T00:00:00Z"
#     }
#   ],
#   resolution: %#     %Update{
# {
#     description: "We did...",
#     id: "j0892je801892je",
#     created_at: "2019-01-01T00:00:00Z",
#     updated_at: "2019-01-01T00:00:00Z"
#   },
#   id: "j0892je801892je",
#   created_at: "2019-01-01T00:00:00Z",
#   updated_at: "2019-01-01T00:00:00Z"
# }
