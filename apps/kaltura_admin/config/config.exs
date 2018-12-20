# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :kaltura_admin, ecto_repos: [KalturaAdmin.Repo]

# Configures the endpoint
config :kaltura_admin, KalturaAdmin.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "toHibrVaZOP7yUT8rKUeqPXuNqbiDWP5JaRwct2R2Xn3Gm67Cv8CZSTOcws76Euu",
  render_errors: [view: KalturaAdmin.ErrorView, accepts: ~w(html json)],
  pubsub: [name: KalturaAdmin.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :kaltura_admin, KalturaAdmin.Authorization.Guardian,
  issuer: "SimpleAuth",
  secret_key: "U7fWw3uDlga9DRB"

config :kaltura_admin, :generators, context_app: :kaltura_admin

config :kaltura_admin, :public_api, module: KalturaAdmin.PublicApi

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
