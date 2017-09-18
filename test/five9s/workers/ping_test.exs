defmodule Five9s.Workers.PingTest do
  use ExUnit.Case
  import Mock

  test "ping - 200" do
    config = %{"pings" => [%{"name" => "APP", "url" => "http://localhost:4000/url"}]}

    with_mocks([
      {HTTPoison, [], [get: fn(_url) -> {:ok, %{status_code: 200}} end]},
      {Five9s.Supervisors.FetchSupervisor, [], [fetch: fn(_) -> config end]},
      {Five9sWeb.Endpoint, [], [broadcast: fn(_, _, _) -> true end]}
    ]) do
      Five9s.Workers.Ping.handle_info({:ping}, %{})
      assert called Five9sWeb.Endpoint.broadcast("ping:APP", "ping", %{"time" => :_, "value" => 100})
    end
  end

  test "ping - 404" do
    config = %{"pings" => [%{"name" => "APP", "url" => "http://localhost:4000/url"}]}

    with_mocks([
      {HTTPoison, [], [get: fn(_url) -> {:ok, %{status_code: 404}} end]},
      {Five9s.Supervisors.FetchSupervisor, [], [fetch: fn(_) -> config end]},
      {Five9sWeb.Endpoint, [], [broadcast: fn(_, _, _) -> true end]}
    ]) do
      Five9s.Workers.Ping.handle_info({:ping}, %{})
      assert called Five9sWeb.Endpoint.broadcast("ping:APP", "ping", %{"time" => :_, "value" => 0})
    end
  end

  test "ping - connection error" do
    config = %{
      "pings" => [
        %{
          "name" => "APP",
          "url" => "http://localhost:4000/url",
          "status" => 200
        }
      ]
    }

    with_mocks([
      {HTTPoison, [], [get: fn(_url) -> {:error, %{reason: "Didn't work"}} end]},
      {Five9s.Supervisors.FetchSupervisor, [], [fetch: fn(_) -> config end]},
      {Five9sWeb.Endpoint, [], [broadcast: fn(_, _, _) -> true end]}
    ]) do
      Five9s.Workers.Ping.handle_info({:ping}, %{})
      # Tests that make the expected call
      assert called Five9sWeb.Endpoint.broadcast("ping:APP", "ping", %{"time" => :_, "value" => 0})
    end
  end

  # Malartu
  test "integration - malartu - 200" do
    config = %{"malartu" => %{"uid" => "tester"}}
    System.put_env("MALARTU_APIKEY", "abcde")
    with_mocks([
      {HTTPoison, [], [post: fn(_, _, _) -> {:ok, %HTTPoison.Response{status_code: 200}} end]},
    ]) do
      Five9s.Workers.Ping.send_to_integrations(config, 100)
      json = Poison.encode!(%{"apikey" => "abcde", "topic" => config["malartu"]["uid"], "value" => 100})
      assert called HTTPoison.post("https://api.malartu.co/v0/kpi/tracking/data", json, :_)
    end
  end

  test "integration - malartu - 422" do
    config = %{"malartu" => %{"uid" => "tester"}}
    System.put_env("MALARTU_APIKEY", "abcde")
    with_mocks([
      {HTTPoison, [], [post: fn(_, _, _) -> {:ok, %HTTPoison.Response{status_code: 422}} end]},
    ]) do
      Five9s.Workers.Ping.send_to_integrations(config, 100)
      json = Poison.encode!(%{"apikey" => "abcde", "topic" => config["malartu"]["uid"], "value" => 100})
      assert called HTTPoison.post("https://api.malartu.co/v0/kpi/tracking/data", json, :_)
    end
  end

  # Zapier
  test "integration - zapier - 200" do
    config = %{"zapier" => "http://localhost:3000"}
    System.put_env("MALARTU_APIKEY", "abcde")
    with_mocks([
      {HTTPoison, [], [post: fn(_, _) -> {:ok, %HTTPoison.Response{status_code: 200}} end]},
    ]) do
      Five9s.Workers.Ping.send_to_integrations(config, 100)
      assert called HTTPoison.post(config["zapier"], "100")
    end
  end

  test "integration - zapier - 422" do
    config = %{"zapier" => %{"uid" => "tester"}}
    System.put_env("MALARTU_APIKEY", "abcde")
    with_mocks([
      {HTTPoison, [], [post: fn(_, _) -> {:ok, %HTTPoison.Response{status_code: 422}} end]},
    ]) do
      Five9s.Workers.Ping.send_to_integrations(config, 100)
      assert called HTTPoison.post(config["zapier"], "100")
    end
  end
end
