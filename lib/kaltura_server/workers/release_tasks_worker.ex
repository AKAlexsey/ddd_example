defmodule CtiKaltura.Workers.ReleaseTasksWorker do
  @moduledoc """
  Run functions after starting and stop
  """

  use GenServer

  alias CtiKaltura.ReleaseTasks

  @await_timeout Application.get_env(:cti_kaltura, :after_start_callback_timeout)

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(__MODULE__))
  end

  def make_mnesia_cluster_again do
    GenServer.cast(via_tuple(__MODULE__), :make_mnesia_cluster_again)
  end

  def reset_single_mnesia do
    GenServer.cast(via_tuple(__MODULE__), :reset_single_mnesia)
  end

  def init(_opts) do
    Process.send_after(self(), :after_start_callback, @await_timeout)
    {:ok, %{}}
  end

  def handle_info(:after_start_callback, state) do
    ReleaseTasks.cache_domain_model()
    ReleaseTasks.migrate_repo()
    {:noreply, state}
  end

  def handle_cast(:make_mnesia_cluster_again, state) do
    ReleaseTasks.make_mnesia_cluster_again()
    {:noreply, state}
  end

  def handle_cast(:reset_single_mnesia, state) do
    ReleaseTasks.reset_single_mnesia()
    {:noreply, state}
  end

  defp via_tuple(name), do: {:via, :global, name}
end
