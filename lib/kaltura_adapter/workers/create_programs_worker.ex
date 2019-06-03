defmodule CtiKaltura.ProgramScheduling.CreateProgramsWorker do
  @moduledoc """
  Stage для формирования программы передач по данным из EPG файла.
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

    case ProgramScheduler.perform(program_schedule_data) do
      :ok ->
        log_info(
          "Programs for #{inspect(program_schedule_data.linear_channel)} has been created. Programs count #{
            length(program_schedule_data.programs)
          }."
        )

      {:error, :linear_channel_does_not_exist} ->
        log_error(
          "Linear channel does not exist #{inspect(program_schedule_data.linear_channel)}."
        )
    end

    {:noreply, state}
  end
end
