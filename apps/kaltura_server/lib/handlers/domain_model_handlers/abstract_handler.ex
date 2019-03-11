defmodule KalturaServer.DomainModelHandlers.AbstractHandler do
  @moduledoc """
  Содержит общую для вех хендлеров логику. Определяет общие для всех случаев функции handle.
  """

  defmacro __using__(opts) do
    table = Keyword.get(opts, :table)

    quote do
      require Amnesia
      require Amnesia.Helper

      @table unquote(table)
      @kaltura_server_public_api Application.get_env(:kaltura_admin, :public_api)[:module]

      def handle(action, attrs) when action in [:insert, :update] do
        Amnesia.transaction do
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

      defoverridable before_write: 2
    end
  end
end
