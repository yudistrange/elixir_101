# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :elixir_101,
  ecto_repos: [Elixir101.Repo]

# Configures the endpoint
config :elixir_101, Elixir101Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Jc59wHVnKcRKVzD+HFz7uR8E+Ujv/sYJakGIrMfc2gdxWYarwitMD82Mk+DM80E5",
  render_errors: [view: Elixir101Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Elixir101.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "SyGY/b6Q"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
