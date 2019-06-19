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

config :cti_kaltura, :pagination, default_per_page: 100

# Таймаут запуска колбеков (миллисекунды)
config :cti_kaltura, after_start_callback_timeout: 3000
config :cti_kaltura, servers_activity_checking_timeout: 10_000

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
    {LoggerFileBackend, :caching_system_log},
    {LoggerFileBackend, :database_log},
    {LoggerFileBackend, :epg_files_log},
    {LoggerFileBackend, :program_scheduling_log},
    {LoggerFileBackend, :release_tasks_log},
    {LoggerFileBackend, :request_log},
    {LoggerFileBackend, :servers_activity_log},
    {LoggerFileBackend, :sessions_log}
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

config :logger, :servers_activity_log,
  path: "log/servers_activity.log",
  metadata_filter: [domain: :servers_activity],
  level: :debug,
  format: "\n$date $time [$level] - $message"

config :logger, :epg_files_log,
  path: "log/epg_files.log",
  metadata_filter: [domain: :epg_files],
  level: :debug,
  format: "\n$date $time [$level] - $message"

config :soap, :globals, version: "1.1"

config :cti_kaltura, :program_records_scheduler,
  # Включение и отключение планирование статуса записей
  enabled: true,
  # Интервал с которым будет производиться планирование записей (миллисекунды)
  run_interval: 15_000,
  # Время, через которое должны начинаться программы, для которых будет осуществляться планирование записей(секунды)
  seconds_after: 1200

config :cti_kaltura, :program_records_status,
  # актуализации статуса записей
  enabled: true,
  # Интервал с которым будет производиться проверка состояния записей (миллисекунды)
  run_interval: 15_000

config :cti_kaltura, :program_records_cleaner,
  # Включение и отключение функции очистки устареших записей программ из БД и с DVR сервера
  enabled: true,
  # Интервал с которым будет осуществляться очистка устаревших записей и программ (миллисекунды)
  run_interval: 30_000,
  # Время хранения записей программы (часы)
  storing_hours: 48

config :cti_kaltura, :programs_cleaner,
  # Включение и отключение функции очистки устареших программ из БД и с DVR сервера
  enabled: true,
  # Интервал с которым будет осуществляться очистка устаревших записей и программ (миллисекунды)
  run_interval: 30_000,
  # Время хранения программы (часы)
  storing_hours: 48

config :cti_kaltura, :dvr_soap_requests,
  # Включение и отключение отправки SOAP запросов на DVR
  enabled: true,
  # Интервал с которым будет происходить запрос WSDL (миллисекунды)
  run_interval: 5000,
  # Путь до WSDL XML файла
  wsdl_file_path: "#{File.cwd!()}/priv/program_scheduling/wsdl.xml",
  # SOAP пользователь для Basic ваторизации
  soap_user: "usercti",
  # SOAP пользователь для Basic ваторизации
  soap_password: "passcti"

# https://stackoverflow.com/questions/29889881/an-example-ftp-session-using-elixir Answer for downloading
config :cti_kaltura, :epg_files_downloading,
  # Включение и отключение функции автоматического скачивания EPG файлов
  enabled: false,
  # Интервал с которым будет происходить проверка FTP папки
  run_interval: 30_000,
  # Количество файлов, скачиваемых за одну итерацию
  batch_size: 10,
  # Хост FTP. Должен быть именно в одинарных кавычках.
  ftp_host: 'ftp.epgservice.ru',
  # Папка, в которой лежат файлы на FTP серере. Должен быть именно в одинарных кавычках.
  ftp_folder: '4cti',
  # Пользователь для доступа по FTP. Должен быть именно в одинарных кавычках.
  ftp_user: 'beelinetvkz',
  # Пароль для доступа по FTP. Должен быть именно в одинарных кавычках.
  ftp_password: 'lQklCn8T',
  # Настройка сделана для удобства. Чтобы можно было отлаживать программу
  # и при этом не трогать файлы на FTP сервере.
  delete_downloaded_files: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
