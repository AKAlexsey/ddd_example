defmodule CtiKaltura.MnesiaTestCase do
  @moduledoc false

  defmacro __using__(opts) do
    async = Keyword.get(opts, :async, false)

    quote do
      use ExUnit.Case, async: unquote(async)

      alias CtiKaltura.MnesiaFactory, as: Factory
      alias CtiKaltura.MnesiaTestSupport

      require Amnesia
      require Amnesia.Helper

      Faker.start()

      setup do
        on_exit(fn -> MnesiaTestSupport.flush_database_tables() end)
      end
    end
  end
end
