defmodule KalturaServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias KalturaServer.RequestProcessing.MainRouter
  alias KalturaServer.Workers.AfterStartCallback
  alias Plug.Cowboy

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {
        AfterStartCallback,
        {AfterStartCallback, :start_link, []},
        :transient,
        5000,
        :worker,
        [AfterStartCallback]
      },
      Cowboy.child_spec(
        scheme: :http,
        plug: MainRouter,
        options: [port: main_router_port()]
      )
    ]

    opts = [strategy: :one_for_one, name: KalturaServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp main_router_port do
    Application.get_env(:kaltura_server, MainRouter)[:port]
    |> Keyword.get(Mix.env(), 4001)
  end
end
