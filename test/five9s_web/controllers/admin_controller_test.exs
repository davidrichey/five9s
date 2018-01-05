defmodule Five9sWeb.AdminControllerTest do
  use Five9sWeb.ConnCase
  import Mock

  test "GET /status/admin/services", %{conn: conn} do
    conn = get conn, "/status/admin/services?key=admin&verifier=verified"
    assert html_response(conn, 200)
  end

  test "GET /status/admin/services - 401", %{conn: conn} do
    conn = get conn, "/status/admin/services?key=admin&verifier=wrong"
    assert html_response(conn, 401)
  end

  test "GET /status/admin/incidents", %{conn: conn} do
    conn = get conn, "/status/admin/incidents?key=admin&verifier=verified"
    assert html_response(conn, 200)
  end

  test "GET /status/admin/maintenance", %{conn: conn} do
    conn = get conn, "/status/admin/maintenance?key=admin&verifier=verified"
    assert html_response(conn, 200)
  end

  test "POST /status/admin/services", %{conn: conn} do
    with_mock Five9s.S3, [put_object: fn(_) -> :ok end] do
      json = %{
        "external_services" => [
          %{"name" => "Stripe", "status" => "ok"},
          %{"name" => "Twitter", "status" => "ok"}
        ]
      }
      Process.send(Five9s.Workers.Fetcher, {:update, json}, [])

      conn = post conn, "/status/admin/services?key=admin&verifier=verified&service=Twitter&value=delay&key=admin&verifier=verified"
      assert html_response(conn, 200)
      updated = %{
        "external_services" => [
          %{"name" => "Stripe", "status" => "ok"},
          %{"name" => "Twitter", "status" => "delay"}
        ]
      } = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
      assert Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher) == updated
      %{"external_services" => json} = updated
      assert called Five9s.S3.put_object(%{json: %{"external_services" => json}, name: "external_services"})
    end
  end

  test "POST /status/admin/incident", %{conn: conn} do # TODO: left off here
    with_mock Five9s.S3, [put_object: fn(_) -> :ok end] do
      obj = %{"description" => "My test incident", "title" => "Test"}
      json = %{ "incidents" => [] }
      Process.send(Five9s.Workers.Fetcher, {:update, json}, [])

      conn = post conn, "/status/admin/incident?key=admin&verifier=verified", %{"form" => obj}
      assert html_response(conn, 200)
      obj = %{ "incidents" => [%{
        "active" => true, "description" => "My test incident", "title" => "Test",
        "timestamp" => _}]} = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
      assert Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher) == obj
      %{"incidents" => json} = obj
      assert called Five9s.S3.put_object(%{json: %{"incidents" => json}, name: "incidents"})
    end
  end

  test "POST /status/admin/resolve", %{conn: conn} do # TODO: left off here
    with_mock Five9s.S3, [put_object: fn(_) -> :ok end] do
      ts = "2018-01-05 20:09:38.221082Z"
      json = %{"incidents" => [%{
        "active" => true, "description" => "My test incident",
        "timestamp" => ts, "title" => "Test"
      }]}
      Process.send(Five9s.Workers.Fetcher, {:update, json}, [])

      conn = post conn, "/status/admin/incident/resolve?key=admin&verifier=verified", %{"timestamp" => ts}
      assert html_response(conn, 200)
      obj = %{ "incidents" => [%{
        "active" => false, "description" => "My test incident", "title" => "Test",
        "resolution" => "Resolved", "resolution_at" => _,
        "timestamp" => _}]} = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
      assert Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher) == obj
      %{"incidents" => json} = obj
      assert called Five9s.S3.put_object(%{json: %{"incidents" => json}, name: "incidents"})
    end
  end

  test "POST /status/admin/maintenance", %{conn: conn} do # TODO: left off here
    with_mock Five9s.S3, [put_object: fn(_) -> :ok end] do
      obj = %{
        "components" => "API", "description" => "1234",
        "end_time" => "2017-12-01T05:05:00Z", "name" => "Test",
        "severity" => "minor", "start_time" => "2017-12-01T05:00:00Z"
      }
      json = %{ "maintenance" => [] }
      Process.send(Five9s.Workers.Fetcher, {:update, json}, [])

      conn = post conn, "/status/admin/maintenance?key=admin&verifier=verified", %{"form" => obj}
      assert html_response(conn, 200)
      obj = %{ "maintenance" => [%{
        "components" => "API", "description" => "1234",
        "end_time" => "2017-12-01T05:05:00Z", "name" => "Test",
        "severity" => "minor", "start_time" => "2017-12-01T05:00:00Z",
        "active" => false, "relevant" => false, "timestamp" => _
      }]} = Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher)
      assert Five9s.Supervisors.FetchSupervisor.fetch(Five9s.Workers.Fetcher) == obj
      %{"maintenance" => json} = obj
      assert called Five9s.S3.put_object(%{json: %{"maintenance" => json}, name: "maintenance"})
    end
  end
end
