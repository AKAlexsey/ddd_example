defmodule KalturaServer.TestCase do
  @moduledoc false

  defmacro __using__(opts) do
    async = Keyword.get(opts, :async, false)

    quote do
      use ExUnit.Case, async: unquote(async)

      alias KalturaServer.Factory
      alias KalturaServer.TestSupport

      require Amnesia
      require Amnesia.Helper

      Faker.start()

      setup do
        on_exit(fn -> TestSupport.flush_database_tables() end)
      end
    end
  end
end
