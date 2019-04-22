use Mix.Config

config :libcluster,
  debug: true,
  topologies: [
    cti_kaltura: [
      # The selected clustering strategy. Required.
      strategy: Cluster.Strategy.Epmd,
      # Configuration for the provided strategy. Optional.
      config: [hosts: [:"first@172.16.2.143", :"second@172.16.2.6"]],
      # The function to use for connecting nodes. The node
      # name will be appended to the argument list. Optional
      connect: {:net_kernel, :connect, []},
      # The function to use for disconnecting nodes. The node
      # name will be appended to the argument list. Optional
      disconnect: {:net_kernel, :disconnect, []},
      # The function to use for listing nodes.
      # This function must return a list of node names. Optional
      list_nodes: {:erlang, :nodes, [:connected]},
      # A list of options for the supervisor child spec
      # of the selected strategy. Optional
      child_spec: [restart: :transient]
    ]
  ]

config :cti_kaltura, :epg_file_parser,
  # Опция включения или выключения стейджа, осуществляющего парсинг EPG XML файлов.
  enabled: true,
  # Интервал проверки папки с EPG файлами
  scan_file_directory_interval: 5000,
  # Интервал обаботки файлов
  process_file_interval: 500,
  # Путь до папки где должны лежать валидные XML файлы
  files_directory: "/home/app/cti_kaltura/ftp_files",
  # Путь до папки куда будут складываться отработанные файлы
  processed_files_directory: "/home/app/cti_kaltura/ftp_files/processed"

if File.exists?("config/stage.secret.exs") do
  import_config("stage.secret.exs")
end
