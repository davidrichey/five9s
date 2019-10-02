defmodule Five9s.Incident do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "" do
    field :id
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
    field :name
    field :updates, {:array, :map}
    field :resolution, :map
  end

  def changeset(incident, params) do
    incident
    |> cast(params, [:name, :resolution])
    |> Five9s.Repo.cast_id()
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
