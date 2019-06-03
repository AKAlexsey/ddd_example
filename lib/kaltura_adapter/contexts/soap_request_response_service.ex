defmodule CtiKaltura.ProgramScheduling.SoapRequestResponseService do
  @moduledoc """
  Содержит функции для отправки запросов на DVR сервер.
  """

  @doc """
  Разбивает список результатов запросов на {успешные, ошибочные}
  """
  @spec split_result(list(tuple())) :: {list() | [], list() | []}
  def split_result(responses) do
    responses
    |> Enum.reduce({[], []}, fn
      {:ok, result}, {success, error} ->
        {success ++ [result], error}

      {:error, {response, params}}, {success, error} ->
        {success, error ++ [print_error(response, params)]}
    end)
  end

  defp print_error(response, params) do
    "Error occurred: #{inspect(response)} with params: #{inspect(params)}"
  end
end
