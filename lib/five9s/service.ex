defmodule Five9s.Service do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "services" do
    field :id
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
    field :name
    field :description
    field :status
    field :source, :map
  end

  def changeset(service, params) do
    service
    |> cast(params, [:name, :description, :source, :status])
    |> Five9s.Repo.cast_defaults()
  end
end

# %{
#   name: "Service name",
#   status: "ok" # , "degraded", "broken"
#   description: "",
#   source: %{
#     type: "webhook",
#     id: "https://...."
#   }, # %{type: "manual", id: "apikey"}
# }
