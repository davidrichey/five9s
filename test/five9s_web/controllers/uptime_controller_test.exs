defmodule Five9sWeb.UptimeControllerTest do
  use Five9sWeb.ConnCase
  import Mock

  test "GET /", %{conn: conn} do
    state = %{"ping" => %{
      "API" => [[1506009933000, 0], [1506009993000, 0]],
      "APP" => [[1506009933000, 0], [1506009993000, 0]]
    }}
    with_mocks([
      {Five9s.Supervisors.FetchSupervisor, [], [fetch: fn(_) -> state end]},
    ]) do
      conn = get conn, "/status/uptime"
      json = json_response(conn, 200)
      assert json == %{"uptimes" => %{
        "API" => [[1506009933000, 0], [1506009993000, 0]],
        "APP" => [[1506009933000, 0], [1506009993000, 0]]
      }}
    end
  end
end
