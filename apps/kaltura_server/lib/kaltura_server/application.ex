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
        options: [port: http_main_router_port()]
      ),
      Cowboy.child_spec(
        scheme: :https,
        plug: MainRouter,
        options: [
          port: https_main_router_port(),
          keyfile: https_keyfile(),
          certfile: https_certfile(),
          otp_app: :kaltura_server
        ]
      )
    ]

    opts = [strategy: :one_for_one, name: KalturaServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp router_config, do: Application.get_env(:kaltura_server, MainRouter)

  defp http_main_router_port do
    router_config()[:http_port]
    |> Keyword.get(Mix.env(), 4001)
  end

  defp https_main_router_port do
    router_config()[:https_port]
    |> Keyword.get(Mix.env(), 4040)
  end

  defp https_keyfile do
    router_config()[:https_keyfile]
  end

  defp https_certfile do
    router_config()[:https_certfile]
  end
end
