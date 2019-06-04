defmodule CtiKaltura.Executors.ServersActivityCheckExecutor do
  @moduledoc """
  Executor for periodical running of the servers activity checking.
  Period is parameter 'servers_activity_checking_timeout' from config.exs
  """

  use GenServer
  use CtiKaltura.KalturaLogger, metadata: [domain: :servers_activity]

  alias CtiKaltura.ServersActivityService, as: Service

  @interval_timeout Application.get_env(:cti_kaltura, :servers_activity_checking_timeout)

  # CLIENT implementation =========================================================================

  def start_link(_) do
    log_info("Starting ...")
    GenServer.start_link(__MODULE__, [], name: {:global, __MODULE__})
  end

  # SERVER implementation =========================================================================

  def init(_opts) do
    log_info("Started successfully! Scheduled period: #{@interval_timeout} ms")
    do_schedule()
    {:ok, %{}}
  end

  def handle_info(:run_job, state) do
    Service.update_servers_activity()
    do_schedule()
    {:noreply, state}
  end

  def do_schedule do
    Process.send_after(self(), :run_job, @interval_timeout)
  end
end
