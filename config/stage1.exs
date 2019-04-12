use Mix.Config

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

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

if File.exists?("config/stage.secret.exs") do
  import_config("stage.secret.exs")
end
