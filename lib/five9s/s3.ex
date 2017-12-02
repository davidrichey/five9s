defmodule Five9s.S3 do
  require Logger

  def put_object(obj) do
    config = {Application.get_env(:five9s, :configs), Application.get_env(:five9s, :s3_bucket)}
    case config do
      {:s3, bucket} -> write(obj, bucket)
      _ -> {:error, "S3 is not configured"}
    end
  end

  def write(%{json: json, name: name}, bucket) do
    text = Poison.encode!(json)
    response = ExAws.S3.put_object(bucket, "#{name}.json", text, [{:acl, :public_read}])
    |> request()
    case response do
      {:ok, _} -> {:ok, :succes}
      {:error, err} -> Logger.error("Unhandled S3 Write Error: #{inspect err}")
    end
  end

  defp request(object) do
    ExAws.request(object)
  end
end
