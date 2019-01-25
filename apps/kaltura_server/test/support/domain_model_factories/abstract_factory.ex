defmodule KalturaServer.DomainModelFactories.AbstractFactory do
  @moduledoc """
  Contains common inclusions for factories.
  And method for getting last table id
  """

  defmacro __using__(opts) do
    table = Keyword.get(opts, :table)

    quote do
      require Amnesia
      require Amnesia.Helper

      alias KalturaServer.Factory

      @table unquote(table)

      @doc "Function for getting next table record id. For creation record in database."
      @spec next_table_id :: integer
      def next_table_id do
        case :mnesia.dirty_last(@table) do
          id when is_integer(id) -> id + 1
          _ -> 1
        end
      end
    end
  end
end
