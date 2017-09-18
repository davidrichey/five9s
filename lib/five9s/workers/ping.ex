defmodule Five9s.Workers.Ping do
  require Logger
  use GenServer

  def init(_) do
    Process.send_after(self(), {:ping}, 1000)
    {:ok, %{"ping" => %{}}}
  end

  def start_link do
    Logger.debug("Starting ping worker")
    GenServer.start_link(__MODULE__, [], name: Five9s.Workers.Ping)
  end

  def config(pid), do: GenServer.call(pid, {:config})
  def handle_call({:config}, _from, config) do
    {:reply, config, config}
  end

  def handle_info({:state, app, time, value, config}, state) do
    app_pings = state["ping"][app] || []
    send_to_integrations(config, value)
    concatted = app_pings ++ [[time * 1000, value]]
                |> Enum.reverse()
                |> Enum.take(60 * 24 * 7) # one week of minute data
                |> Enum.reverse()
    nstate = Map.merge(state["ping"], %{ app => concatted } )
    {:noreply, %{ "ping" => nstate }}
  end

  def handle_info({:ping}, state) do
    Process.send_after(self(), {:ping}, 1000 * 60) # One minute
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)["pings"]
    Enum.each(config, fn(x) -> ping_config(x) end)
    {:noreply, state}
  end

  def ping_config(config = %{ "url" => url }) do
    Logger.debug "Pinging #{config["name"]} - #{url}"
    {co, rsp} = HTTPoison.get(url)
    case co do
      :ok ->
        value = if rsp.status_code == 200, do: 100, else: 0
        time = DateTime.utc_now() |> DateTime.to_unix()
        Five9sWeb.Endpoint.broadcast("ping:#{config["name"]}","ping", %{"time" => time/1000, "value" => value})
        Process.send_after(self(), {:state, config["name"], time, value, config}, 0)
      _e ->
        value = 0
        time = DateTime.utc_now() |> DateTime.to_unix()
        Five9sWeb.Endpoint.broadcast("ping:#{config["name"]}","ping", %{"time" => time/1000, "value" => value})
        Process.send_after(self(), {:state, config["name"], time, value, config}, 0)
        Logger.warn("Ping #{url} gave back #{rsp.reason}")
    end
  end

  # Integrations
  def send_to_integrations(config, value) do
    send_to_malartu(config["malartu"], value, System.get_env("MALARTU_APIKEY"))
    send_to_zapier(config["zapier"], value)
  end

  defp send_to_malartu(%{"uid" => uid}, value, "" <> key) do
    json = Poison.encode!(%{"apikey" => key, "topic" => uid, "value" => value})
    result = HTTPoison.post("https://api.malartu.co/v0/kpi/tracking/data", json, [{"Content-Type", "application/json"}])
    case result do
      {:ok, %HTTPoison.Response{status_code: 200}} -> true
      {:ok, resp} ->
        Logger.warn("Malartu response code: #{resp.status_code}; body #{resp.body}")
      {code, rsp} ->
        Logger.warn("Malartu post error: #{code}; body #{rsp.reason}")
    end
  end
  defp send_to_malartu(_, _, _), do: Logger.debug("Did not meet all requirements to send to Malartu")

  defp send_to_zapier(nil, _), do: Logger.debug("Did not meet all requirements to send to Zapier")
  defp send_to_zapier(url, value) do
    case HTTPoison.post url, Integer.to_string(value) do
      {:ok, %HTTPoison.Response{status_code: 200}} -> true
      {:ok, resp} ->
        Logger.warn("Zapier response code: #{resp.status_code}; body #{resp.body}")
      {code, rsp} ->
        Logger.warn("Zapier post error: #{code}; body #{rsp.reason}")
    end
  end
end
