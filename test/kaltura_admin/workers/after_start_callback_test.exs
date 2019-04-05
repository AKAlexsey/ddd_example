defmodule CtiKaltura.Workers.AfterStartCallbackTest do
  use CtiKaltura.DataCase
  alias CtiKaltura.ReleaseTasks
  alias CtiKaltura.Workers.AfterStartCallback
  import Mock

  describe "#init" do
    test "Request models from CtiKaltura" do
      with_mock(
        ReleaseTasks,
        migrate_repo: fn -> :ok end,
        create_mnesia_schema: fn -> :ok end,
        cache_domain_model: fn -> :ok end
      ) do
        AfterStartCallback.start_link()
        :timer.sleep(100)

        assert_called(ReleaseTasks.migrate_repo())
        assert_called(ReleaseTasks.create_mnesia_schema())
        assert_called(ReleaseTasks.cache_domain_model())
      end
    end
  end
end
