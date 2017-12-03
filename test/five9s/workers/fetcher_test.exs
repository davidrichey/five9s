defmodule Five9s.Workers.FetcherTest do
  use ExUnit.Case
  import Mock
  #
  # test "ping - 200" do
  #   config = %{"pings" => [%{"name" => "APP", "url" => "http://localhost:4000/url"}]}
  #
  #   with_mocks([
  #     {HTTPoison, [], [get: fn(_url) -> {:ok, %{status_code: 200}} end]},
  #     {Five9s.Supervisors.FetchSupervisor, [], [fetch: fn(_) -> config end]},
  #     {Five9sWeb.Endpoint, [], [broadcast: fn(_, _, _) -> true end]}
  #   ]) do
  #     Five9s.Workers.Ping.handle_info({:ping}, %{})
  #     assert called Five9sWeb.Endpoint.broadcast("ping:APP", "ping", %{"time" => :_, "value" => 100})
  #   end
  # end


  test "fetch_config - yml" do
    txt = Poison.encode!(%{
      "statusPageName" => "Malartu",
      "statusPageDescription" => "Status page for Malartu",
      "image" => "https://s3.amazonaws.com"
    })

    Application.put_env(:five9s, :configs, :yml)
    with_mocks([
      {File, [], [read!: fn(_) -> txt end, cwd!: fn() -> true end]},
    ]) do
      page = Five9s.Workers.Fetcher.fetch_config("page")
      assert page == txt
    end
  end

  test "fetch_config - s3 - 200" do
    json = Poison.encode!(%{
      "statusPageName" => "Malartu",
      "statusPageDescription" => "Status page for Malartu",
      "image" => "https://s3.amazonaws.com"
    })

    Application.put_env(:five9s, :configs, :s3)
    Application.put_env(:five9s, :s3_bucket, "test")
    with_mocks([
      {HTTPoison, [], [get: fn("https://s3.amazonaws.com/test/page.json") -> {:ok, %{body: json, status_code: 200}} end]},
    ]) do
      page = Five9s.Workers.Fetcher.fetch_config("page")
      assert page == json
    end
  end

  test "fetch_config - s3 - no bucket environment variable" do
    Application.put_env(:five9s, :configs, :s3)
    Application.delete_env(:five9s, :s3_bucket)
    page = Five9s.Workers.Fetcher.fetch_config("page")
    assert page == "{\"page\": []}"
  end

  test "fetch_config - s3 - 404" do
    Application.put_env(:five9s, :configs, :s3)
    Application.put_env(:five9s, :s3_bucket, "test")
    with_mocks([
      {HTTPoison, [], [get: fn("https://s3.amazonaws.com/test/page.json") -> {:ok, %{status_code: 404}} end]},
    ]) do
      page = Five9s.Workers.Fetcher.fetch_config("page")
      assert page == "{\"page\": []}"
    end
  end

  test "fetch_config - s3 - error" do
    Application.put_env(:five9s, :configs, :s3)
    Application.put_env(:five9s, :s3_bucket, "test")
    with_mocks([
      {HTTPoison, [], [get: fn("https://s3.amazonaws.com/test/page.json") -> {:error, %{reason: 500}} end]},
    ]) do
      page = Five9s.Workers.Fetcher.fetch_config("page")
      assert page == "{\"page\": []}"
    end
  end
end
