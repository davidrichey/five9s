defmodule Five9s.Workers.Fetcher do
  use GenServer
  require Logger

  def init(_) do
    Process.send_after(self(), {:fetch}, 1000)
    {:ok, %{}}
  end

  def start_link do
    Logger.debug("Starting fetcher")
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def config(pid), do: GenServer.call(pid, {:config})
  def handle_call({:config}, _from, config) do
    {:reply, config, config}
  end

  def schedule_next_run do
    Process.send_after(self(), {:fetch}, schedule_at())

    Logger.info "Scheduling in #{schedule_at()} ms"
  end

  def schedule_at do
    # (60 - Time.utc_now.minute) * 60
    1000 * 5 * 60
  end

  def handle_info({:fetch}, _s) do
    schedule_next_run()
    Logger.info "Fetching"
    state = %{
      "page" => fetch_page(),
      "incidents" => fetch_incidents(),
      "maintenance" => fetch_maintenance(),
      "pings" => fetch_pings(),
      "external_services" => fetch_external_services()
    }
    {:noreply, state}
  end

  def handle_info({:update, map}, state) do
    Logger.info "Updating #{Map.keys(map) |> Enum.join(", ")}"
    {:noreply, Map.merge(state, map)}
  end

  @doc """
  Fetches the External Services configuration file

  ## Examples
    iex> Fetcher.fetch_external_services()
    %{ "external_services" => [
      %{ "name": "Salesforce", "status": "ok" }
    ]}
  """
  def fetch_external_services do
    txt = fetch_config("external_services")
    Logger.debug txt
    Poison.decode!(txt)["external_services"]
  end

  @doc """
  Fetches the Page configuration file

  ## Examples
    iex> Fetcher.fetch_page()
    %{
      "statusPageName" => "Malartu",
      "statusPageDescription" => "Status page for Malartu",
      "image" => "https://s3.amazonaws.com/"
    }

  """
  def fetch_page do
    txt = fetch_config("page")
    Logger.debug txt
    Poison.decode!(txt)
  end

  @doc """
  Fetches the Incidents configuration file

  ## Examples
    iex> Fetcher.fetch_incidents()
    %{ "incidents" => [%{
      "title" => "500 Errors",
      "description" => "We are investigating high 500 responses from app.malartu.co",
      "timestamp" => "2017-09-15 18:29:00Z",
      "resolution_at" => "2017-09-15 19:18:00Z",
      "resolution" => "We have moved AWS hosted regions. AWS is experiences erros in US-EAST-1. http://status.aws.amazon.com/"
    }]}
  """
  def fetch_incidents do
    txt = fetch_config("incidents")
    Logger.debug txt
    (Poison.decode!(txt)["incidents"] || [])
    |> Enum.sort_by(fn(i) -> i["timestamp"] end)
    |> Enum.reverse()
    |> Enum.map(fn(i) ->
      Map.merge(i, %{ "active" => i["resolution_at"] == nil })
    end)
  end

  @doc """
  Fetches the Maintance configuration file

  ## Examples
    iex> Fetcher.fetch_maintenance()
    %{ "maintenance" => [%{
      "name" => "DB Cleanup",
      "description" => "We are investigating higher than usual response time",
      "start_time" => "2017-10-31T00:21:55Z",
      "end_time" => "2017-10-31T01:41:55Z",
      "severity" => "minor",
      "components" => "Backend, API"
    }]}
  """
  def fetch_maintenance do
    txt = fetch_config("maintenance")

    Logger.debug txt
    all = (Poison.decode!(txt)["maintenance"] || [])
    |> Enum.map(fn(i) ->
      now = DateTime.utc_now()
      {:ok, st, _} = DateTime.from_iso8601(i["start_time"])
      {:ok, et, _} = DateTime.from_iso8601(i["end_time"])
      stc = DateTime.compare(st, now)
      etc = DateTime.compare(et, now)
      Map.merge(i, %{
        "active" => Enum.member?([:lt, :eq], stc) && Enum.member?([:gt, :eq], etc),
        "relevant" => Enum.member?([:gt, :eq], stc) || Enum.member?([:gt, :eq], etc)
      })
    end)
    Enum.filter(all, fn(a) -> a["relevant"] end)
  end

  @doc """
  Fetches the Pings configuration file

  ## Examples
    iex> Fetcher.fetch_pings()
    %{ "pings" => [
      %{"url" => "http://www.example.com", "name" => "App Name"}
    ]}
  """
  def fetch_pings do
    txt = fetch_config("pings")
    Logger.debug txt
    Poison.decode!(txt)["pings"] || []
  end


  @doc """
  Fetches the configuration file based off of keys set

  Returns JSON String
  """
  def fetch_config(type) do
    case Application.fetch_env(:five9s, :configs) do
      {:ok, :yml} ->
        File.read!("#{File.cwd!}/config/five9s/#{type}.json")
      {:ok, :s3} ->
        fetch_s3(type)
    end
  end

  defp fetch_s3(type) do
    case Application.fetch_env(:five9s, :s3_bucket) do
      {:ok, bucket} ->
        case HTTPoison.get("https://s3.amazonaws.com/#{bucket}/#{type}.json") do
          {:ok, rsp} ->
            case rsp.status_code do
              200 -> rsp.body || "{\"#{type}\": []}"
              code ->
                Logger.error("Fetching #{type} gave status #{code}")
                "{\"#{type}\": []}"
            end
          {:error, rsp} ->
            Logger.error("Fetching Incidents error: #{rsp.reason}")
            "{\"#{type}\": []}"
        end
      _ ->
        Logger.error("Fetching Incidents error: no s3_bucket variable")
        "{\"#{type}\": []}"
    end
  end
end
