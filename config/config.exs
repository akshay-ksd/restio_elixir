# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :pos,
  ecto_repos: [Pos.Repo]

# Configures the endpoint
config :pos, PosWeb.Endpoint,
  url: [host: "prickly-flawed-pronghorn.gigalixirapp.com"],
  secret_key_base: "pUSuI3RKtmRWUuau0BVQey7UHvt1l5s7EzK/H0wFJ0B1q2Y1pOnsj+d28A0XQl5z",
  render_errors: [view: PosWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Pos.PubSub,
  live_view: [signing_salt: "fZ4aSAS6"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
