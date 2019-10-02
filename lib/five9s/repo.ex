defmodule Five9s.Repo do
  import Ecto.Changeset

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

  def cast_id(changeset) do
    case get_field(changeset, :id) do
      nil -> cast(changeset, %{id: hex(15)}, [:id])
      _ -> changeset
    end
  end
end
