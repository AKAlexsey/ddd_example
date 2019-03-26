defmodule KalturaServer.RequestProcessing.CatchupResponserTest do
  use KalturaServer.PlugTestCase

  alias KalturaServer.RequestProcessing.CatchupResponser

  describe "#make_response application_layer_protocol: http" do
    setup do
      subnet_id = 777
      region_id = 777
      server_group_id = 777
      server1_id = 777
      server2_id = 778

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
          type: "EDGE",
          healthcheck_enabled: true,
          weight: 25
        })

      %{port: port, domain_name: domain_name2} =
        Factory.insert(:server, %{
          id: server2_id,
          server_group_ids: [server_group_id],
          port: 96,
          status: "ACTIVE",
          type: "EDGE",
          healthcheck_enabled: true,
          weight: 30
        })

      %{id: dvr_server1_id, prefix: dvr_prefix1} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: "ACTIVE",
          type: "EDGE",
          healthcheck_enabled: true
        })

      %{id: dvr_server2_id, prefix: dvr_prefix2} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: "ACTIVE",
          type: "EDGE",
          healthcheck_enabled: true
        })

      %{id: program_id, epg_id: epg_id} = Factory.insert(:program)

      Factory.insert(:server_group, %{
        id: server_group_id,
        region_ids: [region_id],
        server_ids: [server1_id, server2_id, dvr_server1_id, dvr_server2_id]
      })

      %{path: hls_path} =
        Factory.insert(:program_record, %{
          server_id: dvr_server1_id,
          program_id: program_id,
          protocol: "HLS",
          status: "COMPLETED"
        })

      %{path: hls_pr_path} =
        Factory.insert(:program_record, %{
          server_id: dvr_server1_id,
          program_id: program_id,
          protocol: "HLS",
          status: "COMPLETED",
          encryption: "CENC"
        })

      %{path: mpd_path} =
        Factory.insert(:program_record, %{
          server_id: dvr_server2_id,
          program_id: program_id,
          protocol: "MPD",
          status: "COMPLETED"
        })

      %{path: mpd_pr_path} =
        Factory.insert(:program_record, %{
          server_id: dvr_server2_id,
          program_id: program_id,
          protocol: "MPD",
          status: "COMPLETED",
          encryption: "CENC"
        })

      hls_conn =
        conn(:get, "/btv/catchup/hls/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "hls",
          encryption: "",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      hls_pr_conn =
        conn(:get, "/btv/catchup/hls_pr/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "hls",
          encryption: "pr",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      mpd_conn =
        conn(:get, "/btv/catchup/mpd/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "mpd",
          encryption: "",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      mpd_pr_conn =
        conn(:get, "/btv/catchup/mpd_pr/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "mpd",
          encryption: "pr",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      hls_redirect_path_without_port = "http://#{domain_name1}/dvr/#{dvr_prefix1}/#{hls_path}"

      hls_redirect_path_with_port =
        "http://#{domain_name2}:#{port}/dvr/#{dvr_prefix1}/#{hls_path}"

      hls_pr_redirect_path_without_port =
        "http://#{domain_name1}/dvr/#{dvr_prefix1}/#{hls_pr_path}"

      hls_pr_redirect_path_with_port =
        "http://#{domain_name2}:#{port}/dvr/#{dvr_prefix1}/#{hls_pr_path}"

      mpd_redirect_path_without_port = "http://#{domain_name1}/dvr/#{dvr_prefix2}/#{mpd_path}"

      mpd_redirect_path_with_port =
        "http://#{domain_name2}:#{port}/dvr/#{dvr_prefix2}/#{mpd_path}"

      mpd_pr_redirect_path_without_port =
        "http://#{domain_name1}/dvr/#{dvr_prefix2}/#{mpd_pr_path}"

      mpd_pr_redirect_path_with_port =
        "http://#{domain_name2}:#{port}/dvr/#{dvr_prefix2}/#{mpd_pr_path}"

      {
        :ok,
        hls_conn: hls_conn,
        hls_paths: [hls_redirect_path_without_port, hls_redirect_path_with_port],
        hls_pr_conn: hls_pr_conn,
        hls_pr_paths: [hls_pr_redirect_path_without_port, hls_pr_redirect_path_with_port],
        mpd_conn: mpd_conn,
        mpd_paths: [mpd_redirect_path_without_port, mpd_redirect_path_with_port],
        mpd_pr_conn: mpd_pr_conn,
        mpd_pr_paths: [mpd_pr_redirect_path_without_port, mpd_pr_redirect_path_with_port]
      }
    end

    test "Redirect to right path if appropriate server exist (HLS none)", %{
      hls_conn: conn,
      hls_paths: redirect_paths
    } do
      test_asserts(conn, redirect_paths)
    end

    test "Redirect to right path if appropriate server exist (HLS playready)", %{
      hls_pr_conn: conn,
      hls_pr_paths: redirect_paths
    } do
      test_asserts(conn, redirect_paths)
    end

    test "Redirect to right path if appropriate server exist (MPD none)", %{
      mpd_conn: conn,
      mpd_paths: redirect_paths
    } do
      test_asserts(conn, redirect_paths)
    end

    test "Redirect to right path if appropriate server exist (MPD playready)", %{
      mpd_pr_conn: conn,
      mpd_pr_paths: redirect_paths
    } do
      test_asserts(conn, redirect_paths)
    end
  end

  describe "#make_response application_layer_protocol: https" do
    setup do
      subnet_id = 777
      region_id = 777
      server_group_id = 777
      server1_id = 777
      server2_id = 778

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
          port: 443,
          status: "ACTIVE",
          type: "EDGE",
          healthcheck_enabled: true,
          weight: 25
        })

      %{port: port, domain_name: domain_name2} =
        Factory.insert(:server, %{
          id: server2_id,
          server_group_ids: [server_group_id],
          port: 96,
          status: "ACTIVE",
          type: "EDGE",
          healthcheck_enabled: true,
          weight: 30
        })

      %{id: dvr_server1_id, prefix: dvr_prefix1} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: "ACTIVE",
          type: "EDGE",
          healthcheck_enabled: true
        })

      %{id: dvr_server2_id, prefix: dvr_prefix2} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: "ACTIVE",
          type: "EDGE",
          healthcheck_enabled: true
        })

      %{id: program_id, epg_id: epg_id} = Factory.insert(:program)

      Factory.insert(:server_group, %{
        id: server_group_id,
        region_ids: [region_id],
        server_ids: [server1_id, server2_id, dvr_server1_id, dvr_server2_id]
      })

      %{path: hls_path} =
        Factory.insert(:program_record, %{
          server_id: dvr_server1_id,
          program_id: program_id,
          protocol: "HLS",
          status: "COMPLETED"
        })

      %{path: hls_pr_path} =
        Factory.insert(:program_record, %{
          server_id: dvr_server1_id,
          program_id: program_id,
          protocol: "HLS",
          status: "COMPLETED",
          encryption: "CENC"
        })

      %{path: mpd_path} =
        Factory.insert(:program_record, %{
          server_id: dvr_server2_id,
          program_id: program_id,
          protocol: "MPD",
          status: "COMPLETED"
        })

      %{path: mpd_pr_path} =
        Factory.insert(:program_record, %{
          server_id: dvr_server2_id,
          program_id: program_id,
          protocol: "MPD",
          status: "COMPLETED",
          encryption: "CENC"
        })

      hls_conn =
        conn(:get, "/btv/catchup/hls/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "hls",
          encryption: "",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      hls_pr_conn =
        conn(:get, "/btv/catchup/hls_pr/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "hls",
          encryption: "pr",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      mpd_conn =
        conn(:get, "/btv/catchup/mpd/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "mpd",
          encryption: "",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      mpd_pr_conn =
        conn(:get, "/btv/catchup/mpd_pr/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "mpd",
          encryption: "pr",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      hls_redirect_path_without_port = "https://#{domain_name1}/dvr/#{dvr_prefix1}/#{hls_path}"

      hls_redirect_path_with_port =
        "http://#{domain_name2}:#{port}/dvr/#{dvr_prefix1}/#{hls_path}"

      hls_pr_redirect_path_without_port =
        "https://#{domain_name1}/dvr/#{dvr_prefix1}/#{hls_pr_path}"

      hls_pr_redirect_path_with_port =
        "http://#{domain_name2}:#{port}/dvr/#{dvr_prefix1}/#{hls_pr_path}"

      mpd_redirect_path_without_port = "https://#{domain_name1}/dvr/#{dvr_prefix2}/#{mpd_path}"

      mpd_redirect_path_with_port =
        "http://#{domain_name2}:#{port}/dvr/#{dvr_prefix2}/#{mpd_path}"

      mpd_pr_redirect_path_without_port =
        "https://#{domain_name1}/dvr/#{dvr_prefix2}/#{mpd_pr_path}"

      mpd_pr_redirect_path_with_port =
        "http://#{domain_name2}:#{port}/dvr/#{dvr_prefix2}/#{mpd_pr_path}"

      {
        :ok,
        hls_conn: hls_conn,
        hls_paths: [hls_redirect_path_without_port, hls_redirect_path_with_port],
        hls_pr_conn: hls_pr_conn,
        hls_pr_paths: [hls_pr_redirect_path_without_port, hls_pr_redirect_path_with_port],
        mpd_conn: mpd_conn,
        mpd_paths: [mpd_redirect_path_without_port, mpd_redirect_path_with_port],
        mpd_pr_conn: mpd_pr_conn,
        mpd_pr_paths: [mpd_pr_redirect_path_without_port, mpd_pr_redirect_path_with_port]
      }
    end

    test "Redirect to right path if appropriate server exist (HLS, none)", %{
      hls_conn: conn,
      hls_paths: redirect_paths
    } do
      test_asserts(conn, redirect_paths)
    end

    test "Redirect to right path if appropriate server exist (HLS, playready)", %{
      hls_pr_conn: conn,
      hls_pr_paths: redirect_paths
    } do
      test_asserts(conn, redirect_paths)
    end

    test "Redirect to right path if appropriate server exist (MPD none)", %{
      mpd_conn: conn,
      mpd_paths: redirect_paths
    } do
      test_asserts(conn, redirect_paths)
    end

    test "Redirect to right path if appropriate server exist (MPD playready)", %{
      mpd_pr_conn: conn,
      mpd_pr_paths: redirect_paths
    } do
      test_asserts(conn, redirect_paths)
    end
  end

  describe "#make_response fail scenarios" do
    setup do
      conn = %Plug.Conn{
        assigns: %{
          protocol: "hls",
          encryption: "",
          resource_id: "p_epg_1234",
          ip_address: {124, 123, 123, 123}
        },
        remote_ip: {124, 123, 123, 123},
        request_path: "/btv/catchup/hls/resource_1234"
      }

      {:ok, conn: conn}
    end

    test "Return 400 error if passed is not connection", %{conn: %{assigns: assigns}} do
      invalid_conn = %{assigns: assigns}

      assert {^invalid_conn, 400, "Request invalid"} =
               CatchupResponser.make_response(invalid_conn)
    end

    test "Return 404 error if server can not be found", %{conn: conn} do
      assert {^conn, 404, "Server not found"} = CatchupResponser.make_response(conn)
    end
  end

  def test_asserts(conn, redirect_paths) do
    assert {%{
              resp_headers: [
                {"cache-control", "max-age=0, private, must-revalidate"},
                {"Location", response_redirect_path}
              ]
            }, 302, ""} = CatchupResponser.make_response(conn)

    assert response_redirect_path in redirect_paths
  end
end
