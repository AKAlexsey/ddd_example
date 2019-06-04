defmodule CtiKaltura.Util.ServerUtilTest do
  use CtiKaltura.MnesiaTestCase
  use CtiKaltura.DataCase

  alias CtiKaltura.Util.ServerUtil

  describe "ServerUtil " do
    test "normalize_path #1" do
      path = "/some/normal/url"
      assert ServerUtil.normalize_path(path) == "/some/normal/url"
    end

    test "normalize_path #2" do
      path = "///some/normal/url"
      assert ServerUtil.normalize_path(path) == "/some/normal/url"
    end

    test "normalize_path #3" do
      path = "some/normal/url"
      assert ServerUtil.normalize_path(path) == "/some/normal/url"
    end

    test "prepare_url #1" do
      url = ServerUtil.prepare_url("host.com", 80, "some/path")
      assert url == "http://host.com/some/path"
    end

    test "prepare_url #2" do
      url = ServerUtil.prepare_url("host.com", 443, "///some/path")
      assert url == "https://host.com/some/path"
    end

    test "prepare_url #3" do
      url = ServerUtil.prepare_url("host.com", 444, "/some/path")
      assert url == "http://host.com:444/some/path"
    end

    test "prepare_url_for_healthcheck #1" do
      {:ok, server} =
        Factory.insert(:server, %{
          :domain_name => "host.com",
          :port => 80,
          :healthcheck_path => "/some/path"
        })

      url = ServerUtil.prepare_url_for_healthcheck(server)
      assert url == "http://host.com/some/path"
    end

    test "prepare_url_for_healthcheck #2" do
      {:ok, server} =
        Factory.insert(:server, %{
          :domain_name => "host.com",
          :port => 443,
          :healthcheck_path => "/some/path"
        })

      url = ServerUtil.prepare_url_for_healthcheck(server)
      assert url == "https://host.com/some/path"
    end

    test "prepare_url_for_stream #1" do
      {:ok, server} = Factory.insert(:server, %{:domain_name => "host.com", :port => 80})
      url = ServerUtil.prepare_url_for_stream(server, "/stream/path")
      assert url == "http://host.com/stream/path"
    end

    test "prepare_url_for_stream #2" do
      {:ok, server} = Factory.insert(:server, %{:domain_name => "host.com", :port => 443})
      url = ServerUtil.prepare_url_for_stream(server, "/stream/path")
      assert url == "https://host.com/stream/path"
    end
  end
end
