defmodule CtiKaltura do
  @moduledoc false

  use Application

  alias CtiKaltura.Endpoint
  alias CtiKaltura.RequestProcessing.MainRouter
  alias CtiKaltura.Workers.AfterStartCallback
  alias Plug.Cowboy

  def start(_type, _args) do
    children = [
      CtiKaltura.Repo,
      CtiKaltura.Endpoint,
      Cowboy.child_spec(
        scheme: :http,
        plug: MainRouter,
        options: [port: http_main_router_port()]
      ),
      {
        AfterStartCallback,
        {AfterStartCallback, :start_link, []},
        :transient,
        5000,
        :worker,
        [AfterStartCallback]
      }
    ]

    opts = [strategy: :one_for_one, name: CtiKaltura.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp router_config, do: Application.get_env(:cti_kaltura, MainRouter)

  defp http_main_router_port do
    router_config()[:http_port]
    |> Keyword.get(mix_env(), 4001)
  end

  defp mix_env do
    Application.get_env(:cti_kaltura, :env)[:current]
  end

  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
