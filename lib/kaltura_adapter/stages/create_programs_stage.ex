defmodule CtiKaltura.ProgramScheduling.CreateProgramsStage do
  @moduledoc """
  Stage для формирования программы передач по данным из EPG файла.
  """

  use GenStage
  use CtiKaltura.KalturaLogger, metadata: [domain: :program_scheduling]

  alias CtiKaltura.ProgramScheduling.{ParseFileStage, ProgramScheduler}

  def start_link(_) do
    GenStage.start_link(__MODULE__, :ok, name: via_tuple(__MODULE__))
  end

  def init(state) do
    log_info("Starting")
    {:consumer, state, subscribe_to: [via_tuple(ParseFileStage)]}
  end

  defp via_tuple(name) do
    {:global, name}
  end

  def handle_events(program_schedule_data, _from, state) do
    log_info("Event received program_schedule_data_length #{length(program_schedule_data)}")

    for data <- program_schedule_data do
      case ProgramScheduler.perform(data) do
        :ok ->
          log_info(
            "Programs for #{inspect(data.linear_channel)} has been created. Programs count #{
              length(data.programs)
            }."
          )

        {:error, :linear_channel_does_not_exist} ->
          log_error("Linear channel does not exist #{inspect(data.linear_channel)}.")
      end
    end

    # Так как мы потребители, мы не создаем события
    {:noreply, [], state}
  end
end
