defmodule CtiKaltura.ProgramScheduling.CreateProgramsStage do
  @moduledoc """
  Stage для формирования программы передач по данным из EPG файла.
  """

  use GenStage

  alias CtiKaltura.ProgramScheduling.{ParseFileStage, ProgramScheduler}

  def start_link(_) do
    GenStage.start_link(__MODULE__, :ok, name: via_tuple(__MODULE__))
  end

  def init(state) do
    {:consumer, state, subscribe_to: [via_tuple(ParseFileStage)]}
  end

  defp via_tuple(name) do
    {:via, :global, name}
  end

  def handle_events(program_schedule_data, _from, state) do
    for data <- program_schedule_data do
      case ProgramScheduler.perform(data) do
        :ok ->
          "Successful branch log when logging system will be performed"

        {:error, :linear_channel_does_not_exist} ->
          "Fail branch. Log fail when logging system will be performed"
      end
    end

    # Так как мы потребители, мы не создаем события
    {:noreply, [], state}
  end
end
