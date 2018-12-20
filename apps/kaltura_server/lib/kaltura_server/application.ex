defmodule KalturaServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {
        KalturaServer.Workers.AfterStartCallback,
        {KalturaServer.Workers.AfterStartCallback, :start_link, []},
        :transient,
        5000,
        :worker,
        [KalturaServer.Workers.AfterStartCallback]
      },
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: KalturaServer.RequestProcessing.MainRouter,
        options: [port: 4001]
      )
    ]

    opts = [strategy: :one_for_one, name: KalturaServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
