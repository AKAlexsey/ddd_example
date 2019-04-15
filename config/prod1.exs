use Mix.Config

config :cti_kaltura, CtiKaltura.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  render_errors: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

config :libcluster,
       debug: true,
       topologies: [
         cti_kaltura: [
           # The selected clustering strategy. Required.
           strategy: Cluster.Strategy.Epmd,
           # Configuration for the provided strategy. Optional.
           config: [hosts: [:"first@10.15.2.20"]], # when second core will be initialized, add its ip :"second@<second_ip>"
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

config :cti_kaltura, CtiKaltura.Repo,
       adapter: Ecto.Adapters.Postgres,
       username: "cti",
       password: "cti",
       database: "cti_cdn",
       hostname: "10.15.7.46",
       pool_size: 80

if File.exists?("config/prod.secret.exs") do
  import_config("prod.secret.exs")
end
