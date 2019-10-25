defmodule Five9s.Incident.Update do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder, except: [:__meta__]}
  schema "" do
    field :id
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
    field :description
  end

  def changeset(incident, params) do
    incident
    |> cast(params, [:description])
    |> Five9s.Repo.cast_defaults()
  end
end
