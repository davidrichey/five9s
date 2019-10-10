defmodule Five9s.RepoTest do
  use Five9s.DataCase

  alias Five9s.Incident

  test "insert & get" do
    {:ok, record} =
      Incident.changeset(%Incident{}, %{name: "Test"})
      |> Repo.insert()

    saved = Repo.get(Incident, record.id)

    assert record == saved
  end

  test "insert on error" do
    changeset = Incident.changeset(%Incident{}, %{})
    {:error, _} = changeset |> Repo.insert()

    assert Repo.get(Incident, changeset.changes.id) == nil
  end

  test "insert & update & get" do
    {:ok, record} =
      Incident.changeset(%Incident{}, %{name: "Test"})
      |> Repo.insert()

    {:ok, record} =
      Incident.changeset(record, %{name: "Test It"})
      |> Repo.update()

    assert record.name == "Test It"
  end

  test "insert & delete & get nil" do
    {:ok, record} =
      Incident.changeset(%Incident{}, %{name: "Test"})
      |> Repo.insert()

    {:ok} = Repo.delete(Incident, record.id)

    assert Repo.get(Incident, record.id) == nil
  end
end
