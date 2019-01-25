defmodule KalturaServer.RequestProcessing.DataReaderTest do
  use KalturaServer.PlugTestCase, async: false

  alias KalturaServer.RequestProcessing.DataReader

  describe "#call" do
    setup do
      {:ok,
       ip_address: {123, 123, 123, 123},
       str_ip_address: "123.123.123.123",
       resource_id: "resource_1234"}
    end

    test "set assigns right. request: live, protocol: hls", %{
      ip_address: ip_address,
      str_ip_address: str_ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "hls",
                 type: :live,
                 resource_id: ^res_id,
                 ip_address: ^str_ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/live/hls/#{res_id}"), %{})
    end

    test "set assigns right. request: live, protocol: mpd", %{
      ip_address: ip_address,
      str_ip_address: str_ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd",
                 type: :live,
                 resource_id: ^res_id,
                 ip_address: ^str_ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/live/mpd/#{res_id}"), %{})
    end

    test "set assigns right. request: live, protocol: mpd_wv", %{
      ip_address: ip_address,
      str_ip_address: str_ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd_wv",
                 type: :live,
                 resource_id: ^res_id,
                 ip_address: ^str_ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/live/mpd_wv/#{res_id}"), %{})
    end

    test "set assigns right. request: live, protocol: mpd_pr", %{
      ip_address: ip_address,
      str_ip_address: str_ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd_pr",
                 type: :live,
                 resource_id: ^res_id,
                 ip_address: ^str_ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/live/mpd_pr/#{res_id}"), %{})
    end

    test "set assigns right. request: catchup, protocol: hls", %{
      ip_address: ip_address,
      str_ip_address: str_ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "hls",
                 type: :catchup,
                 resource_id: ^res_id,
                 ip_address: ^str_ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/catchup/hls/#{res_id}"), %{})
    end

    test "set assigns right. request: catchup, protocol: mpd", %{
      ip_address: ip_address,
      str_ip_address: str_ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd",
                 type: :catchup,
                 resource_id: ^res_id,
                 ip_address: ^str_ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/catchup/mpd/#{res_id}"), %{})
    end

    test "set assigns right. request: catchup, protocol: mpd_wv", %{
      ip_address: ip_address,
      str_ip_address: str_ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd_wv",
                 type: :catchup,
                 resource_id: ^res_id,
                 ip_address: ^str_ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/catchup/mpd_wv/#{res_id}"), %{})
    end

    test "set assigns right. request: catchup, protocol: mpd_pr", %{
      ip_address: ip_address,
      str_ip_address: str_ip_address,
      resource_id: res_id
    } do
      assert %Plug.Conn{
               assigns: %{
                 protocol: "mpd_pr",
                 type: :catchup,
                 resource_id: ^res_id,
                 ip_address: ^str_ip_address
               }
             } = DataReader.call(build_conn(ip_address, "/btv/catchup/mpd_pr/#{res_id}"), %{})
    end

    test "Return plug assigns if request type is wrong", %{
      ip_address: ip_address,
      str_ip_address: str_ip_address,
      resource_id: res_id
    } do
      %Plug.Conn{assigns: response_assigns} =
        DataReader.call(build_conn(ip_address, "/btv/life/hls/#{res_id}"), %{})

      assert %{ip_address: str_ip_address, protocol: "", resource_id: "", type: :""} ==
               response_assigns
    end

    test "Return plug assigns if request protocol is wrong", %{
      ip_address: ip_address,
      str_ip_address: str_ip_address,
      resource_id: res_id
    } do
      %Plug.Conn{assigns: response_assigns} =
        DataReader.call(build_conn(ip_address, "/btv/live/hlss/#{res_id}"), %{})

      assert %{ip_address: str_ip_address, protocol: "", resource_id: "", type: :""} ==
               response_assigns
    end

    test "Return plug assigns if request resource format is wrong", %{
      ip_address: ip_address,
      str_ip_address: str_ip_address
    } do
      %Plug.Conn{assigns: response_assigns} =
        DataReader.call(build_conn(ip_address, "/btv/live/hls/asd123!"), %{})

      assert %{ip_address: str_ip_address, protocol: "", resource_id: "", type: :""} ==
               response_assigns
    end
  end

  def build_conn(ip_address, path) do
    conn(:get, path)
    |> Map.put(:remote_ip, ip_address)
  end
end
