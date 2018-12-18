defmodule KalturaServer.Utils do
  @moduledoc false

  @kaltura_server_public_api Application.get_env(:kaltura_admin, :public_api)[:module]

  def refresh_linked_tables_if_necessary(table, joined_attributes_and_models, %{id: id} = attrs) do
    case table.read(id) do
      nil ->
        :ok

      record ->
        joined_attributes_and_models
        |> Enum.each(fn {attribute, model_name} ->
          current_value = Map.get(record, attribute)
          new_value = Map.get(attrs, attribute)

          case differences_between_arrays(current_value, new_value) do
            [] ->
              :ok

            ids ->
              ids
              |> Enum.each(fn id ->
                @kaltura_server_public_api.cache_model_record(model_name, id)
              end)
          end
        end)
    end
  end

  # TODO функция очень медленная в сущности делает следующее:
  # (arr1 -- arr2) ++ (arr2 -- arr1)
  # Но мы не можем положиться на строчку выше т.к. она иногда возвраащает некорректное значение.
  # Например:
  # iex> [4,5,6,7,8,9,10,11,12] -- [4,5,6,7] #=> '\b\t\n\v\f'
  # iex> [4,5,6,7,8] -- [4,5,6,7] #=> '\b\t\n\v\f'
  def differences_between_arrays(arr1, arr2) do
    set1 = MapSet.new(arr1)
    set2 = MapSet.new(arr2)
    difference1 = calculate_difference(set1, set2)
    difference2 = calculate_difference(set2, set1)
    difference1 ++ difference2
  end

  defp calculate_difference(set1, set2) do
    set1
    |> Enum.reduce([], fn elem, accumulator ->
      if MapSet.member?(set2, elem) do
        accumulator
      else
        accumulator ++ [elem]
      end
    end)
  end
end
