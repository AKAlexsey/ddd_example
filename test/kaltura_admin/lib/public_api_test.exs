defmodule CtiKaltura.PublicApiTest do
  use ExUnit.Case
  alias CtiKaltura.PublicApi
  alias CtiKaltura.Services.DomainModelCache
  import Mock

  test "#get_all_records" do
    with_mock(DomainModelCache, get_all_records: fn -> :ok end) do
      PublicApi.cache_domain_model_at_server()
      :timer.sleep(50)
      assert_called(DomainModelCache.get_all_records())
    end
  end

  test "#get_one_record" do
    model = "Program"
    id = 1

    with_mock(DomainModelCache, get_one_record: fn _, _ -> :ok end) do
      PublicApi.cache_model_record(model, id)
      :timer.sleep(50)
      assert_called(DomainModelCache.get_one_record(model, id))
    end
  end
end
