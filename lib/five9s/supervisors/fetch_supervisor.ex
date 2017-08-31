defmodule Five9s.Supervisors.FetchSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: Five9s.Supervisors.FetchSupervisor)
  end

  def init([]) do
    children = [worker(Five9s.Workers.Fetcher, [], id: :one)]
    supervise(children, strategy: :one_for_one)
  end

  def pid do
    {_, pid, _, _} = Supervisor.which_children(__MODULE__)
                     |> Enum.filter(fn(x) -> elem(x, 3) == [Five9s.Workers.Fetcher] end)
                     |> Enum.at(0)
    pid
  end

  def fetch do
    pid() |> Five9s.Workers.Fetcher.config()
  end
end
