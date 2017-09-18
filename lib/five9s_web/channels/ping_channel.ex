defmodule Five9sWeb.PingChannel do
  use Phoenix.Channel
  require Logger

  def join("ping:" <> ping_app, _p, socket) do
    Logger.info ping_app
    Five9sWeb.Endpoint.broadcast("ping:all","ping", %{test: "me"})
    {:ok, socket}
  end

  def handle_in("ping", all, socket) do
    Logger.info "handling ping"
    Five9sWeb.Endpoint.broadcast!("ping:app", "ping", all)
    broadcast! socket, "ping", all#%{ "app_id" => id, "value" => value }
    {:noreply, socket}
  end
end
