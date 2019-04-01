# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :cti_kaltura, ecto_repos: [CtiKaltura.Repo]

# Configures the endpoint
config :cti_kaltura, CtiKaltura.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "toHibrVaZOP7yUT8rKUeqPXuNqbiDWP5JaRwct2R2Xn3Gm67Cv8CZSTOcws76Euu",
  render_errors: [view: CtiKaltura.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CtiKaltura.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :cti_kaltura, CtiKaltura.Authorization.Guardian,
  issuer: "SimpleAuth",
  secret_key: "U7fWw3uDlga9DRB"

config :cti_kaltura, :generators, context_app: :cti_kaltura

config :cti_kaltura, :public_api, module: CtiKaltura.PublicApi

config :cti_kaltura, domain_model_handler: CtiKaltura.Handlers.DomainModelHandler

# Timeout in milliseconds
config :cti_kaltura, after_start_callback_timeout: 3000

config :cti_kaltura, CtiKaltura.RequestProcessing.MainRouter,
  http_port: [dev: 4001, test: 4003, prod: 81, stage: 4001]

config :plug, validate_header_keys_during_test: false

config :cti_kaltura, :env, current: Mix.env()

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
