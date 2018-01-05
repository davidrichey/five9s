use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :five9s, Five9sWeb.Endpoint,
  http: [port: 4001],
  secret_key_base: :crypto.strong_rand_bytes(200) |> Base.url_encode64 |> binary_part(0, 200),
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :five9s,
       configs: :s3, # :yml, :s3
       s3_bucket: "test.s3.me", # required if configs == :s3
       admin_key: "admin",
       admin_verifier: "verified"
