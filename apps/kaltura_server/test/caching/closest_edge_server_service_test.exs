defmodule KalturaServer.ClosestEdgeServerServiceTest do
  use KalturaServer.TestCase, async: false

  alias KalturaServer.ClosestEdgeServerService

  setup do
    %{id: tv_stream_id} = Factory.insert(:tv_stream)
    {:ok, tv_stream_id: tv_stream_id}
  end

  describe "#perform fails scenarios" do
    test "Return nil if no Subnets for given IP", %{tv_stream_id: tv_stream_id} do
      assert is_nil(ClosestEdgeServerService.perform("196.196.196.196", tv_stream_id))
    end

    test "Return nil if Subnet does not have Region", %{tv_stream_id: tv_stream_id} do
      Factory.insert(:subnet, %{cidr: "196.196.196.196/29"})
      assert is_nil(ClosestEdgeServerService.perform("196.196.196.196", tv_stream_id))
    end

    test "Return nil if Region does not have ServerGroups", %{tv_stream_id: tv_stream_id} do
      subnet_id = 1342
      region_id = 1342
      Factory.insert(:region, %{id: region_id, subnet_ids: [subnet_id]})
      Factory.insert(:subnet, %{id: subnet_id, cidr: "196.196.196.196/29", region_id: region_id})

      assert is_nil(ClosestEdgeServerService.perform("196.196.196.196", tv_stream_id))
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

      assert is_nil(ClosestEdgeServerService.perform("196.196.196.196", tv_stream_id))
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

      assert is_nil(ClosestEdgeServerService.perform("196.196.196.196", tv_stream_id))

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

      assert is_nil(ClosestEdgeServerService.perform("196.196.196.196", tv_stream_id))

      delete_servers([s_id1, s_id2, s_id3, s_id4, s_id5, best_server_id])
    end
  end

  describe "#perform success scenarios" do
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
      %{id: best_server_id} =
        best_server =
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
        server_ids: server_ids ++ [best_server_id],
        tv_stream_ids: [tv_stream_id]
      })

      assert best_server == ClosestEdgeServerService.perform("196.196.196.196", tv_stream_id)

      delete_servers(server_ids ++ [best_server_id])
    end

    test "Return Random sever if available servers are several", %{
      server_group_id: server_group_id,
      tv_stream_id: tv_stream_id,
      server_ids: server_ids,
      region_id: region_id
    } do
      %{id: best_server1_id} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          weight: 30
        })

      %{id: best_server2_id} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          weight: 30
        })

      %{id: best_server3_id} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          weight: 30
        })

      all_server_ids = server_ids ++ [best_server1_id, best_server2_id, best_server3_id]

      Factory.insert(:server_group, %{
        id: server_group_id,
        region_ids: [region_id],
        server_ids: all_server_ids,
        tv_stream_ids: [tv_stream_id]
      })

      assert ClosestEdgeServerService.perform("196.196.196.196", tv_stream_id).id in [
               best_server1_id,
               best_server2_id,
               best_server3_id
             ]

      delete_servers(all_server_ids)
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
