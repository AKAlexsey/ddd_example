defmodule CtiKaltura.Workers.AfterStartCallback do
  @moduledoc """
  Run functions after starting and stop
  """

  use GenServer

  import CtiKaltura.ReleaseTasks,
    only: [migrate_repo: 0, create_mnesia_schema: 0, cache_domain_model: 0]

  @await_timeout Application.get_env(:cti_kaltura, :after_start_callback_timeout)

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    Process.send_after(self(), :after_start_callback, @await_timeout)
    {:ok, %{}}
  end

  def handle_info(:after_start_callback, state) do
    migrate_repo()
    create_mnesia_schema()
    cache_domain_model()
    {:stop, :normal, state}
  end
end
