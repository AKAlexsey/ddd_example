defmodule KalturaServer.Workers.AfterStartCallbackTest do
  use ExUnit.Case
  alias KalturaServer.Workers.AfterStartCallback
  import Mock

  @kaltura_admin_public_api Application.get_env(:kaltura_admin, :public_api)[:module]

  describe "#init" do
    test "Request models from KalturaAdmin" do
      with_mock(@kaltura_admin_public_api, cache_domain_model_at_server: fn -> :ok end) do
        AfterStartCallback.start_link()
        :timer.sleep(50)
        assert_called(@kaltura_admin_public_api.cache_domain_model_at_server())
      end
    end
  end
end
