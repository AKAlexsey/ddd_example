use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cti_kaltura, CtiKaltura.Endpoint,
  http: [port: 4002],
  server: false

# Timeout in milliseconds
config :cti_kaltura, after_start_callback_timeout: 50

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :cti_kaltura, CtiKaltura.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "cti_kaltura_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :cti_kaltura, :epg_file_parser,
  # Опция включения или выключения GenServer, осуществляющего парсинг EPG XML файлов.
  enabled: false,
  # Интервал проверки папки с EPG файлами (миллисекунды)
  run_interval: 500,
  # Путь до папки где должны лежать валидные XML файлы
  files_directory: "#{File.cwd!()}/test/kaltura_adapter/fixtures/not_processed",
  # Путь до папки куда будут складываться отработанные файлы
  processed_files_directory: "#{File.cwd!()}/test/kaltura_adapter/fixtures"

config :logger, backends: []

config :cti_kaltura, :program_records_scheduler, enabled: false

config :cti_kaltura, :program_records_status, enabled: false

config :cti_kaltura, :program_records_cleaner, enabled: false

config :cti_kaltura, :programs_cleaner, enabled: false

config :cti_kaltura, :dvr_soap_requests, enabled: false
