defmodule Five9s.IncidentTest do
  use Five9s.DataCase

  alias Five9s.Incident

  test "insert" do
    {:ok, _record} =
      Incident.changeset(%Incident{}, %{
        name: "Test",
        updates: [
          %{description: "testing..."}
        ]
      })
      |> Repo.insert()
  end
end
