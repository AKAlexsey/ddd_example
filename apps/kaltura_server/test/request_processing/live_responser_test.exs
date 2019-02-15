defmodule KalturaServer.RequestProcessing.LiveResponserTest do
  use KalturaServer.PlugTestCase

  alias KalturaServer.RequestProcessing.LiveResponser

  describe "#make_response" do
    setup do
      subnet_id = 777
      region_id = 777
      server_group_id = 777
      best_server1_id = 778
      best_server2_id = 777
      Factory.insert(:subnet, %{id: subnet_id, cidr: "123.123.123.123/29", region_id: region_id})

      Factory.insert(:region, %{
        id: region_id,
        subnet_ids: [subnet_id],
        server_group_ids: [server_group_id]
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
        server_ids: [best_server1_id, best_server2_id],
        tv_stream_ids: [tv_stream_id]
      })

      conn =
        conn(:get, "/btv/live/hls/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: :hls,
          resource_id: epg_id,
          ip_address: "123.123.123.123"
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      redirect_path_without_port = "http://#{domain_name1}/hls/#{stream_path}"
      redirect_path_with_port = "http://#{domain_name2}:#{port}/hls/#{stream_path}"

      {:ok,
       conn: conn,
       redirect_path_with_port: redirect_path_with_port,
       redirect_path_without_port: redirect_path_without_port,
       port_server_id: best_server2_id}
    end

    test "Redirect to right path if appropriate server exist #1", %{
      conn: conn,
      redirect_path_without_port: redirect_path1,
      redirect_path_with_port: redirect_path2
    } do
      assert {%{
                resp_headers: [
                  {"cache-control", "max-age=0, private, must-revalidate"},
                  {"location", redirect_path}
                ]
              }, 302, ""} = LiveResponser.make_response(conn)

      assert redirect_path in [redirect_path1, redirect_path2]
    end

    test "Redirect to right path if appropriate server exist #2", %{
      conn: conn,
      redirect_path_without_port: redirect_path,
      port_server_id: port_server_id
    } do
      Amnesia.transaction(fn -> DomainModel.Server.delete(port_server_id) end)
      assert {redirect_conn, 302, ""} = LiveResponser.make_response(conn)

      assert redirect_conn.resp_headers == [
               {"cache-control", "max-age=0, private, must-revalidate"},
               {"location", redirect_path}
             ]
    end
  end

  describe "#make_response fail scenarios" do
    setup do
      conn = %Plug.Conn{
        assigns: %{
          protocol: :hls,
          resource_id: "resource_1234",
          ip_address: "123.123.123.123"
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
      assert {^invalid_conn, 400, "Request invalid"} = LiveResponser.make_response(invalid_conn)
    end

    test "Return 500 error if server can not be found", %{conn: conn} do
      assert {^conn, 500, "Server not found"} = LiveResponser.make_response(conn)
    end
  end
end
