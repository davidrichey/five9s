defmodule Five9sWeb.Plugs.Admin do
  def verfy_admin_request(conn, _) do
    k = conn.params["key"] || ""
    v = conn.params["verifier"] || ""
    cond do
      {Application.get_env(:five9s, :admin_key), Application.get_env(:five9s, :admin_verifier)} == {k, v} ->
        conn
      true -> unauthorized(conn)
    end
  end

  defp unauthorized(conn) do
    conn
    |> Plug.Conn.put_status(401)
    |> Phoenix.Controller.render(Five9sWeb.ErrorView, "unauthorized.html")
    |> Plug.Conn.halt
  end
end
