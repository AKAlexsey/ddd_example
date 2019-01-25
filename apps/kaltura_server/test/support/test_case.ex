defmodule KalturaServer.TestCase do
  @moduledoc false

  defmacro __using__(opts) do
    async = Keyword.get(opts, :async, true)

    quote do
      use ExUnit.Case, async: unquote(async)

      alias KalturaServer.Factory

      require Amnesia
      require Amnesia.Helper

      Faker.start()
    end
  end
end
