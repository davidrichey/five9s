defmodule Five9sWeb.Admin.ServiceController do
  use Five9sWeb, :controller
  require Logger

  def index(conn, %{"key" => k, "verifier" => v}) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    external_services = get_in(config, ["external_services"]) || []

    render(conn, "index.html", %{
      external_services: external_services,
      key: k,
      verifier: v
    })
  end

  def create(conn, obj = %{"form" => %{"name" => service}}) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    external_services = get_in(config, ["external_services"]) || []
    service = %{"name" => service, "status" => "ok"}
    external_services = external_services ++ [service]

    external_services =
      external_services |> Enum.sort_by(fn i -> i["name"] |> String.downcase() end)

    Logger.debug("Services now include: #{inspect(service)}; #{inspect(external_services)}")

    json = %{"external_services" => external_services}
    Process.send(Five9s.Workers.Fetcher, {:update, json}, [])

    Five9s.S3.put_object(%{json: json, name: "external_services"})

    render(conn, "index.html", %{
      external_services: external_services,
      key: obj["form"]["key"],
      verifier: obj["form"]["verifier"]
    })
  end

  def update(conn, params = %{"service" => s, "value" => v}) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    external_services = get_in(config, ["external_services"]) || []

    services =
      Enum.map(external_services, fn %{"name" => n, "status" => st} ->
        case n == s do
          true -> %{"name" => n, "status" => v}
          _ -> %{"name" => n, "status" => st}
        end
      end)

    Logger.debug("External Services updated: #{inspect(services)}")
    json = %{"external_services" => services}
    Process.send(Five9s.Workers.Fetcher, {:update, json}, [])
    Five9s.S3.put_object(%{json: json, name: "external_services"})

    render(conn, "index.html", %{
      external_services: services,
      key: params["key"],
      verifier: params["verifier"]
    })
  end

  def delete(conn, params = %{"service" => s}) do
    config = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
    external_services = get_in(config, ["external_services"]) || []
    services = Enum.filter(external_services, fn %{"name" => n} -> n != s end)

    Logger.debug("External Services Updated: #{inspect(services)}")
    json = %{"external_services" => services}
    Process.send(Five9s.Workers.Fetcher, {:update, json}, [])
    Five9s.S3.put_object(%{json: json, name: "external_services"})

    render(conn, "index.html", %{
      external_services: services,
      key: params["key"],
      verifier: params["verifier"]
    })
  end
end
