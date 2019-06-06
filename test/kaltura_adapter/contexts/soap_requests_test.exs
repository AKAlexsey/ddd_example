defmodule CtiKaltura.ProgramScheduling.SoapRequestsTest do
  use CtiKaltura.ModelCase, async: false

  alias CtiKaltura.ProgramScheduling.{DvrSoapRequestsWorker, SoapRequests, Time}

  import Mock

  describe "#get_wsdl_file" do
    setup do
      {:ok, path: "http://test.ru/dvr/dvr-server", user: "user", password: "password"}
    end

    test "status 200", %{path: path, user: user, password: password} do
      parsed_wsdl = %{field1: "value1", field2: "value2"}

      with_mocks([
        {HTTPoison, [],
         [get!: fn _, _, _ -> %HTTPoison.Response{status_code: 200, body: "response_body"} end]},
        {Soap.Wsdl, [], parse: fn _, _ -> {:ok, parsed_wsdl} end}
      ]) do
        assert {:ok, parsed_wsdl} == SoapRequests.get_wsdl_file(path, user, password)
      end
    end

    test "status 500", %{path: path, user: user, password: password} do
      with_mocks([
        {HTTPoison, [],
         [get!: fn _, _, _ -> %HTTPoison.Response{status_code: 500, body: "internal_error"} end]}
      ]) do
        assert {:error, :request_fail} == SoapRequests.get_wsdl_file(path, user, password)
      end
    end

    test "status 401", %{path: path, user: user, password: password} do
      with_mocks([
        {HTTPoison, [],
         [get!: fn _, _, _ -> %HTTPoison.Response{status_code: 401, body: "internal_error"} end]}
      ]) do
        assert {:error, :unauthorized} == SoapRequests.get_wsdl_file(path, user, password)
      end
    end

    test "status 404", %{path: path, user: user, password: password} do
      with_mocks([
        {HTTPoison, [],
         [get!: fn _, _, _ -> %HTTPoison.Response{status_code: 404, body: "internal_error"} end]}
      ]) do
        assert {:error, :not_found} == SoapRequests.get_wsdl_file(path, user, password)
      end
    end

    test "unknown status", %{path: path, user: user, password: password} do
      with_mocks([
        {HTTPoison, [],
         [get!: fn _, _, _ -> %HTTPoison.Response{status_code: 302, body: "internal_error"} end]}
      ]) do
        assert {:error, :unknown_error} == SoapRequests.get_wsdl_file(path, user, password)
      end
    end
  end

  describe "#schedule_recording" do
    test "Perform request with given params" do
      {:ok, server_group} = Factory.insert(:server_group)

      {:ok, %{domain_name: domain_name}} =
        Factory.insert(:server, %{
          status: "ACTIVE",
          type: "EDGE",
          server_group_ids: [server_group.id]
        })

      {:ok, %{manage_ip: manage_ip, manage_port: manage_port}} =
        Factory.insert(:server, %{
          status: "ACTIVE",
          type: "DVR",
          server_group_ids: [server_group.id]
        })

      {:ok, %{code_name: code_name} = linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      {:ok, %{stream_path: stream_path, protocol: protocol, encryption: encryption} = tv_stream} =
        Factory.insert(:tv_stream, %{linear_channel_id: linear_channel.id})

      {:ok,
       %{epg_id: epg_id, start_datetime: start_datetime, end_datetime: end_datetime} = program} =
        Factory.insert(:program, %{linear_channel_id: linear_channel.id})

      Factory.insert(:program_record, %{program_id: program.id})

      standard = {:ok, "viasat_history/HLS/NONE/120190529123000/index-1559100600-3600.m3u8"}

      standard_params = %{
        arg0: %{
          plannedStartTime: Time.soap_datetime(start_datetime),
          plannedEndTime: Time.soap_datetime(end_datetime),
          assetToCapture: "http://#{domain_name}#{stream_path}",
          placement: "#{code_name}/#{protocol}/#{encryption}/#{epg_id}",
          params:
            "format=#{String.downcase(protocol)};encryption=#{String.downcase(encryption)};channel=#{
              code_name
            }"
        }
      }

      standard_dvr_server_domain = "http://#{manage_ip}:#{manage_port}/cti-dvr/dvr-service"

      with_mocks([{DvrSoapRequestsWorker, [], sync_request: fn _, _, _ -> standard end}]) do
        assert standard == SoapRequests.schedule_recording({program, linear_channel, tv_stream})

        assert_called(
          DvrSoapRequestsWorker.sync_request(
            "scheduleRecording",
            standard_params,
            standard_dvr_server_domain
          )
        )
      end
    end

    test "Return error if no ACTIVE dvr Server" do
      {:ok, server_group} = Factory.insert(:server_group)

      Factory.insert(:server, %{
        status: "ACTIVE",
        type: "EDGE",
        server_group_ids: [server_group.id]
      })

      Factory.insert(:server, %{
        status: "INACTIVE",
        type: "DVR",
        server_group_ids: [server_group.id]
      })

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      {:ok, tv_stream} = Factory.insert(:tv_stream, %{linear_channel_id: linear_channel.id})

      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})

      Factory.insert(:program_record, %{program_id: program.id})

      assert {:error, :no_dvr_server} ==
               SoapRequests.schedule_recording({program, linear_channel, tv_stream})
    end

    test "Return error if Params is wrong" do
      {:ok, server_group} = Factory.insert(:server_group)

      Factory.insert(:server, %{
        status: "ACTIVE",
        type: "EDGE",
        server_group_ids: [server_group.id]
      })

      Factory.insert(:server, %{
        status: "INACTIVE",
        type: "DVR",
        server_group_ids: [server_group.id]
      })

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      {:ok, tv_stream} = Factory.insert(:tv_stream, %{linear_channel_id: linear_channel.id})

      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})

      Factory.insert(:program_record, %{program_id: program.id})

      assert {:error, :invalid_params} ==
               SoapRequests.schedule_recording({program, %{}, tv_stream})
    end
  end

  describe "#get_recording" do
    test "Perform request with given params" do
      {:ok, server_group} = Factory.insert(:server_group)

      Factory.insert(:server, %{
        status: "ACTIVE",
        type: "EDGE",
        server_group_ids: [server_group.id]
      })

      {:ok, %{manage_ip: manage_ip, manage_port: manage_port}} =
        Factory.insert(:server, %{
          status: "ACTIVE",
          type: "DVR",
          server_group_ids: [server_group.id]
        })

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      Factory.insert(:tv_stream, %{linear_channel_id: linear_channel.id})

      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})

      {:ok, %{path: path} = program_record} =
        Factory.insert(:program_record, %{program_id: program.id})

      standard = {:ok, "viasat_history/HLS/NONE/120190529123000/index-1559100600-3600.m3u8"}
      standard_params = %{arg0: path}
      standard_dvr_server_domain = "http://#{manage_ip}:#{manage_port}/cti-dvr/dvr-service"

      with_mocks([{DvrSoapRequestsWorker, [], sync_request: fn _, _, _ -> standard end}]) do
        assert standard == SoapRequests.get_recording(program_record)

        assert_called(
          DvrSoapRequestsWorker.sync_request(
            "getRecording",
            standard_params,
            standard_dvr_server_domain
          )
        )
      end
    end

    test "Return error if no ACTIVE dvr Server" do
      {:ok, server_group} = Factory.insert(:server_group)

      Factory.insert(:server, %{
        status: "ACTIVE",
        type: "EDGE",
        server_group_ids: [server_group.id]
      })

      Factory.insert(:server, %{
        status: "INACTIVE",
        type: "DVR",
        server_group_ids: [server_group.id]
      })

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      Factory.insert(:tv_stream, %{linear_channel_id: linear_channel.id})

      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})

      {:ok, program_record} = Factory.insert(:program_record, %{program_id: program.id})

      assert {:error, :no_dvr_server} == SoapRequests.get_recording(program_record)
    end

    test "Return error if Params is wrong" do
      {:ok, server_group} = Factory.insert(:server_group)

      Factory.insert(:server, %{
        status: "ACTIVE",
        type: "EDGE",
        server_group_ids: [server_group.id]
      })

      Factory.insert(:server, %{
        status: "INACTIVE",
        type: "DVR",
        server_group_ids: [server_group.id]
      })

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      Factory.insert(:tv_stream, %{linear_channel_id: linear_channel.id})

      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})

      Factory.insert(:program_record, %{program_id: program.id})

      assert {:error, :invalid_params} == SoapRequests.get_recording(program)
    end
  end

  describe "#remove_recording" do
    test "Perform request with given params" do
      {:ok, server_group} = Factory.insert(:server_group)

      Factory.insert(:server, %{
        status: "ACTIVE",
        type: "EDGE",
        server_group_ids: [server_group.id]
      })

      {:ok, %{manage_ip: manage_ip, manage_port: manage_port}} =
        Factory.insert(:server, %{
          status: "ACTIVE",
          type: "DVR",
          server_group_ids: [server_group.id]
        })

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      Factory.insert(:tv_stream, %{linear_channel_id: linear_channel.id})

      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})

      {:ok, %{path: path} = program_record} =
        Factory.insert(:program_record, %{program_id: program.id})

      standard = {:ok, "viasat_history/HLS/NONE/120190529123000/index-1559100600-3600.m3u8"}
      standard_params = %{arg0: path}
      standard_dvr_server_domain = "http://#{manage_ip}:#{manage_port}/cti-dvr/dvr-service"

      with_mocks([{DvrSoapRequestsWorker, [], async_request: fn _, _, _ -> standard end}]) do
        assert standard == SoapRequests.remove_recording(program_record)

        assert_called(
          DvrSoapRequestsWorker.async_request(
            "removeRecording",
            standard_params,
            standard_dvr_server_domain
          )
        )
      end
    end

    test "Return error if no ACTIVE dvr Server" do
      {:ok, server_group} = Factory.insert(:server_group)

      Factory.insert(:server, %{
        status: "ACTIVE",
        type: "EDGE",
        server_group_ids: [server_group.id]
      })

      Factory.insert(:server, %{
        status: "INACTIVE",
        type: "DVR",
        server_group_ids: [server_group.id]
      })

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      Factory.insert(:tv_stream, %{linear_channel_id: linear_channel.id})

      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})

      {:ok, program_record} = Factory.insert(:program_record, %{program_id: program.id})

      assert {:error, :no_dvr_server} == SoapRequests.remove_recording(program_record)
    end

    test "Return error if Params is wrong" do
      {:ok, server_group} = Factory.insert(:server_group)

      Factory.insert(:server, %{
        status: "ACTIVE",
        type: "EDGE",
        server_group_ids: [server_group.id]
      })

      Factory.insert(:server, %{
        status: "INACTIVE",
        type: "DVR",
        server_group_ids: [server_group.id]
      })

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      Factory.insert(:tv_stream, %{linear_channel_id: linear_channel.id})

      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})

      Factory.insert(:program_record, %{program_id: program.id})

      assert {:error, :invalid_params} == SoapRequests.remove_recording(program)
    end
  end

  describe "#get_params" do
    test "scheduleRecording request" do
      {:ok, server_group} = Factory.insert(:server_group)

      {:ok, %{domain_name: domain_name}} =
        Factory.insert(:server, %{status: "ACTIVE", server_group_ids: [server_group.id]})

      {:ok, %{code_name: code_name} = linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      {:ok, %{stream_path: stream_path, protocol: protocol, encryption: encryption} = tv_stream} =
        Factory.insert(:tv_stream, %{linear_channel_id: linear_channel.id})

      {:ok,
       %{epg_id: epg_id, start_datetime: start_datetime, end_datetime: end_datetime} = program} =
        Factory.insert(:program, %{linear_channel_id: linear_channel.id})

      Factory.insert(:program_record, %{program_id: program.id})

      standard =
        {:ok,
         %{
           arg0: %{
             plannedStartTime: Time.soap_datetime(start_datetime),
             plannedEndTime: Time.soap_datetime(end_datetime),
             assetToCapture: "http://#{domain_name}#{stream_path}",
             placement: "#{code_name}/#{protocol}/#{encryption}/#{epg_id}",
             params:
               "format=#{String.downcase(protocol)};encryption=#{String.downcase(encryption)};channel=#{
                 code_name
               }"
           }
         }}

      assert standard ==
               SoapRequests.get_params("scheduleRecording", {program, linear_channel, tv_stream})
    end

    test "scheduleRecording request return error if no active edge server" do
      {:ok, server_group} = Factory.insert(:server_group)

      Factory.insert(:server, %{
        type: "DVR",
        status: "ACTIVE",
        server_group_ids: [server_group.id]
      })

      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      {:ok, tv_stream} = Factory.insert(:tv_stream, %{linear_channel_id: linear_channel.id})

      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})

      Factory.insert(:program_record, %{program_id: program.id})

      assert {:error, :no_edge_server} ==
               SoapRequests.get_params("scheduleRecording", {program, linear_channel, tv_stream})
    end

    test "getRecording request" do
      {:ok, %{path: path} = program_record} = Factory.insert(:program_record)
      assert {:ok, %{arg0: path}} == SoapRequests.get_params("getRecording", program_record)
    end

    test "removeRecording request" do
      {:ok, %{path: path} = program_record} = Factory.insert(:program_record)
      assert {:ok, %{arg0: path}} == SoapRequests.get_params("removeRecording", program_record)
    end

    test "invalid params" do
      {:ok, program} = Factory.insert(:program)
      assert {:error, :invalid_params} == SoapRequests.get_params("invalidRequest", program)
    end
  end

  describe "#soap_request" do
    setup do
      config = Application.get_env(:cti_kaltura, :dvr_soap_requests)
      {:ok, wsdl} = Soap.init_model(config[:wsdl_file_path], :file)

      authorization_header = [
        Authorization:
          SoapRequests.authorization_header(config[:soap_user], config[:soap_password])
      ]

      test_function = fn operation, params ->
        {:ok, request_params} = SoapRequests.get_params(operation, params)

        SoapRequests.soap_request(
          wsdl,
          operation,
          {%{}, request_params},
          authorization_header,
          []
        )
      end

      request_mock = [
        {
          HTTPoison,
          [],
          post: fn url, body, headers, opts ->
            {
              :ok,
              %HTTPoison.Response{
                body: "",
                headers: [
                  {"Content-Type", "text/xml; charset=ISO-8859-1"},
                  {"Content-Length", "323"},
                  {"Server", "Jetty(9.1.3.v20140225)"}
                ],
                request: %HTTPoison.Request{
                  body: body,
                  headers: headers,
                  method: :post,
                  options: opts,
                  params: %{},
                  url: url
                },
                request_url: url,
                status_code: 200
              }
            }
          end
        }
      ]

      {:ok,
       request_mock: request_mock,
       authorization_header: authorization_header,
       test_function: test_function}
    end

    test "#scheduleRecording Perform request with right params and headers", %{
      request_mock: request_mock,
      authorization_header: authorization_header,
      test_function: test_function
    } do
      path = "/btv/SWM/English_club/english_club.m3u8"
      asset_to_capture = "http://edge01.beetv.kz#{path}"
      epg_id = "000001"
      code_name = "english_club"

      {:ok, server_group} = Factory.insert(:server_group)

      Factory.insert(:server, %{
        domain_name: "edge01.beetv.kz",
        type: "EDGE",
        server_group_ids: [server_group.id]
      })

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{code_name: code_name, server_group_id: server_group.id})

      {:ok, tv_stream} = Factory.insert(:tv_stream, %{stream_path: path})

      {:ok, %{start_datetime: start_datetime, end_datetime: end_datetime} = program} =
        Factory.insert(:program, %{epg_id: epg_id})

      placement = "#{code_name}/#{tv_stream.protocol}/#{tv_stream.encryption}/#{epg_id}"

      with_mocks(request_mock) do
        body_standard =
          ~s(<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tns=\"http://ws.api.dvr.cti.ru\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><env:Header/><env:Body><tns:scheduleRecording><arg0><assetToCapture>#{
            asset_to_capture
          }</assetToCapture><params>format=hls;encryption=none;channel=english_club</params><placement>#{
            placement
          }</placement><plannedEndTime>#{Time.soap_datetime(end_datetime)}</plannedEndTime><plannedStartTime>#{
            Time.soap_datetime(start_datetime)
          }</plannedStartTime></arg0></tns:scheduleRecording></env:Body></env:Envelope>)

        {:ok, response} =
          test_function.("scheduleRecording", {program, linear_channel, tv_stream})

        response_request = Map.get(response, :request)

        assert Map.get(response_request, :body) == body_standard
        assert Map.get(response_request, :headers) == authorization_header
      end
    end

    test "#getRecording Perform request with right params and headers", %{
      request_mock: request_mock,
      authorization_header: authorization_header,
      test_function: test_function
    } do
      captured_asset = "/asdfasdf/asdfsadf/sdfsdf.m8p3"
      {:ok, program_record} = Factory.insert(:program_record, %{path: captured_asset})

      with_mocks(request_mock) do
        body_standard =
          ~s(<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tns=\"http://ws.api.dvr.cti.ru\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><env:Header/><env:Body><tns:getRecording><arg0>#{
            captured_asset
          }</arg0></tns:getRecording></env:Body></env:Envelope>)

        {:ok, response} = test_function.("getRecording", program_record)
        response_request = Map.get(response, :request)

        assert Map.get(response_request, :body) == body_standard
        assert Map.get(response_request, :headers) == authorization_header
      end
    end

    test "#removeRecording Preform request with right params and headers", %{
      request_mock: request_mock,
      authorization_header: authorization_header,
      test_function: test_function
    } do
      captured_asset = "/asdfasdf/asdfsadf/sdfsdf.m8p3"
      {:ok, program_record} = Factory.insert(:program_record, %{path: captured_asset})

      with_mocks(request_mock) do
        body_standard =
          ~s(<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tns=\"http://ws.api.dvr.cti.ru\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><env:Header/><env:Body><tns:removeRecording><arg0>#{
            captured_asset
          }</arg0></tns:removeRecording></env:Body></env:Envelope>)

        {:ok, response} = test_function.("removeRecording", program_record)
        response_request = Map.get(response, :request)

        assert Map.get(response_request, :body) == body_standard
        assert Map.get(response_request, :headers) == authorization_header
      end
    end
  end

  test "#authorization_header" do
    user = "Admin"
    password = "qweasd123"
    standard = "Basic #{Base.encode64("#{user}:#{password}")}"
    assert standard == SoapRequests.authorization_header(user, password)

    user = "Cowex"
    password = "Cowex"
    standard = "Basic #{Base.encode64("#{user}:#{password}")}"
    assert standard == SoapRequests.authorization_header(user, password)

    user = "Measurement"
    password = "Measurement123"
    standard = "Basic #{Base.encode64("#{user}:#{password}")}"
    assert standard == SoapRequests.authorization_header(user, password)

    user = "123123123"
    password = "r2d2"
    standard = "Basic #{Base.encode64("#{user}:#{password}")}"
    assert standard == SoapRequests.authorization_header(user, password)
  end

  describe "#parse_response" do
    test "Parse success response" do
      response = %HTTPoison.Response{
        body:
          "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><ns2:scheduleRecordingResponse xmlns:ns2=\"http://ws.api.dvr.cti.ru\"><return>viasat_history/HLS/NONE/120190529123000/index-1559100600-3600.m3u8</return></ns2:scheduleRecordingResponse></soap:Body></soap:Envelope>",
        headers: [
          {"Content-Type", "text/xml; charset=ISO-8859-1"},
          {"Content-Length", "292"},
          {"Server", "Jetty(9.1.3.v20140225)"}
        ],
        request: %HTTPoison.Request{
          body:
            "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tns=\"http://ws.api.dvr.cti.ru\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><env:Header/><env:Body><tns:scheduleRecording><arg0><assetToCapture>http://edge01.beetv.kz/btv/SWM/ViasatHistory/ViasatHistory.m3u8</assetToCapture><params>format=hls;encryption=none;channel=viasat_history</params><placement>viasat_history/HLS/NONE/120190529123000</placement><plannedEndTime>2019-05-29T10:30:00</plannedEndTime><plannedStartTime>2019-05-29T09:30:00</plannedStartTime></arg0></tns:scheduleRecording></env:Body></env:Envelope>",
          headers: [Authorization: "Basic dXNlcmN0aTpwYXNzY3Rp"],
          method: :post,
          options: [],
          params: %{},
          url: "http://10.15.6.158:8085/cti-dvr/dvr-service"
        },
        request_url: "http://10.15.6.158:8085/cti-dvr/dvr-service",
        status_code: 200
      }

      standard = {:ok, "viasat_history/HLS/NONE/120190529123000/index-1559100600-3600.m3u8"}

      assert standard == SoapRequests.parse_response(response)
    end

    test "Parse error response" do
      response = %HTTPoison.Response{
        body:
          "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><soap:Fault><faultcode>soap:Server</faultcode><faultstring>Asset /btv/live hasn't found on dvr server</faultstring><detail><ns1:DvrAssetNotFoundException xmlns:ns1=\"http://ws.api.dvr.cti.ru\"/></detail></soap:Fault></soap:Body></soap:Envelope>",
        headers: [
          {"Content-Type", "text/xml; charset=ISO-8859-1"},
          {"Content-Length", "323"},
          {"Server", "Jetty(9.1.3.v20140225)"}
        ],
        request: %HTTPoison.Request{
          body:
            "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tns=\"http://ws.api.dvr.cti.ru\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><env:Header/><env:Body><tns:getRecording><arg0>/btv/live</arg0></tns:getRecording></env:Body></env:Envelope>",
          headers: [Authorization: "Basic dXNlcmN0aTpwYXNzY3Rp"],
          method: :post,
          options: [],
          params: %{},
          url: "http://10.15.6.158:8085/cti-dvr/dvr-service"
        },
        request_url: "http://10.15.6.158:8085/cti-dvr/dvr-service",
        status_code: 500
      }

      standard =
        {:error,
         %{
           detail: %{"ns1:DvrAssetNotFoundException": %{}},
           faultcode: "soap:Server",
           faultstring: "Asset /btv/live hasn't found on dvr server"
         }}

      assert standard == SoapRequests.parse_response(response)
    end
  end
end
