defmodule KalturaAdmin.PublicApiTest do
  use ExUnit.Case
  alias KalturaAdmin.PublicApi
  alias KalturaAdmin.Services.DomainModelCache
  import Mock

  test "#get_all_records" do
    with_mock(DomainModelCache, get_all_records: fn -> :ok end) do
      PublicApi.cache_domain_model_at_server()
      :timer.sleep(50)
      assert_called(DomainModelCache.get_all_records())
    end
  end
end
