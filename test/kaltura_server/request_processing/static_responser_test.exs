defmodule CtiKaltura.RequestProcessing.StaticResponserTest do
  Faker.start()

  use CtiKaltura.PlugTestCase
  alias CtiKaltura.RequestProcessing.StaticResponser

  describe "#make_response application_layer_protocol: http" do
    setup do
      subnet_id = 777
      region_id = 777
      server_group_id = 777
      server1_id = 778
      server2_id = 777

      Factory.insert(:subnet, %{
        id: subnet_id,
        cidr: "123.123.123.123/29",
        region_id: region_id,
        server_ids: [server1_id, server2_id]
      })

      Factory.insert(:region, %{
        id: region_id,
        subnet_ids: [subnet_id],
        server_group_ids: [server_group_id]
      })

      %{domain_name: domain_name1} =
        Factory.insert(:server, %{
          id: server1_id,
          server_group_ids: [server_group_id],
          port: 80,
          status: "ACTIVE",
          availability: true,
          type: "EDGE",
          healthcheck_enabled: true,
          weight: 25
        })

      %{domain_name: domain_name2} =
        Factory.insert(:server, %{
          id: server2_id,
          server_group_ids: [server_group_id],
          port: 96,
          status: "ACTIVE",
          availability: true,
          type: "EDGE",
          healthcheck_enabled: true,
          weight: 30
        })

      Factory.insert(:server_group, %{
        id: server_group_id,
        region_ids: [region_id],
        server_ids: [server1_id, server2_id]
      })

      static_path = "#{Faker.Lorem.word()}/#{Faker.Lorem.word()}/#{Faker.Lorem.word()}"

      conn =
        conn(:get, "/static/#{static_path}")
        |> Map.put(:assigns, %{
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      redirect_path_1 = "http://#{domain_name1}/static/#{static_path}"
      redirect_path_2 = "http://#{domain_name2}/static/#{static_path}"

      {:ok,
       conn: conn,
       redirect_path_1: redirect_path_1,
       redirect_path_2: redirect_path_2,
       port_server_id: server2_id}
    end

    test "Redirect to right path if appropriate server exist #1", %{
      conn: conn,
      redirect_path_1: redirect_path1,
      redirect_path_2: redirect_path2
    } do
      assert {%{
                resp_headers: [
                  {"cache-control", "max-age=0, private, must-revalidate"},
                  {"Location", redirect_path}
                ]
              }, 302, ""} = StaticResponser.make_response(conn)

      assert redirect_path in [redirect_path1, redirect_path2]
    end

    test "Redirect to right path if appropriate server exist #2", %{
      conn: conn,
      redirect_path_1: redirect_path,
      port_server_id: port_server_id
    } do
      Amnesia.transaction(fn -> DomainModel.Server.delete(port_server_id) end)
      assert {redirect_conn, 302, ""} = StaticResponser.make_response(conn)

      assert redirect_conn.resp_headers == [
               {"cache-control", "max-age=0, private, must-revalidate"},
               {"Location", redirect_path}
             ]
    end
  end

  describe "#make_response fail scenarios" do
    setup do
      conn = %Plug.Conn{
        assigns: %{
          ip_address: {124, 123, 123, 123}
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
      assert {^invalid_conn, 400, "Request invalid"} = StaticResponser.make_response(invalid_conn)
    end

    test "Return 404 error if server can not be found", %{conn: conn} do
      assert {^conn, 404, "Server not found"} = StaticResponser.make_response(conn)
    end
  end
end
