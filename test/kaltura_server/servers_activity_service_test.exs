defmoёёdule CtiKaltura.ServersActivityServiceTest do
  use CtiKaltura.MnesiaTestCase
  use CtiKaltura.DataCase

  alias CtiKaltura.ServersActivityService, as: Service

  describe "ServersActivityService " do
    test "get_server_activity #1" do
      {:ok, server} =
        Factory.insert(:server, %{
          :domain_name => "127.0.0.1",
          :port => 80,
          :healthcheck_path => "/check"
        })

      res = Service.get_server_activity(server)

      case res do
        {:error, _} -> true
        {:ok, _} -> true
        _ -> flunk("Is not a valid result! #{res}")
      end
    end

    test "check_server_activity (server.availability=TRUE and server is AVAILABLE) #1" do
      {:ok, server} =
        Factory.insert(:server, %{
          :domain_name => "edge01.beetv.kz",
          :port => 80,
          :healthcheck_path => "/check",
          :availability => true
        })

      Service.check_server_activity(server)
    end

    test "check_server_activity (server.availability=FALSE and server is UNAVAILABLE) #2" do
      {:ok, server} =
        Factory.insert(:server, %{
          :domain_name => "127.127.127.127",
          :port => 80,
          :healthcheck_path => "/check",
          :availability => false
        })

      Service.check_server_activity(server)
    end
  end

  describe "ServersActivityService bug-fix : " do
    alias CtiKaltura.Servers
    alias CtiKaltura.ServersActivityService

    @group_attrs %{description: "some description", name: "some name", status: "ACTIVE"}

    @server_attrs %{
      domain_name: "some-domain3.name",
      healthcheck_enabled: true,
      healthcheck_path: "/some-healthcheck-path",
      ip: "123.123.123.125",
      manage_ip: "123.123.123.125",
      manage_port: 40,
      port: 80,
      prefix: "some-prefix-3",
      status: "ACTIVE",
      availability: true,
      type: "EDGE",
      weight: 50
    }

    test "update_servers_activity/0 for server with groups" do
      # create group
      {:ok, server_group} = @group_attrs |> Servers.create_server_group()
      # create server with group
      {:ok, server} =
        @server_attrs
        |> Enum.into(%{:server_group_ids => [server_group.id]})
        |> Servers.create_server()

      # check LOADED server HAS group
      loaded_server = Servers.get_server!(server.id, [:server_groups])
      assert length(loaded_server.server_groups) == 1

      # update servers activity
      ServersActivityService.update_servers_activity()

      # reload server
      loaded_server = Servers.get_server!(server.id, [:server_groups])
      assert length(loaded_server.server_groups) == 1
    end
  end
end
