defmodule KalturaServer.RequestProcessing.MainRouterTest do
  require Amnesia
  require Amnesia.Helper

  use KalturaServer.PlugTestCase

  alias KalturaServer.RequestProcessing.MainRouter

  describe "#make_response #1 live" do
    setup do
      subnet_id = 1966
      region_id = 1966
      server_group_id = 1966
      Factory.insert(:subnet, %{id: subnet_id, cidr: "123.123.123.123/29", region_id: region_id})

      Factory.insert(:region, %{
        id: region_id,
        subnet_ids: [subnet_id],
        server_group_ids: [server_group_id]
      })

      %{id: edge_server1_id, domain_name: domain_name1} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          port: 80,
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          weight: 25
        })

      %{id: edge_server2_id, port: port, domain_name: domain_name2} =
        Factory.insert(:server, %{
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
        server_ids: [edge_server1_id, edge_server2_id],
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
        port_server_id: edge_server2_id
      }
    end

    test "Redirect to right path if appropriate server exist #1", %{
      conn: conn,
      redirect_path_without_port: redirect_path1,
      redirect_path_with_port: redirect_path2
    } do
      assert %{
               status: 302,
               resp_headers: [
                 {"cache-control", "max-age=0, private, must-revalidate"},
                 {"location", redirect_path}
               ]
             } = MainRouter.call(conn, MainRouter.init([]))

      assert redirect_path in [redirect_path1, redirect_path2]
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

  describe "#make_response #1 catchup" do
    setup do
      subnet_id = 20660
      region_id = 20660
      server_group_id = 20660
      edge_server1_id = 20660
      edge_server2_id = 20660
      Factory.insert(:subnet, %{id: subnet_id, cidr: "123.123.123.123/29", region_id: region_id})

      Factory.insert(:region, %{
        id: region_id,
        subnet_ids: [subnet_id],
        server_group_ids: [server_group_id]
      })

      %{domain_name: domain_name1} =
        Factory.insert(:server, %{
          id: edge_server1_id,
          server_group_ids: [server_group_id],
          port: 80,
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          weight: 25
        })

      %{port: port, domain_name: domain_name2} =
        Factory.insert(:server, %{
          id: edge_server2_id,
          server_group_ids: [server_group_id],
          port: 96,
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          weight: 30
        })

      %{id: dvr_server1_id, prefix: dvr_prefix1, domain_name: domain_name3} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :dvr,
          healthcheck_enabled: true
        })

      %{id: dvr_server2_id, prefix: dvr_prefix2, domain_name: domain_name4} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :dvr,
          healthcheck_enabled: true
        })

      %{id: program_id, epg_id: epg_id} = Factory.insert(:program)

      Factory.insert(:server_group, %{
        id: server_group_id,
        region_ids: [region_id],
        server_ids: [edge_server1_id, edge_server2_id, dvr_server1_id, dvr_server2_id]
      })

      %{id: program_record1_id, path: hls_path} =
        Factory.insert(:program_record, %{
          server_id: dvr_server1_id,
          program_id: program_id,
          protocol: :HLS,
          status: :completed
        })

      %{id: program_record2_id, path: mpd_path} =
        Factory.insert(:program_record, %{
          server_id: dvr_server2_id,
          program_id: program_id,
          protocol: :MPD,
          status: :completed
        })

      hls_conn =
        conn(:get, "/btv/catchup/hls/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: :HLS,
          resource_id: epg_id,
          ip_address: "123.123.123.123"
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      mpd_conn =
        conn(:get, "/btv/catchup/mpd/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: :MPD,
          resource_id: epg_id,
          ip_address: "123.123.123.123"
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      hls_redirect_path_without_port = "http://#{domain_name1}/dvr/#{dvr_prefix1}/#{hls_path}"

      hls_redirect_path_with_port =
        "http://#{domain_name2}:#{port}/dvr/#{dvr_prefix1}/#{hls_path}"

      mpd_redirect_path_without_port = "http://#{domain_name1}/dvr/#{dvr_prefix2}/#{mpd_path}"

      mpd_redirect_path_with_port =
        "http://#{domain_name2}:#{port}/dvr/#{dvr_prefix2}/#{mpd_path}"

      {
        :ok,
        hls_conn: hls_conn,
        hls_paths: [hls_redirect_path_without_port, hls_redirect_path_with_port],
        mpd_conn: mpd_conn,
        mpd_paths: [mpd_redirect_path_without_port, mpd_redirect_path_with_port]
      }
    end

    # TODO причина падения не яссная тесты плавают как моряк. Возможно починится само после разделения на на окружения.
    test "Redirect to right path if program record with given protocol exist #1", %{
      hls_conn: conn,
      hls_paths: redirect_paths,
      record_ids: record_ids,
      server_ids: server_ids
    } do
      assert %{
               status: 302,
               resp_headers: [
                 {"cache-control", "max-age=0, private, must-revalidate"},
                 {"location", redirect_path}
               ]
             } = MainRouter.call(conn, MainRouter.init([]))

      assert redirect_path in redirect_paths
    end

    test "Redirect to right path if program record with given protocol exist #2", %{
      mpd_conn: conn,
      mpd_paths: redirect_paths,
      record_ids: record_ids,
      server_ids: server_ids
    } do
      assert %{
               status: 302,
               resp_headers: [
                 {"cache-control", "max-age=0, private, must-revalidate"},
                 {"location", redirect_path}
               ]
             } = MainRouter.call(conn, MainRouter.init([]))

      assert redirect_path in redirect_paths
    end
  end

  describe "#make_response #1 vod" do
    setup do
      subnet_id = 2166
      region_id = 2166
      server_group_id = 2166
      Factory.insert(:subnet, %{id: subnet_id, cidr: "143.143.143.143/29", region_id: region_id})

      Factory.insert(:region, %{
        id: region_id,
        subnet_ids: [subnet_id],
        server_group_ids: [server_group_id]
      })

      %{id: edge_server1_id, domain_name: domain_name1} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          port: 80,
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          weight: 25
        })

      %{id: edge_server2_id, port: port, domain_name: domain_name2} =
        Factory.insert(:server, %{
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
        server_ids: [edge_server1_id, edge_server2_id]
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
        port_server_id: edge_server2_id
      }
    end

    test "Redirect to right path if appropriate server exist #1", %{
      conn: conn,
      redirect_path_without_port: redirect_path1,
      redirect_path_with_port: redirect_path2
    } do
      assert %{
               status: 302,
               resp_headers: [
                 {"cache-control", "max-age=0, private, must-revalidate"},
                 {"location", redirect_path}
               ]
             } = MainRouter.call(conn, MainRouter.init([]))

      assert redirect_path in [redirect_path1, redirect_path2]
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

  describe "Fail scenarios" do
    test "Return status 400 if there is no responser for given path" do
      conn =
        conn(:get, "/non/existing/path")
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      assert %{status: 400, resp_body: "Request invalid"} =
               MainRouter.call(conn, MainRouter.init([]))
    end
  end
end
