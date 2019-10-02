defmodule Five9s.Repo do
  use Ecto.Repo,
    otp_app: :five9s,
    adapter: Ecto.Adapters.Postgres
end
