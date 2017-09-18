defmodule Five9sWeb.PageControllerTest do
  use Five9sWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200)
  end

  test "GET /status", %{conn: conn} do
    conn = get conn, "/status"
    assert html_response(conn, 200)
  end
end
