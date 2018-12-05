defmodule Five9s.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(Five9sWeb.Endpoint, []),
      # Start your own worker by calling: Five9s.Worker.start_link(arg1, arg2, arg3)
      supervisor(Five9s.Supervisors.FetchSupervisor, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Five9s.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Five9sWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def random_string(l \\ 25) do
    :crypto.strong_rand_bytes(l) |> Base.url_encode64() |> binary_part(0, l)
  end
end
