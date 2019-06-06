defmodule CtiKaltura.RequestProcessing.LiveResponserTest do
  use CtiKaltura.PlugTestCase

  alias CtiKaltura.RequestProcessing.LiveResponser

  describe "#make_response applycation_layer_protocol: http" do
    setup do
      subnet_id = 777
      region_id = 777
      server_group_id = 777
      linear_channel_id = 777
      best_server1_id = 778
      best_server2_id = 777
      mpd_wv_tv_stream_id = 777
      mpd_pr_tv_stream_id = 778
      mpd_none_tv_stream_id = 779
      mpd_common_tv_stream_id = 780
      hls_tv_stream_id = 781
      hls_common_tv_stream_id = 782

      Factory.insert(:subnet, %{
        id: subnet_id,
        cidr: "123.123.123.123/29",
        region_id: region_id,
        server_ids: [best_server1_id, best_server2_id]
      })

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
          status: "ACTIVE",
          availability: true,
          type: "EDGE",
          healthcheck_enabled: true,
          weight: 25
        })

      %{port: port, domain_name: domain_name2} =
        Factory.insert(:server, %{
          id: best_server2_id,
          server_group_ids: [server_group_id],
          port: 96,
          status: "ACTIVE",
          availability: true,
          type: "EDGE",
          healthcheck_enabled: true,
          weight: 30
        })

      %{epg_id: epg_id} =
        Factory.insert(:linear_channel, %{
          id: linear_channel_id,
          tv_stream_ids: [
            mpd_wv_tv_stream_id,
            mpd_pr_tv_stream_id,
            mpd_none_tv_stream_id,
            mpd_common_tv_stream_id,
            hls_tv_stream_id,
            hls_common_tv_stream_id
          ]
        })

      %{stream_path: mpd_pr_stream_path} =
        Factory.insert(:tv_stream, %{
          id: mpd_pr_tv_stream_id,
          linear_channel_id: linear_channel_id,
          protocol: "MPD",
          encryption: "PLAYREADY"
        })

      %{stream_path: mpd_common_stream_path} =
        Factory.insert(:tv_stream, %{
          id: mpd_common_tv_stream_id,
          linear_channel_id: linear_channel_id,
          protocol: "MPD",
          encryption: "CENC"
        })

      %{stream_path: mpd_wv_stream_path} =
        Factory.insert(:tv_stream, %{
          id: mpd_wv_tv_stream_id,
          linear_channel_id: linear_channel_id,
          protocol: "MPD",
          encryption: "WIDEVINE"
        })

      %{stream_path: mpd_none_stream_path} =
        Factory.insert(:tv_stream, %{
          id: mpd_none_tv_stream_id,
          linear_channel_id: linear_channel_id,
          protocol: "MPD",
          encryption: "NONE"
        })

      %{stream_path: hls_stream_path} =
        Factory.insert(:tv_stream, %{
          id: hls_tv_stream_id,
          linear_channel_id: linear_channel_id,
          protocol: "HLS",
          encryption: "NONE"
        })

      %{stream_path: hls_common_stream_path} =
        Factory.insert(:tv_stream, %{
          id: hls_common_tv_stream_id,
          linear_channel_id: linear_channel_id,
          protocol: "HLS",
          encryption: "CENC"
        })

      Factory.insert(:server_group, %{
        id: server_group_id,
        region_ids: [region_id],
        server_ids: [best_server1_id, best_server2_id],
        linear_channel_ids: [linear_channel_id]
      })

      mpd_pr_conn =
        conn(:get, "/btv/live/mpd_pr/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "mpd",
          encryption: "pr",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      mpd_wv_conn =
        conn(:get, "/btv/live/mpd_wv/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "mpd",
          encryption: "wv",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      mpd_conn =
        conn(:get, "/btv/live/mpd/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "mpd",
          encryption: "",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      hls_conn =
        conn(:get, "/btv/live/hls/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "hls",
          encryption: "",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      hls_pr_conn =
        conn(:get, "/btv/live/hls_pr/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "hls",
          encryption: "pr",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      hls_wv_conn =
        conn(:get, "/btv/live/hls_wv/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "hls",
          encryption: "wv",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      mpd_pr_redirect_path_without_port = "http://#{domain_name1}/#{mpd_pr_stream_path}"
      mpd_pr_redirect_path_with_port = "http://#{domain_name2}:#{port}/#{mpd_pr_stream_path}"
      mpd_common_redirect_path_without_port = "http://#{domain_name1}/#{mpd_common_stream_path}"

      mpd_common_redirect_path_with_port =
        "http://#{domain_name2}:#{port}/#{mpd_common_stream_path}"

      mpd_wv_redirect_path_without_port = "http://#{domain_name1}/#{mpd_wv_stream_path}"
      mpd_wv_redirect_path_with_port = "http://#{domain_name2}:#{port}/#{mpd_wv_stream_path}"
      mpd_none_redirect_path_without_port = "http://#{domain_name1}/#{mpd_none_stream_path}"
      mpd_none_redirect_path_with_port = "http://#{domain_name2}:#{port}/#{mpd_none_stream_path}"

      hls_redirect_path_without_port = "http://#{domain_name1}/#{hls_stream_path}"
      hls_redirect_path_with_port = "http://#{domain_name2}:#{port}/#{hls_stream_path}"
      hls_pr_redirect_path_without_port = "http://#{domain_name1}/#{hls_common_stream_path}"
      hls_pr_redirect_path_with_port = "http://#{domain_name2}:#{port}/#{hls_common_stream_path}"
      hls_wv_redirect_path_without_port = "http://#{domain_name1}/#{hls_common_stream_path}"
      hls_wv_redirect_path_with_port = "http://#{domain_name2}:#{port}/#{hls_common_stream_path}"

      {
        :ok,
        mpd_pr_conn: mpd_pr_conn,
        mpd_wv_conn: mpd_wv_conn,
        mpd_conn: mpd_conn,
        hls_conn: hls_conn,
        hls_pr_conn: hls_pr_conn,
        hls_wv_conn: hls_wv_conn,
        mpd_pr_redirect_path_with_port: mpd_pr_redirect_path_with_port,
        mpd_pr_redirect_path_without_port: mpd_pr_redirect_path_without_port,
        mpd_common_redirect_path_with_port: mpd_common_redirect_path_with_port,
        mpd_common_redirect_path_without_port: mpd_common_redirect_path_without_port,
        mpd_wv_redirect_path_with_port: mpd_wv_redirect_path_with_port,
        mpd_wv_redirect_path_without_port: mpd_wv_redirect_path_without_port,
        mpd_none_redirect_path_with_port: mpd_none_redirect_path_with_port,
        mpd_none_redirect_path_without_port: mpd_none_redirect_path_without_port,
        hls_redirect_path_with_port: hls_redirect_path_with_port,
        hls_redirect_path_without_port: hls_redirect_path_without_port,
        hls_pr_redirect_path_with_port: hls_pr_redirect_path_with_port,
        hls_pr_redirect_path_without_port: hls_pr_redirect_path_without_port,
        hls_wv_redirect_path_with_port: hls_wv_redirect_path_with_port,
        hls_wv_redirect_path_without_port: hls_wv_redirect_path_without_port,
        port_server_id: best_server2_id,
        mpd_pr_tv_stream_id: mpd_pr_tv_stream_id,
        mpd_common_tv_stream_id: mpd_common_tv_stream_id
      }
    end

    test "Redirect to right path if appropriate server exist #1 stream_meta mpd_wv", %{
      mpd_wv_conn: conn,
      mpd_wv_redirect_path_without_port: redirect_path1,
      mpd_wv_redirect_path_with_port: redirect_path2
    } do
      assert {%{
                resp_headers: [
                  {"cache-control", "max-age=0, private, must-revalidate"},
                  {"Location", redirect_path}
                ]
              }, 302, ""} = LiveResponser.make_response(conn)

      assert redirect_path in [redirect_path1, redirect_path2]
    end

    test "Redirect to right path if appropriate server exist #2 stream_meta mpd_wv", %{
      mpd_wv_conn: conn,
      mpd_wv_redirect_path_without_port: redirect_path,
      port_server_id: port_server_id
    } do
      Amnesia.transaction(fn -> DomainModel.Server.delete(port_server_id) end)
      assert {redirect_conn, 302, ""} = LiveResponser.make_response(conn)

      assert redirect_conn.resp_headers == [
               {"cache-control", "max-age=0, private, must-revalidate"},
               {"Location", redirect_path}
             ]
    end

    test "Redirect to right path if appropriate server exist #3 stream_meta mpd_pr", %{
      mpd_pr_conn: conn,
      mpd_pr_redirect_path_without_port: redirect_path1,
      mpd_pr_redirect_path_with_port: redirect_path2
    } do
      assert {%{
                resp_headers: [
                  {"cache-control", "max-age=0, private, must-revalidate"},
                  {"Location", redirect_path}
                ]
              }, 302, ""} = LiveResponser.make_response(conn)

      assert redirect_path in [redirect_path1, redirect_path2]
    end

    test "Redirect to right path if appropriate server exist #4 stream_meta mpd_pr", %{
      mpd_pr_conn: conn,
      mpd_common_redirect_path_without_port: redirect_path1,
      mpd_common_redirect_path_with_port: redirect_path2,
      mpd_pr_tv_stream_id: tv_stream_id
    } do
      Amnesia.transaction(fn -> DomainModel.TvStream.delete(tv_stream_id) end)

      assert {%{
                resp_headers: [
                  {"cache-control", "max-age=0, private, must-revalidate"},
                  {"Location", redirect_path}
                ]
              }, 302, ""} = LiveResponser.make_response(conn)

      assert redirect_path in [redirect_path1, redirect_path2]
    end

    test "Redirect to right path if appropriate server exist #5 stream_meta mpd", %{
      mpd_conn: conn,
      mpd_none_redirect_path_without_port: redirect_path1,
      mpd_none_redirect_path_with_port: redirect_path2
    } do
      assert {%{
                resp_headers: [
                  {"cache-control", "max-age=0, private, must-revalidate"},
                  {"Location", redirect_path}
                ]
              }, 302, ""} = LiveResponser.make_response(conn)

      assert redirect_path in [redirect_path1, redirect_path2]
    end

    test "Return error if there is no TvStream with given codec and protocol", %{
      mpd_pr_conn: conn,
      mpd_pr_tv_stream_id: tv_stream_id1,
      mpd_common_tv_stream_id: tv_stream_id2
    } do
      Amnesia.transaction(fn ->
        DomainModel.TvStream.delete(tv_stream_id1)
        DomainModel.TvStream.delete(tv_stream_id2)
      end)

      assert assert {^conn, 404, "Server not found"} = LiveResponser.make_response(conn)
    end

    test "Redirect to right path if appropriate server exist #6 stream_meta HLS (none)", %{
      hls_conn: conn,
      hls_redirect_path_without_port: redirect_path1,
      hls_redirect_path_with_port: redirect_path2
    } do
      assert {%{
                resp_headers: [
                  {"cache-control", "max-age=0, private, must-revalidate"},
                  {"Location", redirect_path}
                ]
              }, 302, ""} = LiveResponser.make_response(conn)

      assert redirect_path in [redirect_path1, redirect_path2]
    end

    test "Redirect to right path if appropriate server exist #6 stream_meta HLS (PLAYREADY)", %{
      hls_pr_conn: conn,
      hls_pr_redirect_path_without_port: redirect_path1,
      hls_pr_redirect_path_with_port: redirect_path2
    } do
      assert {%{
                resp_headers: [
                  {"cache-control", "max-age=0, private, must-revalidate"},
                  {"Location", redirect_path}
                ]
              }, 302, ""} = LiveResponser.make_response(conn)

      assert redirect_path in [redirect_path1, redirect_path2]
    end

    test "Redirect to right path if appropriate server exist #6 stream_meta HLS (WIDEVINE)", %{
      hls_wv_conn: conn,
      hls_wv_redirect_path_without_port: redirect_path1,
      hls_wv_redirect_path_with_port: redirect_path2
    } do
      assert {%{
                resp_headers: [
                  {"cache-control", "max-age=0, private, must-revalidate"},
                  {"Location", redirect_path}
                ]
              }, 302, ""} = LiveResponser.make_response(conn)

      assert redirect_path in [redirect_path1, redirect_path2]
    end
  end

  describe "#make_response applycation_layer_protocol: https" do
    setup do
      subnet_id = 777
      region_id = 777
      server_group_id = 777
      linear_channel_id = 777
      best_server1_id = 778
      best_server2_id = 777
      mpd_wv_tv_stream_id = 777
      mpd_pr_tv_stream_id = 778
      mpd_none_tv_stream_id = 779
      mpd_common_tv_stream_id = 780
      hls_tv_stream_id = 781
      hls_common_tv_stream_id = 782

      Factory.insert(:subnet, %{
        id: subnet_id,
        cidr: "123.123.123.123/29",
        region_id: region_id,
        server_ids: [best_server1_id, best_server2_id]
      })

      Factory.insert(:region, %{
        id: region_id,
        subnet_ids: [subnet_id],
        server_group_ids: [server_group_id]
      })

      %{domain_name: domain_name1} =
        Factory.insert(:server, %{
          id: best_server1_id,
          server_group_ids: [server_group_id],
          port: 443,
          status: "ACTIVE",
          availability: true,
          type: "EDGE",
          healthcheck_enabled: true,
          weight: 25
        })

      %{port: port, domain_name: domain_name2} =
        Factory.insert(:server, %{
          id: best_server2_id,
          server_group_ids: [server_group_id],
          port: 96,
          status: "ACTIVE",
          availability: true,
          type: "EDGE",
          healthcheck_enabled: true,
          weight: 30
        })

      %{epg_id: epg_id} =
        Factory.insert(:linear_channel, %{
          id: linear_channel_id,
          tv_stream_ids: [
            mpd_wv_tv_stream_id,
            mpd_pr_tv_stream_id,
            mpd_none_tv_stream_id,
            mpd_common_tv_stream_id,
            hls_tv_stream_id,
            hls_common_tv_stream_id
          ]
        })

      %{stream_path: mpd_pr_stream_path} =
        Factory.insert(:tv_stream, %{
          id: mpd_pr_tv_stream_id,
          linear_channel_id: linear_channel_id,
          protocol: "MPD",
          encryption: "PLAYREADY"
        })

      %{stream_path: mpd_common_stream_path} =
        Factory.insert(:tv_stream, %{
          id: mpd_common_tv_stream_id,
          linear_channel_id: linear_channel_id,
          protocol: "MPD",
          encryption: "CENC"
        })

      %{stream_path: mpd_wv_stream_path} =
        Factory.insert(:tv_stream, %{
          id: mpd_wv_tv_stream_id,
          linear_channel_id: linear_channel_id,
          protocol: "MPD",
          encryption: "WIDEVINE"
        })

      %{stream_path: mpd_none_stream_path} =
        Factory.insert(:tv_stream, %{
          id: mpd_none_tv_stream_id,
          linear_channel_id: linear_channel_id,
          protocol: "MPD",
          encryption: "NONE"
        })

      %{stream_path: hls_stream_path} =
        Factory.insert(:tv_stream, %{
          id: hls_tv_stream_id,
          linear_channel_id: linear_channel_id,
          protocol: "HLS",
          encryption: "NONE"
        })

      %{stream_path: hls_common_stream_path} =
        Factory.insert(:tv_stream, %{
          id: hls_common_tv_stream_id,
          linear_channel_id: linear_channel_id,
          protocol: "HLS",
          encryption: "CENC"
        })

      Factory.insert(:server_group, %{
        id: server_group_id,
        region_ids: [region_id],
        server_ids: [best_server1_id, best_server2_id],
        linear_channel_ids: [linear_channel_id]
      })

      mpd_pr_conn =
        conn(:get, "/btv/live/mpd_pr/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "mpd",
          encryption: "pr",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      mpd_wv_conn =
        conn(:get, "/btv/live/mpd_wv/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "mpd",
          encryption: "wv",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      mpd_conn =
        conn(:get, "/btv/live/mpd/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "mpd",
          encryption: "",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      hls_conn =
        conn(:get, "/btv/live/hls/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "hls",
          encryption: "",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      hls_pr_conn =
        conn(:get, "/btv/live/hls_pr/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "hls",
          encryption: "pr",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      hls_wv_conn =
        conn(:get, "/btv/live/hls_wv/#{epg_id}")
        |> Map.put(:assigns, %{
          protocol: "hls",
          encryption: "wv",
          resource_id: epg_id,
          ip_address: {123, 123, 123, 123}
        })
        |> Map.put(:remote_ip, {123, 123, 123, 123})

      mpd_pr_redirect_path_without_port = "https://#{domain_name1}/#{mpd_pr_stream_path}"
      mpd_pr_redirect_path_with_port = "http://#{domain_name2}:#{port}/#{mpd_pr_stream_path}"
      mpd_common_redirect_path_without_port = "https://#{domain_name1}/#{mpd_common_stream_path}"

      mpd_common_redirect_path_with_port =
        "http://#{domain_name2}:#{port}/#{mpd_common_stream_path}"

      mpd_wv_redirect_path_without_port = "https://#{domain_name1}/#{mpd_wv_stream_path}"
      mpd_wv_redirect_path_with_port = "http://#{domain_name2}:#{port}/#{mpd_wv_stream_path}"
      mpd_none_redirect_path_without_port = "https://#{domain_name1}/#{mpd_none_stream_path}"
      mpd_none_redirect_path_with_port = "http://#{domain_name2}:#{port}/#{mpd_none_stream_path}"

      hls_redirect_path_without_port = "https://#{domain_name1}/#{hls_stream_path}"
      hls_redirect_path_with_port = "http://#{domain_name2}:#{port}/#{hls_stream_path}"

      hls_common_redirect_path_without_port = "https://#{domain_name1}/#{hls_common_stream_path}"

      hls_common_redirect_path_with_port =
        "http://#{domain_name2}:#{port}/#{hls_common_stream_path}"

      {
        :ok,
        mpd_pr_conn: mpd_pr_conn,
        mpd_wv_conn: mpd_wv_conn,
        mpd_conn: mpd_conn,
        hls_conn: hls_conn,
        hls_pr_conn: hls_pr_conn,
        hls_wv_conn: hls_wv_conn,
        mpd_pr_redirect_path_with_port: mpd_pr_redirect_path_with_port,
        mpd_pr_redirect_path_without_port: mpd_pr_redirect_path_without_port,
        mpd_common_redirect_path_with_port: mpd_common_redirect_path_with_port,
        mpd_common_redirect_path_without_port: mpd_common_redirect_path_without_port,
        mpd_wv_redirect_path_with_port: mpd_wv_redirect_path_with_port,
        mpd_wv_redirect_path_without_port: mpd_wv_redirect_path_without_port,
        mpd_none_redirect_path_with_port: mpd_none_redirect_path_with_port,
        mpd_none_redirect_path_without_port: mpd_none_redirect_path_without_port,
        hls_redirect_path_with_port: hls_redirect_path_with_port,
        hls_redirect_path_without_port: hls_redirect_path_without_port,
        hls_common_redirect_path_with_port: hls_common_redirect_path_with_port,
        hls_common_redirect_path_without_port: hls_common_redirect_path_without_port,
        port_server_id: best_server2_id,
        mpd_pr_tv_stream_id: mpd_pr_tv_stream_id,
        mpd_common_tv_stream_id: mpd_common_tv_stream_id
      }
    end

    test "Redirect to right path if appropriate server exist #1 stream_meta mpd_wv", %{
      mpd_wv_conn: conn,
      mpd_wv_redirect_path_without_port: redirect_path1,
      mpd_wv_redirect_path_with_port: redirect_path2
    } do
      assert {%{
                resp_headers: [
                  {"cache-control", "max-age=0, private, must-revalidate"},
                  {"Location", redirect_path}
                ]
              }, 302, ""} = LiveResponser.make_response(conn)

      assert redirect_path in [redirect_path1, redirect_path2]
    end

    test "Redirect to right path if appropriate server exist #2 stream_meta mpd_wv", %{
      mpd_wv_conn: conn,
      mpd_wv_redirect_path_without_port: redirect_path,
      port_server_id: port_server_id
    } do
      Amnesia.transaction(fn -> DomainModel.Server.delete(port_server_id) end)
      assert {redirect_conn, 302, ""} = LiveResponser.make_response(conn)

      assert redirect_conn.resp_headers == [
               {"cache-control", "max-age=0, private, must-revalidate"},
               {"Location", redirect_path}
             ]
    end

    test "Redirect to right path if appropriate server exist #3 stream_meta mpd_pr", %{
      mpd_pr_conn: conn,
      mpd_pr_redirect_path_without_port: redirect_path1,
      mpd_pr_redirect_path_with_port: redirect_path2
    } do
      assert {%{
                resp_headers: [
                  {"cache-control", "max-age=0, private, must-revalidate"},
                  {"Location", redirect_path}
                ]
              }, 302, ""} = LiveResponser.make_response(conn)

      assert redirect_path in [redirect_path1, redirect_path2]
    end

    test "Redirect to right path if appropriate server exist #4 stream_meta mpd_pr", %{
      mpd_pr_conn: conn,
      mpd_common_redirect_path_without_port: redirect_path1,
      mpd_common_redirect_path_with_port: redirect_path2,
      mpd_pr_tv_stream_id: tv_stream_id
    } do
      Amnesia.transaction(fn -> DomainModel.TvStream.delete(tv_stream_id) end)

      assert {%{
                resp_headers: [
                  {"cache-control", "max-age=0, private, must-revalidate"},
                  {"Location", redirect_path}
                ]
              }, 302, ""} = LiveResponser.make_response(conn)

      assert redirect_path in [redirect_path1, redirect_path2]
    end

    test "Redirect to right path if appropriate server exist #5 stream_meta mpd", %{
      mpd_conn: conn,
      mpd_none_redirect_path_without_port: redirect_path1,
      mpd_none_redirect_path_with_port: redirect_path2
    } do
      assert {%{
                resp_headers: [
                  {"cache-control", "max-age=0, private, must-revalidate"},
                  {"Location", redirect_path}
                ]
              }, 302, ""} = LiveResponser.make_response(conn)

      assert redirect_path in [redirect_path1, redirect_path2]
    end

    test "Return error if there is no TvStream with given codec and protocol", %{
      mpd_pr_conn: conn,
      mpd_pr_tv_stream_id: tv_stream_id1,
      mpd_common_tv_stream_id: tv_stream_id2
    } do
      Amnesia.transaction(fn ->
        DomainModel.TvStream.delete(tv_stream_id1)
        DomainModel.TvStream.delete(tv_stream_id2)
      end)

      assert assert {^conn, 404, "Server not found"} = LiveResponser.make_response(conn)
    end

    test "Redirect to right path if appropriate server exist #6 stream_meta HLS (none)", %{
      hls_conn: conn,
      hls_redirect_path_without_port: redirect_path1,
      hls_redirect_path_with_port: redirect_path2
    } do
      assert {%{
                resp_headers: [
                  {"cache-control", "max-age=0, private, must-revalidate"},
                  {"Location", redirect_path}
                ]
              }, 302, ""} = LiveResponser.make_response(conn)

      assert redirect_path in [redirect_path1, redirect_path2]
    end

    test "Redirect to right path if appropriate server exist #6 stream_meta HLS (PLAYREADY)", %{
      hls_pr_conn: conn,
      hls_common_redirect_path_without_port: redirect_path1,
      hls_common_redirect_path_with_port: redirect_path2
    } do
      assert {%{
                resp_headers: [
                  {"cache-control", "max-age=0, private, must-revalidate"},
                  {"Location", redirect_path}
                ]
              }, 302, ""} = LiveResponser.make_response(conn)

      assert redirect_path in [redirect_path1, redirect_path2]
    end

    test "Redirect to right path if appropriate server exist #6 stream_meta HLS (WIDEVINE)", %{
      hls_wv_conn: conn,
      hls_common_redirect_path_without_port: redirect_path1,
      hls_common_redirect_path_with_port: redirect_path2
    } do
      assert {%{
                resp_headers: [
                  {"cache-control", "max-age=0, private, must-revalidate"},
                  {"Location", redirect_path}
                ]
              }, 302, ""} = LiveResponser.make_response(conn)

      assert redirect_path in [redirect_path1, redirect_path2]
    end
  end

  describe "#make_response fail scenarios" do
    setup do
      conn = %Plug.Conn{
        assigns: %{
          protocol: "hls",
          encryption: "",
          resource_id: "resource_1234",
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
      assert {^invalid_conn, 400, "Request invalid"} = LiveResponser.make_response(invalid_conn)
    end

    test "Return 404 error if server can not be found", %{conn: conn} do
      assert {^conn, 404, "Server not found"} = LiveResponser.make_response(conn)
    end
  end
end
