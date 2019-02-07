defmodule KalturaServer.RequestProcessing.VodResponserTest do
  Faker.start()

  use KalturaServer.PlugTestCase, async: false
  alias KalturaServer.RequestProcessing.VodResponser

  describe "#make_response" do
    setup do
      subnet_id = 1756
      region_id = 1756
      server_group_id = 1756
      best_server1_id = 1755
      best_server2_id = 1756
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

      Factory.insert(:server_group, %{
        id: server_group_id,
        region_ids: [region_id],
        server_ids: [s_id1, s_id2, s_id3, s_id4, s_id5, best_server1_id, best_server2_id]
      })

      vod_path = "#{Faker.Lorem.word()}/#{Faker.Lorem.word()}/#{Faker.Lorem.word()}"

      conn =
        conn(:get, "/vod/#{vod_path}")
        |> Map.put(:assigns, %{
          vod_path: vod_path,
          ip_address: "123.123.123.123"
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      redirect_path_without_port = "http://#{domain_name1}/vod/#{vod_path}"
      redirect_path_with_port = "http://#{domain_name2}:#{port}/vod/#{vod_path}"

      {:ok,
       conn: conn,
       redirect_path_with_port: redirect_path_with_port,
       redirect_path_without_port: redirect_path_without_port,
       port_server_id: best_server2_id}
    end

    test "Redirect to right path if appropriate server exist #1", %{
      conn: conn,
      redirect_path_with_port: redirect_path
    } do
      assert {redirect_conn, 302, ""} = VodResponser.make_response(conn)

      assert redirect_conn.resp_headers == [
               {"cache-control", "max-age=0, private, must-revalidate"},
               {"location", redirect_path}
             ]
    end

    test "Redirect to right path if appropriate server exist #2", %{
      conn: conn,
      redirect_path_without_port: redirect_path,
      port_server_id: port_server_id
    } do
      Amnesia.transaction(fn -> DomainModel.Server.delete(port_server_id) end)
      assert {redirect_conn, 302, ""} = VodResponser.make_response(conn)

      assert redirect_conn.resp_headers == [
               {"cache-control", "max-age=0, private, must-revalidate"},
               {"location", redirect_path}
             ]
    end
  end

  describe "#make_response fail scenarios" do
    setup do
      vod_path = "#{Faker.Lorem.word()}/#{Faker.Lorem.word()}/#{Faker.Lorem.word()}"

      conn = %Plug.Conn{
        assigns: %{
          vod_path: vod_path,
          ip_address: "124.123.123.123"
        },
        remote_ip: {124, 123, 123, 123},
        request_path: "/btv/live/hls/resource_1234"
      }

      {:ok, conn: conn}
    end

    test "Return 400 error if passed is not connection", %{
      conn: %{assigns: assigns}
    } do
      invalid_conn = %{assigns: assigns}
      assert {^invalid_conn, 400, "Request invalid"} = VodResponser.make_response(invalid_conn)
    end

    test "Return 500 error if server can not be found", %{conn: conn} do
      assert {^conn, 500, "Server not found"} = VodResponser.make_response(conn)
    end
  end
end
