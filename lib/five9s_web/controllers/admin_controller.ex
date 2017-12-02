defmodule Five9sWeb.AdminController do
  use Five9sWeb, :controller
  require Logger

  def services(conn, %{"key" => k, "verifier" => v}) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    external_services = get_in(config, ["external_services"]) || []
    render conn, "services.html", %{external_services: external_services, key: k, verifier: v}
  end

  def update_service(conn, params = %{"service" => s, "value" => v}) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    external_services = get_in(config, ["external_services"]) || []
    services = Enum.map(external_services, fn(%{"name" => n, "status" => st}) ->
      case n == s do
        true -> %{"name" => n, "status" => v}
        _ -> %{"name" => n, "status" => st}
      end
    end)
    Logger.debug "External Services updated: #{inspect services}"
    json = %{"external_services" => services}
    Process.send(Five9s.Workers.Fetcher, {:update, json}, [])
    Five9s.S3.put_object(%{json: json, name: "external_services"})

    render conn, "services.html", %{external_services: services, key: params["key"], verifier: params["verifier"]}
  end
end
