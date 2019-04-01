defmodule CtiKaltura.Util do
  @moduledoc """
  A module providing some common methods for all controllers
  """

  def date_to_string(dt) do
    day = String.pad_leading(to_string(dt.day), 2, "0")
    month = String.pad_leading(to_string(dt.month), 2, "0")
    "#{day}.#{month}.#{dt.year}"
  end

  def time_to_string(dt) do
    hour = String.pad_leading(to_string(dt.hour), 2, "0")
    minute = String.pad_leading(to_string(dt.minute), 2, "0")
    "#{hour}:#{minute}"
  end
end
