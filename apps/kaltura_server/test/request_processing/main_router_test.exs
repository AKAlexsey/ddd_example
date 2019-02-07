defmodule KalturaServer.RequestProcessing.MainRouterTest do
  use KalturaServer.PlugTestCase

  alias KalturaServer.RequestProcessing.MainRouter

  describe "#make_response #1 live" do
    setup do
      subnet_id = 1966
      region_id = 1966
      server_group_id = 1966
      best_server1_id = 1965
      best_server2_id = 1966
      Factory.insert(:subnet, %{id: subnet_id, cidr: "123.123.123.123/29", region_id: region_id})

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

      %{domain_name: domain_name1} =
        Factory.insert(:server, %{
          id: best_server1_id,
          server_group_ids: [server_group_id],
          port: 80,
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          weight: 25
        })

      %{port: port, domain_name: domain_name2} =
        Factory.insert(:server, %{
          id: best_server2_id,
          server_group_ids: [server_group_id],
          port: 96,
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          weight: 30
        })

      %{id: tv_stream_id, stream_path: stream_path, epg_id: epg_id} = Factory.insert(:tv_stream)

      Factory.insert(:server_group, %{
        id: server_group_id,
        region_ids: [region_id],
        server_ids: [s_id1, s_id2, s_id3, s_id4, s_id5, best_server1_id, best_server2_id],
        tv_stream_ids: [tv_stream_id]
      })

      conn =
        conn(:get, "/btv/live/hls/#{epg_id}")
        |> Map.put(:remote_ip, {123, 123, 123, 123})
        |> Map.put(:assigns, %{
          protocol: :hls,
          type: :live,
          resource_id: epg_id,
          ip_address: "123.123.123.123"
        })

      redirect_path_without_port = "http://#{domain_name1}/hls/#{stream_path}"
      redirect_path_with_port = "http://#{domain_name2}:#{port}/hls/#{stream_path}"

      {
        :ok,
        conn: conn,
        redirect_path_with_port: redirect_path_with_port,
        redirect_path_without_port: redirect_path_without_port,
        port_server_id: best_server2_id
      }
    end

    test "Redirect to right path if appropriate server exist #1", %{
      conn: conn,
      redirect_path_with_port: redirect_path
    } do
      assert %{
               status: 302,
               resp_headers: [
                 {"cache-control", "max-age=0, private, must-revalidate"},
                 {"location", ^redirect_path}
               ]
             } = MainRouter.call(conn, MainRouter.init([]))
    end

    test "Redirect to right path if appropriate server exist #2", %{
      conn: conn,
      redirect_path_without_port: redirect_path,
      port_server_id: port_server_id
    } do
      Amnesia.transaction(fn -> DomainModel.Server.delete(port_server_id) end)

      assert %{
               status: 302,
               resp_headers: [
                 {"cache-control", "max-age=0, private, must-revalidate"},
                 {"location", ^redirect_path}
               ]
             } = MainRouter.call(conn, MainRouter.init([]))
    end
  end

  describe "#make_response #1 vod" do
    setup do
      subnet_id = 2066
      region_id = 2066
      server_group_id = 2066
      best_server1_id = 2065
      best_server2_id = 2066
      Factory.insert(:subnet, %{id: subnet_id, cidr: "143.143.143.143/29", region_id: region_id})

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

      %{domain_name: domain_name1} =
        Factory.insert(:server, %{
          id: best_server1_id,
          server_group_ids: [server_group_id],
          port: 80,
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          weight: 25
        })

      %{port: port, domain_name: domain_name2} =
        Factory.insert(:server, %{
          id: best_server2_id,
          server_group_ids: [server_group_id],
          port: 96,
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          weight: 30
        })

      Factory.insert(:server_group, %{
        id: server_group_id,
        region_ids: [region_id],
        server_ids: [s_id1, s_id2, s_id3, s_id4, s_id5, best_server1_id, best_server2_id]
      })

      vod_path = "#{Faker.Lorem.word()}/#{Faker.Lorem.word()}/#{Faker.Lorem.word()}"

      conn =
        conn(:get, "/vod/#{vod_path}")
        |> Map.put(:remote_ip, {143, 143, 143, 143})
        |> Map.put(:assigns, %{
          vod_path: vod_path,
          ip_address: "143.143.143.143"
        })

      redirect_path_without_port = "http://#{domain_name1}/vod/#{vod_path}"
      redirect_path_with_port = "http://#{domain_name2}:#{port}/vod/#{vod_path}"

      {
        :ok,
        conn: conn,
        redirect_path_with_port: redirect_path_with_port,
        redirect_path_without_port: redirect_path_without_port,
        port_server_id: best_server2_id
      }
    end

    test "Redirect to right path if appropriate server exist #1", %{
      conn: conn,
      redirect_path_with_port: redirect_path
    } do
      assert %{
               status: 302,
               resp_headers: [
                 {"cache-control", "max-age=0, private, must-revalidate"},
                 {"location", ^redirect_path}
               ]
             } = MainRouter.call(conn, MainRouter.init([]))
    end

    test "Redirect to right path if appropriate server exist #2", %{
      conn: conn,
      redirect_path_without_port: redirect_path,
      port_server_id: port_server_id
    } do
      Amnesia.transaction(fn -> DomainModel.Server.delete(port_server_id) end)

      assert %{
               status: 302,
               resp_headers: [
                 {"cache-control", "max-age=0, private, must-revalidate"},
                 {"location", ^redirect_path}
               ]
             } = MainRouter.call(conn, MainRouter.init([]))
    end
  end
end
