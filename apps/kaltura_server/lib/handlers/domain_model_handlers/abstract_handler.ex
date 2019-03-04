defmodule KalturaServer.DomainModelHandlers.AbstractHandler do
  @moduledoc """
  Содержит общую для вех хендлеров логику. Определяет общие для всех случаев функции handle.
  """

  defmacro __using__(opts) do
    table = Keyword.get(opts, :table)
    joined_attributes_and_models = Keyword.get(opts, :joined_attributes_and_models, [])

    quote do
      require Amnesia
      require Amnesia.Helper

      @table unquote(table)
      @joined_attributes_and_models unquote(joined_attributes_and_models)
      @kaltura_server_public_api Application.get_env(:kaltura_admin, :public_api)[:module]

      def handle(action, attrs) when action in [:insert, :update] do
        Amnesia.transaction do
          refresh_linked_tables_if_necessary(attrs)
          write_to_table(attrs)
        end

        :ok
      end

      def handle(:refresh_by_request, attrs) do
        Amnesia.transaction do
          write_to_table(attrs)
        end

        :ok
      end

      def handle(:delete, %{id: id} = attrs) do
        Amnesia.transaction do
          delete_from_table(id)
          refresh_linked_tables_if_necessary(attrs)
        end

        :ok
      end

      defp write_to_table(attrs) do
        @table.__struct__
        |> struct(attrs)
        |> before_write(attrs)
        |> @table.write()
      end

      @doc """
      This functions calls right before writing to the mnesia table.
      Argument is table structure based on passed attributes.

      Could be used for preprocessing data before writing. For example:
      * Adding calculated attributes;
      * Preprocessing the attributes before writing;
      * Some other manipulations with attributes.
      """
      @spec before_write(map(), map()) :: map()
      def before_write(struct, _raw_attrs) do
        struct
      end

      defp delete_from_table(id) do
        @table.delete(id)
      end

      defp refresh_linked_tables_if_necessary(%{id: id} = attrs) do
        id
        |> @table.read()
        |> check_record_attributes(attrs)
      end

      defp check_record_attributes(nil, attrs) do
        iterate_through_record_attributes(fn {attribute, attribute_config} ->
          {model_name, _notify_always} = get_attribute_config(attribute_config)

          case Map.get(attrs, attribute) do
            array_ids when is_list(array_ids) ->
              Enum.each(array_ids, &notify(model_name, &1))

            id ->
              notify(model_name, id)
          end
        end)
      end

      defp check_record_attributes(record, attrs) do
        iterate_through_record_attributes(fn {attribute, attribute_config} ->
          {model_name, notify_always} = get_attribute_config(attribute_config)
          current_value = Map.get(record, attribute)
          new_value = Map.get(attrs, attribute)

          compare_values_and_refresh(current_value, new_value, model_name, notify_always)
        end)
      end

      defp get_attribute_config(attribute_config) when is_binary(attribute_config) do
        {attribute_config, false}
      end

      defp get_attribute_config([model_name | opts]) do
        {model_name, Keyword.get(opts, :notify_always, false)}
      end

      defp iterate_through_record_attributes(callback) do
        @joined_attributes_and_models
        |> Enum.each(&callback.(&1))
      end

      defp compare_values_and_refresh(current_value, new_value, model_name, notify_always)
           when is_list(current_value) and is_list(new_value) do
        set1 = MapSet.new(current_value)
        set2 = MapSet.new(new_value)

        if notify_always do
          set1
          |> MapSet.union(set2)
          |> Enum.each(&notify(model_name, &1))
        else
          refresh_joined_models(set1, set2, model_name)
          refresh_joined_models(set2, set1, model_name)
        end
      end

      defp compare_values_and_refresh(current_value, new_value, model_name, notify_always) do
        if notify_always || current_value != new_value do
          notify(model_name, current_value)
          notify(model_name, new_value)
        end
      end

      defp refresh_joined_models(set1, set2, model_name) do
        set1
        |> Enum.each(fn id ->
          if !MapSet.member?(set2, id) do
            notify(model_name, id)
          end
        end)
      end

      defp notify(_model_name, nil), do: :ok

      defp notify(model_name, id),
        do: @kaltura_server_public_api.cache_model_record(model_name, id)

      defoverridable before_write: 2
    end
  end
end
