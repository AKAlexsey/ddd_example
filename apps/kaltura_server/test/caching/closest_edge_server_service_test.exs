defmodule KalturaServer.ClosestEdgeServerServiceTest do
  use KalturaServer.TestCase, async: false

  alias KalturaServer.ClosestEdgeServerService

  setup do
    %{id: tv_stream_id} = Factory.insert(:tv_stream)
    {:ok, tv_stream_id: tv_stream_id}
  end

  describe "#perform if TvStream is not given fails scenarios" do
    test "Return nil if no Subnets for given IP" do
      assert is_nil(ClosestEdgeServerService.perform("149.149.149.149"))
    end

    test "Return nil if Subnet does not have Region" do
      Factory.insert(:subnet, %{cidr: "199.199.199.199"})

      assert is_nil(ClosestEdgeServerService.perform("199.199.199.199"))
    end

    test "Return nil if Region does not have ServerGroups" do
      subnet_id = 1343
      region_id = 1343
      Factory.insert(:region, %{id: region_id, subnet_ids: [subnet_id]})
      Factory.insert(:subnet, %{id: subnet_id, cidr: "198.198.198.198/29", region_id: region_id})

      assert is_nil(ClosestEdgeServerService.perform("198.198.198.198"))
    end

    test "Return nil if Region does not have Servers" do
      subnet_id = 1343
      region_id = 1343
      server_group_id = 1343
      Factory.insert(:subnet, %{id: subnet_id, cidr: "197.197.197.197/29", region_id: region_id})

      Factory.insert(:region, %{
        id: region_id,
        subnet_ids: [subnet_id],
        server_group_id: [server_group_id]
      })

      Factory.insert(:server_group, %{id: server_group_id, region_ids: [region_id]})

      assert is_nil(ClosestEdgeServerService.perform("197.197.197.197"))
    end
  end

  describe "#perform if TvStream is not given success scenarios" do
    setup do
      subnet_id = 1343
      region_id = 1343
      server_group_id = 1343

      Factory.insert(:subnet, %{id: subnet_id, cidr: "197.197.197.197/29", region_id: region_id})

      Factory.insert(:region, %{
        id: region_id,
        subnet_ids: [subnet_id],
        server_group_ids: [server_group_id]
      })

      %{id: s_id1} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :inactive,
          type: :edge,
          healthcheck_enabled: true
        })

      %{id: s_id2} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :dvr,
          healthcheck_enabled: true
        })

      %{id: s_id3} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :edge,
          healthcheck_enabled: false
        })

      %{id: s_id4} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          weight: 10
        })

      %{id: s_id5} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :edge,
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
      tv_stream_id: tv_stream_id,
      server_ids: server_ids,
      region_id: region_id
    } do
      Factory.insert(:server_group, %{
        id: server_group_id,
        region_ids: [region_id],
        server_ids: server_ids,
        tv_stream_ids: [tv_stream_id]
      })

      assert ClosestEdgeServerService.perform("197.197.197.197").id in server_ids

      delete_servers(server_ids)
    end
  end

  describe "#perform if TvStream given fails scenarios" do
    test "Return nil if no Subnets for given IP", %{tv_stream_id: tv_stream_id} do
      assert is_nil(
               ClosestEdgeServerService.perform("196.196.196.196", tv_stream_id: tv_stream_id)
             )
    end

    test "Return nil if Subnet does not have Region", %{tv_stream_id: tv_stream_id} do
      Factory.insert(:subnet, %{cidr: "196.196.196.196/29"})

      assert is_nil(
               ClosestEdgeServerService.perform("196.196.196.196", tv_stream_id: tv_stream_id)
             )
    end

    test "Return nil if Region does not have ServerGroups", %{tv_stream_id: tv_stream_id} do
      subnet_id = 1342
      region_id = 1342
      Factory.insert(:region, %{id: region_id, subnet_ids: [subnet_id]})
      Factory.insert(:subnet, %{id: subnet_id, cidr: "196.196.196.196/29", region_id: region_id})

      assert is_nil(
               ClosestEdgeServerService.perform("196.196.196.196", tv_stream_id: tv_stream_id)
             )
    end

    test "Return nil if Region does not have Servers", %{tv_stream_id: tv_stream_id} do
      subnet_id = 1342
      region_id = 1342
      server_group_id = 1342
      Factory.insert(:subnet, %{id: subnet_id, cidr: "196.196.196.196/29", region_id: region_id})

      Factory.insert(:region, %{
        id: region_id,
        subnet_ids: [subnet_id],
        server_group_id: [server_group_id]
      })

      Factory.insert(:server_group, %{id: server_group_id, region_ids: [region_id]})

      assert is_nil(
               ClosestEdgeServerService.perform("196.196.196.196", tv_stream_id: tv_stream_id)
             )
    end

    test "Return nil if Server does not belong to TvStream", %{tv_stream_id: tv_stream_id} do
      subnet_id = 1342
      region_id = 1342
      server_group_id = 1342
      Factory.insert(:subnet, %{id: subnet_id, cidr: "196.196.196.196/29", region_id: region_id})

      Factory.insert(:region, %{
        id: region_id,
        subnet_ids: [subnet_id],
        server_group_ids: [server_group_id]
      })

      %{id: s_id1} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :inactive,
          type: :edge,
          healthcheck_enabled: true
        })

      %{id: s_id2} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :dvr,
          healthcheck_enabled: true
        })

      %{id: s_id3} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :edge,
          healthcheck_enabled: false
        })

      %{id: s_id4} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          weight: 10
        })

      %{id: s_id5} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          weight: 20
        })

      %{id: best_server_id} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          weight: 30
        })

      Factory.insert(:server_group, %{
        id: server_group_id,
        region_ids: [region_id],
        server_ids: [s_id1, s_id2, s_id3, s_id4, s_id5, best_server_id]
      })

      assert is_nil(
               ClosestEdgeServerService.perform("196.196.196.196", tv_stream_id: tv_stream_id)
             )

      delete_servers([s_id1, s_id2, s_id3, s_id4, s_id5, best_server_id])
    end

    test "Return most appropriate Server if they exist", %{tv_stream_id: tv_stream_id} do
      subnet_id = 1342
      region_id = 1342
      server_group_id = 1342
      Factory.insert(:subnet, %{id: subnet_id, cidr: "196.196.196.196/29", region_id: region_id})

      Factory.insert(:region, %{
        id: region_id,
        subnet_ids: [subnet_id],
        server_group_ids: [server_group_id]
      })

      %{id: s_id1} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :inactive,
          type: :edge,
          healthcheck_enabled: true
        })

      %{id: s_id2} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :dvr,
          healthcheck_enabled: true
        })

      %{id: s_id3} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :edge,
          healthcheck_enabled: false
        })

      %{id: s_id4} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          weight: 10
        })

      %{id: s_id5} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          weight: 20
        })

      %{id: best_server_id} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          weight: 30
        })

      Factory.insert(:server_group, %{
        id: server_group_id,
        region_ids: [region_id],
        server_ids: [s_id1, s_id2, s_id3, s_id4, s_id5, best_server_id]
      })

      assert is_nil(
               ClosestEdgeServerService.perform("196.196.196.196", tv_stream_id: tv_stream_id)
             )

      delete_servers([s_id1, s_id2, s_id3, s_id4, s_id5, best_server_id])
    end
  end

  describe "#perform if TvStream given success scenarios" do
    setup do
      subnet_id = 1342
      region_id = 1342
      server_group_id = 1342

      Factory.insert(:subnet, %{id: subnet_id, cidr: "196.196.196.196/29", region_id: region_id})

      Factory.insert(:region, %{
        id: region_id,
        subnet_ids: [subnet_id],
        server_group_ids: [server_group_id]
      })

      %{id: s_id1} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :inactive,
          type: :edge,
          healthcheck_enabled: true
        })

      %{id: s_id2} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :dvr,
          healthcheck_enabled: true
        })

      %{id: s_id3} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :edge,
          healthcheck_enabled: false
        })

      %{id: s_id4} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          weight: 10
        })

      %{id: s_id5} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :edge,
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
      tv_stream_id: tv_stream_id,
      server_ids: server_ids,
      region_id: region_id
    } do
      Factory.insert(:server_group, %{
        id: server_group_id,
        region_ids: [region_id],
        server_ids: server_ids,
        tv_stream_ids: [tv_stream_id]
      })

      assert ClosestEdgeServerService.perform("196.196.196.196", tv_stream_id: tv_stream_id).id in server_ids

      delete_servers(server_ids)
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

  # TODO костыль - поскольку у Mnesia нету песочницы, приходится удалять данные в ручную. Чтобы последующие тесты не падали
  def delete_servers(server_ids) do
    Amnesia.transaction(fn ->
      server_ids
      |> Enum.each(fn id -> DomainModel.Server.delete(id) end)
    end)
  end
end
