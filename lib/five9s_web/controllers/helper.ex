defmodule Five9sWeb.Helper do
  def render_type(conn) do
    case conn.request_path |> String.contains?(".json") do
      true -> "json"
      _ -> "html"
    end
  end
end
