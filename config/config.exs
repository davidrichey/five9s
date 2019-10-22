# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# config :five9s,
#   ecto_repos: []

# Configures the endpoint
config :five9s, Five9sWeb.Endpoint,
  url: [host: "localhost"],
  # TODO: Move to secret
  secret_key_base: "HG0+/heBHk7Mz+FD0r9/z7G46U9YK4payR2hHVI0sKEZufLPCiuZKv2XX5oxMO1G",
  render_errors: [view: Five9sWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Five9s.PubSub, adapter: Phoenix.PubSub.PG2],
  # TODO: Move to secret
  live_view: [signing_salt: "mDL1jpi9XsBRyBDJQMUH0ImFb1tumCsC"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :five9s,
  name: "Malartu",
  description:
    "Malartu provides managers with the answers to the most important questions in your business: How healthy is my business?  Where are we headed? How does that compare to my peers?"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
