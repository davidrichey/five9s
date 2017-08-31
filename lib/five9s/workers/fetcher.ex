defmodule Five9s.Workers.Fetcher do
  import Logger
  use GenServer

  def init(_) do
    Logger.info("init")
    Process.send_after(self(), {:fetch}, 1000)
    {:ok, %{}}
  end

  def start_link do
    Logger.info("starting")
    GenServer.start_link(__MODULE__, [])
  end

  def config(pid), do: GenServer.call(pid, {:config})
  def handle_call({:config}, _from, config) do
    {:reply, config, config}
  end

  def schedule_next_run do
    Process.send_after(self(), {:fetch}, 1000 * seconds_until_the_next_hour())

    Logger.debug "Scheduling in #{seconds_until_the_next_hour()} seconds"
  end

  def seconds_until_the_next_hour do
    10
    # (60 - Time.utc_now.minute) * 60
  end

  def handle_info({:fetch}, _s) do
    schedule_next_run()
    Logger.info "Fetching"
    state = %{
      "page" => fetch_page(),
      "incidents" => fetch_incidents(),
      "maintenance" => fetch_maintenance()
    }
    {:noreply, state}
  end

  def fetch_page do
    txt = File.read!("#{File.cwd!}/config/five9s/page.json")
    Logger.debug txt
    Poison.decode!(txt)
  end

  def fetch_incidents do
    txt = File.read!("#{File.cwd!}/config/five9s/incidents.json")
    Logger.debug txt
    Poison.decode!(txt)["incidents"] || []
  end

  def fetch_maintenance do
    txt = File.read!("#{File.cwd!}/config/five9s/maintenance.json")
    Logger.debug txt
    Poison.decode!(txt)["maintenance"] || []
  end
end
