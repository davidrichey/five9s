defmodule Five9s.Service do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder, except: [:__meta__]}
  schema "services" do
    field :id
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
    field :name
    field :description
    field :status
    field :source, :map
    field :url
  end

  def changeset(service, params) do
    service
    |> cast(params, [:name, :description, :source, :status, :url])
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
