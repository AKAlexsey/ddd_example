defmodule KalturaServer.Workers.AfterStartCallback do
  @moduledoc """
  Run functions after starting and stop
  """

  use GenServer

  @kaltura_admin_public_api Application.get_env(:kaltura_admin, :public_api)[:module]

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    send(self(), :after_start_callback)
    {:ok, %{}}
  end

  def handle_info(:after_start_callback, state) do
    cache_domain_model()
    {:stop, :normal, state}
  end

  def cache_domain_model do
    @kaltura_admin_public_api.cache_domain_model_at_server()
  end
end
