defmodule CtiKaltura.ProgramScheduling.CreateProgramsWorker do
  @moduledoc """
  Worker для формирования программы передач по данным из EPG файла.
  """

  use GenServer
  use CtiKaltura.KalturaLogger, metadata: [domain: :program_scheduling]

  alias CtiKaltura.ProgramScheduling.ProgramScheduler

  def send_program_schedule_data(program_schedule_data) do
    GenServer.cast(via_tuple(__MODULE__), {:schedule_programs, program_schedule_data})
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: via_tuple(__MODULE__))
  end

  def init(_) do
    log_info("Starting")
    {:ok, nil}
  end

  defp via_tuple(name) do
    {:global, name}
  end

  def handle_cast({:schedule_programs, program_schedule_data}, state) do
    log_info("Event received schedule_programs")

    case ProgramScheduler.perform(program_schedule_data, threshold_seconds()) do
      {:ok, %{linear_channel: linear_channel, programs: created_programs}} ->
        log_info(
          "Programs for #{linear_channel} has been created. Programs count #{
            length(created_programs)
          }."
        )

      {:error, :linear_channel_does_not_exist} ->
        log_error(
          "Linear channel does not exist #{inspect(program_schedule_data.linear_channel)}."
        )

      {:error, :linear_channel_dvr_does_not_enabled} ->
        log_error(
          "Linear channel dvr does not enabled #{inspect(program_schedule_data.linear_channel)}."
        )
    end

    {:noreply, state}
  end

  def threshold_seconds do
    Application.get_env(:cti_kaltura, :program_scheudling)[:threshold_seconds]
  end

  def terminate(reason, state) do
    log_error("Terminating server with reason: #{inspect(reason)}\nState: #{inspect(state)}")
  end
end
