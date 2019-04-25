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
  http_port: [
    dev:
      (fn
         nil ->
           4001

         port ->
           {number, ""} = Integer.parse(port)
           number
       end).(System.get_env("API_PORT")),
    test: 4003,
    prod: 4001,
    stage: 4001
  ]

config :plug, validate_header_keys_during_test: false

config :cti_kaltura, :env, current: Mix.env()

config :logger,
  backends: [
    :console,
    {LoggerFileBackend, :request_log},
    {LoggerFileBackend, :program_scheduling_log},
    {LoggerFileBackend, :release_tasks_log},
    {LoggerFileBackend, :caching_system_log},
    {LoggerFileBackend, :sessions_log},
    {LoggerFileBackend, :database_log}
  ]

config :logger, :request_log,
  path: "log/request.log",
  metadata_filter: [domain: :request],
  level: :debug,
  format: "\n$date $time $metadata[$level] $message\n"

config :logger, :program_scheduling_log,
  path: "log/program_scheduling.log",
  metadata_filter: [domain: :program_scheduling],
  level: :debug,
  format: "\n$date $time $metadata[$level] $message\n"

config :logger, :release_tasks_log,
  path: "log/release_tasks.log",
  metadata_filter: [domain: :release_tasks],
  level: :debug,
  format: "\n$date $time $metadata[$level] $message\n"

config :logger, :caching_system_log,
  path: "log/caching_system.log",
  metadata_filter: [domain: :caching_system],
  level: :debug,
  format: "\n$date $time $metadata[$level] $message\n"

config :logger, :sessions_log,
  path: "log/sessions.log",
  metadata_filter: [domain: :sessions],
  level: :debug,
  format: "\n$date $time $metadata[$level] $message\n"

config :logger, :database_log,
  path: "log/database.log",
  metadata_filter: [domain: :database],
  level: :debug,
  format: "\n$date $time $metadata[$level] $message\n"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
