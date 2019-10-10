defmodule Five9sWeb.Admin.IncidentControllerTest do
  use Five9sWeb.ConnCase
  alias Five9s.Incident

  test "POST /admin/incidnets", %{conn: conn} do
    count = Five9s.Repo.all(Incident) |> Enum.count()

    conn =
      post(conn, "/admin/incidents", %{
        incident: %{
          name: "Test1"
        }
      })

    assert Five9s.Repo.all(Incident) |> Enum.count() == count + 1
    assert redirected_to(conn, 302) == "/admin/incidents"
  end
end
