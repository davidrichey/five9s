defmodule Five9s.Supervisors.FetchSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: Five9s.Supervisors.FetchSupervisor)
  end

  def init([]) do
    children = [
      worker(Five9s.Workers.Fetcher, [], id: :fetch),
      worker(Five9s.Workers.Ping, [], id: :ping)
    ]
    supervise(children, strategy: :one_for_one)
  end

  def pid(mod) do
    {_, pid, _, _} = Supervisor.which_children(__MODULE__)
                     |> Enum.filter(fn(x) -> elem(x, 3) == [mod] end)
                     |> Enum.at(0)
    pid
  end

  def fetch(mod) do
    pid(mod) |> mod.config()
  end
end
