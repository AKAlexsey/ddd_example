defmodule CtiKaltura.ClosestEdgeServerServiceTest do
  use CtiKaltura.MnesiaTestCase

  alias CtiKaltura.ClosestEdgeServerService

  setup do
    %{id: linear_channel_id} = Factory.insert(:linear_channel)
    {:ok, linear_channel_id: linear_channel_id}
  end

  describe "#perform if LinearChannel is not given fails scenarios" do
    test "Return nil if no Subnets for given IP" do
      assert is_nil(ClosestEdgeServerService.perform({123, 123, 123, 123}))
    end

    test "Return nil if Region does not have Servers" do
      subnet_id = 777
      region_id = 777
      server_group_id = 777
      Factory.insert(:subnet, %{id: subnet_id, cidr: "123.123.123.123/29", region_id: region_id})

      Factory.insert(:region, %{
        id: region_id,
        subnet_ids: [subnet_id],
        server_group_id: [server_group_id]
      })

      Factory.insert(:server_group, %{id: server_group_id, region_ids: [region_id]})

      assert is_nil(ClosestEdgeServerService.perform({123, 123, 123, 123}))
    end
  end

  describe "#perform if LinearChannel is not given success scenarios" do
    setup do
      subnet_id = 777
      region_id = 777
      server_group_id = 777
      s_id1 = 777
      s_id2 = 778
      s_id3 = 779
      s_id4 = 780
      s_id5 = 781

      Factory.insert(:subnet, %{
        id: subnet_id,
        cidr: "123.123.123.123/29",
        region_id: region_id,
        server_ids: [s_id1, s_id2, s_id3, s_id4, s_id5]
      })

      Factory.insert(:region, %{
        id: region_id,
        subnet_ids: [subnet_id],
        server_group_ids: [server_group_id]
      })

      Factory.insert(:server, %{
        id: s_id1,
        server_group_ids: [server_group_id],
        status: "INACTIVE",
        type: "EDGE",
        healthcheck_enabled: true
      })

      Factory.insert(:server, %{
        id: s_id2,
        server_group_ids: [server_group_id],
        status: "ACTIVE",
        type: "EDGE",
        healthcheck_enabled: true
      })

      Factory.insert(:server, %{
        id: s_id3,
        server_group_ids: [server_group_id],
        status: "ACTIVE",
        type: "EDGE",
        healthcheck_enabled: false
      })

      Factory.insert(:server, %{
        id: s_id4,
        server_group_ids: [server_group_id],
        status: "ACTIVE",
        type: "EDGE",
        healthcheck_enabled: true,
        weight: 10
      })

      Factory.insert(:server, %{
        id: s_id5,
        server_group_ids: [server_group_id],
        status: "ACTIVE",
        type: "EDGE",
        healthcheck_enabled: true,
        weight: 20
      })

      {:ok,
       server_group_id: server_group_id,
       server_ids: [s_id1, s_id2, s_id3, s_id4, s_id5],
       region_id: region_id}
    end

    test "Return Server if they exist", %{
      server_group_id: server_group_id,
      linear_channel_id: linear_channel_id,
      server_ids: server_ids,
      region_id: region_id
    } do
      Factory.insert(:server_group, %{
        id: server_group_id,
        region_ids: [region_id],
        server_ids: server_ids,
        linear_channel_ids: [linear_channel_id]
      })

      assert ClosestEdgeServerService.perform({123, 123, 123, 123}).id in server_ids
    end
  end

  describe "#sum_weights" do
    test "Return 0 if no servers given" do
      assert 0 == ClosestEdgeServerService.sum_weights([])
    end

    test "Return sum of server weights #1" do
      server1 = Factory.insert(:server, %{weight: 20})
      assert 20 == ClosestEdgeServerService.sum_weights([server1])
    end

    test "Return sum of server weights #2" do
      server1 = Factory.insert(:server, %{weight: 30})
      server2 = Factory.insert(:server, %{weight: 15})
      assert 45 == ClosestEdgeServerService.sum_weights([server1, server2])
    end

    test "Return sum of server weights #3" do
      server1 = Factory.insert(:server, %{weight: 30})
      server2 = Factory.insert(:server, %{weight: 9})
      server3 = Factory.insert(:server, %{weight: 7})
      assert 46 == ClosestEdgeServerService.sum_weights([server1, server2, server3])
    end
  end

  describe "#choose_server" do
    test "Return empty map if no servers given" do
      assert %{} == ClosestEdgeServerService.choose_server([], 20)
    end

    test "Return empty map if random number is less than zero" do
      server = Factory.insert(:server, %{weight: 10})
      assert %{} == ClosestEdgeServerService.choose_server([server], -1)
    end

    test "Return empty map if random number is zero" do
      server = Factory.insert(:server, %{weight: 10})
      assert %{} == ClosestEdgeServerService.choose_server([server], 0)
    end

    test "Return server with appropriate weight" do
      server1 = Factory.insert(:server, %{weight: 10})
      server2 = Factory.insert(:server, %{weight: 20})
      server3 = Factory.insert(:server, %{weight: 30})
      servers_list = [server1, server2, server3]
      assert server1 == ClosestEdgeServerService.choose_server(servers_list, 1)
      assert server1 == ClosestEdgeServerService.choose_server(servers_list, 10)
      assert server2 == ClosestEdgeServerService.choose_server(servers_list, 11)
      assert server2 == ClosestEdgeServerService.choose_server(servers_list, 15)
      assert server2 == ClosestEdgeServerService.choose_server(servers_list, 30)
      assert server3 == ClosestEdgeServerService.choose_server(servers_list, 31)
      assert server3 == ClosestEdgeServerService.choose_server(servers_list, 55)
      assert server3 == ClosestEdgeServerService.choose_server(servers_list, 60)
    end
  end
end
