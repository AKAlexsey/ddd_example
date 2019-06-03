defmodule CtiKaltura.ProgramScheduling.SoapServersServiceTest do
  use CtiKaltura.ModelCase, async: false

  alias CtiKaltura.ProgramScheduling.SoapServersService

  describe "#query_servers param is ProgramRecord" do
    test "return right Servers" do
      {:ok, server_group} = Factory.insert(:server_group)

      {:ok, server1} =
        Factory.insert(:server, %{status: "ACTIVE", server_group_ids: [server_group.id]})

      {:ok, server2} =
        Factory.insert(:server, %{status: "ACTIVE", server_group_ids: [server_group.id]})

      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})
      {:ok, program_record} = Factory.insert(:program_record, %{program_id: program.id})

      standard = Enum.sort([server1.id, server2.id])

      result =
        Enum.map(SoapServersService.query_servers(program_record), & &1.id)
        |> Enum.sort()

      assert standard == result
    end

    test "return empty list if ProgramRecord does not have ACTIVE Servers" do
      {:ok, server_group} = Factory.insert(:server_group)
      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})
      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})
      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})
      {:ok, program_record} = Factory.insert(:program_record, %{program_id: program.id})

      assert [] == SoapServersService.query_servers(program_record)
    end

    test "return empty list if ProgramRecord's LinearChannel does not have ServerGroup" do
      {:ok, linear_channel} = Factory.insert(:linear_channel, %{dvr_enabled: false})
      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})
      {:ok, program_record} = Factory.insert(:program_record, %{program_id: program.id})

      assert [] == SoapServersService.query_servers(program_record)
    end
  end

  describe "#query_servers param is LinearChannel" do
    test "return right Servers" do
      {:ok, server_group} = Factory.insert(:server_group)

      {:ok, server1} =
        Factory.insert(:server, %{status: "ACTIVE", server_group_ids: [server_group.id]})

      {:ok, server2} =
        Factory.insert(:server, %{status: "ACTIVE", server_group_ids: [server_group.id]})

      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      standard = Enum.sort([server1.id, server2.id])

      result =
        Enum.map(SoapServersService.query_servers(linear_channel), & &1.id)
        |> Enum.sort()

      assert standard == result
    end

    test "return empty list if LinearChannel does not have ACTIVE Servers" do
      {:ok, server_group} = Factory.insert(:server_group)
      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})
      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})
      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      assert [] == SoapServersService.query_servers(linear_channel)
    end

    test "return empty list if LinearChannel does not have ServerGroup" do
      {:ok, linear_channel} = Factory.insert(:linear_channel, %{dvr_enabled: false})

      assert [] == SoapServersService.query_servers(linear_channel)
    end
  end

  describe "#query_servers param is tuple with LinearChannel" do
    test "return right Servers" do
      {:ok, server_group} = Factory.insert(:server_group)

      {:ok, server1} =
        Factory.insert(:server, %{status: "ACTIVE", server_group_ids: [server_group.id]})

      {:ok, server2} =
        Factory.insert(:server, %{status: "ACTIVE", server_group_ids: [server_group.id]})

      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})
      Factory.insert(:program_record, %{program_id: program.id})
      {:ok, tv_stream} = Factory.insert(:tv_stream, %{linear_channel_id: linear_channel.id})

      standard = Enum.sort([server1.id, server2.id])

      result =
        Enum.map(SoapServersService.query_servers({program, linear_channel, tv_stream}), & &1.id)
        |> Enum.sort()

      assert standard == result
    end

    test "return empty list if LinearChannel does not have ACTIVE Servers" do
      {:ok, server_group} = Factory.insert(:server_group)
      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})
      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})
      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})
      Factory.insert(:program_record, %{program_id: program.id})
      {:ok, tv_stream} = Factory.insert(:tv_stream, %{linear_channel_id: linear_channel.id})

      assert [] == SoapServersService.query_servers({program, linear_channel, tv_stream})
    end

    test "return empty list if LinearChannel does not have ServerGroup" do
      {:ok, linear_channel} = Factory.insert(:linear_channel, %{dvr_enabled: false})
      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})
      Factory.insert(:program_record, %{program_id: program.id})
      {:ok, tv_stream} = Factory.insert(:tv_stream, %{linear_channel_id: linear_channel.id})

      assert [] == SoapServersService.query_servers({program, linear_channel, tv_stream})
    end
  end

  describe "#query_servers getting wrong params" do
    test "return error #1" do
      {:ok, program} = Factory.insert(:program)

      assert {:error, :unknown_params_for_getting_dvr_server} ==
               SoapServersService.query_servers(program)
    end

    test "return error #2" do
      {:ok, linear_channel} = Factory.insert(:linear_channel)

      assert {:error, :unknown_params_for_getting_dvr_server} ==
               SoapServersService.query_servers({linear_channel, 1, 1})
    end

    test "return error #3" do
      {:ok, linear_channel} = Factory.insert(:linear_channel)

      assert {:error, :unknown_params_for_getting_dvr_server} ==
               SoapServersService.query_servers({1, 1, linear_channel})
    end

    test "return error #4" do
      assert {:error, :unknown_params_for_getting_dvr_server} ==
               SoapServersService.query_servers(%{})
    end
  end

  describe "#dvr_server_domain params if ProgramRecord" do
    test "return DVR server domain if it exist" do
      {:ok, server_group} = Factory.insert(:server_group)

      {:ok, %{manage_ip: manage_ip1, manage_port: manage_port1}} =
        Factory.insert(:server, %{
          status: "ACTIVE",
          type: "DVR",
          server_group_ids: [server_group.id]
        })

      {:ok, %{manage_ip: manage_ip2, manage_port: manage_port2}} =
        Factory.insert(:server, %{
          status: "ACTIVE",
          type: "DVR",
          server_group_ids: [server_group.id]
        })

      Factory.insert(:server, %{
        status: "INACTIVE",
        type: "DVR",
        server_group_ids: [server_group.id]
      })

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})
      {:ok, program_record} = Factory.insert(:program_record, %{program_id: program.id})

      standard = [
        "http://#{manage_ip1}:#{manage_port1}/cti-dvr/dvr-service",
        "http://#{manage_ip2}:#{manage_port2}/cti-dvr/dvr-service"
      ]

      result = SoapServersService.dvr_server_domain(program_record)

      assert result in standard
    end

    test "return nil if there is not ACTIVE DVR servers in group" do
      {:ok, server_group} = Factory.insert(:server_group)

      Factory.insert(:server, %{
        status: "INACTIVE",
        type: "DVR",
        server_group_ids: [server_group.id]
      })

      Factory.insert(:server, %{
        status: "INACTIVE",
        type: "DVR",
        server_group_ids: [server_group.id]
      })

      Factory.insert(:server, %{
        status: "INACTIVE",
        type: "DVR",
        server_group_ids: [server_group.id]
      })

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})
      {:ok, program_record} = Factory.insert(:program_record, %{program_id: program.id})

      result = SoapServersService.dvr_server_domain(program_record)

      assert is_nil(result)
    end
  end

  describe "#dvr_server_domain params if LinearChannel" do
    test "return DVR server domain if it exist" do
      {:ok, server_group} = Factory.insert(:server_group)

      {:ok, %{manage_ip: manage_ip1, manage_port: manage_port1}} =
        Factory.insert(:server, %{
          status: "ACTIVE",
          type: "DVR",
          server_group_ids: [server_group.id]
        })

      {:ok, %{manage_ip: manage_ip2, manage_port: manage_port2}} =
        Factory.insert(:server, %{
          status: "ACTIVE",
          type: "DVR",
          server_group_ids: [server_group.id]
        })

      Factory.insert(:server, %{
        status: "INACTIVE",
        type: "DVR",
        server_group_ids: [server_group.id]
      })

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      standard = [
        "http://#{manage_ip1}:#{manage_port1}/cti-dvr/dvr-service",
        "http://#{manage_ip2}:#{manage_port2}/cti-dvr/dvr-service"
      ]

      result = SoapServersService.dvr_server_domain(linear_channel)

      assert result in standard
    end

    test "return nil if there is not ACTIVE DVR servers in group" do
      {:ok, server_group} = Factory.insert(:server_group)

      Factory.insert(:server, %{
        status: "INACTIVE",
        type: "DVR",
        server_group_ids: [server_group.id]
      })

      Factory.insert(:server, %{
        status: "INACTIVE",
        type: "DVR",
        server_group_ids: [server_group.id]
      })

      Factory.insert(:server, %{
        status: "INACTIVE",
        type: "DVR",
        server_group_ids: [server_group.id]
      })

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      result = SoapServersService.dvr_server_domain(linear_channel)

      assert is_nil(result)
    end
  end

  describe "#dvr_server_domain params is tuple with LinearChannel" do
    test "return DVR server domain if it exist" do
      {:ok, server_group} = Factory.insert(:server_group)

      {:ok, %{manage_ip: manage_ip1, manage_port: manage_port1}} =
        Factory.insert(:server, %{
          status: "ACTIVE",
          type: "DVR",
          server_group_ids: [server_group.id]
        })

      {:ok, %{manage_ip: manage_ip2, manage_port: manage_port2}} =
        Factory.insert(:server, %{
          status: "ACTIVE",
          type: "DVR",
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

      standard = [
        "http://#{manage_ip1}:#{manage_port1}/cti-dvr/dvr-service",
        "http://#{manage_ip2}:#{manage_port2}/cti-dvr/dvr-service"
      ]

      result = SoapServersService.dvr_server_domain({program, linear_channel, tv_stream})

      assert result in standard
    end

    test "return nil if there is not ACTIVE DVR servers in group" do
      {:ok, server_group} = Factory.insert(:server_group)

      Factory.insert(:server, %{
        status: "INACTIVE",
        type: "DVR",
        server_group_ids: [server_group.id]
      })

      Factory.insert(:server, %{
        status: "INACTIVE",
        type: "DVR",
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

      result = SoapServersService.dvr_server_domain({program, linear_channel, tv_stream})

      assert is_nil(result)
    end
  end

  describe "#dvr_server_domain wrong params" do
    test "return nil #1" do
      {:ok, program} = Factory.insert(:program)

      assert is_nil(SoapServersService.dvr_server_domain(program))
    end

    test "return nil #2" do
      {:ok, linear_channel} = Factory.insert(:linear_channel)

      assert is_nil(SoapServersService.dvr_server_domain({linear_channel, 1, 1}))
    end

    test "return nil #3" do
      {:ok, linear_channel} = Factory.insert(:linear_channel)

      assert is_nil(SoapServersService.dvr_server_domain({1, 1, linear_channel}))
    end

    test "return nil #4" do
      assert is_nil(SoapServersService.dvr_server_domain(%{}))
    end
  end

  describe "#edge_server_domain params if ProgramRecord" do
    test "return DVR server domain if it exist" do
      {:ok, server_group} = Factory.insert(:server_group)

      {:ok, %{domain_name: domain_name1}} =
        Factory.insert(:server, %{status: "ACTIVE", server_group_ids: [server_group.id]})

      {:ok, %{domain_name: domain_name2}} =
        Factory.insert(:server, %{status: "ACTIVE", server_group_ids: [server_group.id]})

      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})
      {:ok, program_record} = Factory.insert(:program_record, %{program_id: program.id})

      standard = ["http://#{domain_name1}", "http://#{domain_name2}"]
      result = SoapServersService.edge_server_domain(program_record)

      assert result in standard
    end

    test "return nil if there is not ACTIVE DVR servers in group" do
      {:ok, server_group} = Factory.insert(:server_group)
      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})
      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})
      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})
      {:ok, program_record} = Factory.insert(:program_record, %{program_id: program.id})

      result = SoapServersService.edge_server_domain(program_record)

      assert is_nil(result)
    end
  end

  describe "#edge_server_domain params if LinearChannel" do
    test "return DVR server domain if it exist" do
      {:ok, server_group} = Factory.insert(:server_group)

      {:ok, %{domain_name: domain_name1}} =
        Factory.insert(:server, %{status: "ACTIVE", server_group_ids: [server_group.id]})

      {:ok, %{domain_name: domain_name2}} =
        Factory.insert(:server, %{status: "ACTIVE", server_group_ids: [server_group.id]})

      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      standard = ["http://#{domain_name1}", "http://#{domain_name2}"]
      result = SoapServersService.edge_server_domain(linear_channel)

      assert result in standard
    end

    test "return nil if there is not ACTIVE DVR servers in group" do
      {:ok, server_group} = Factory.insert(:server_group)
      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})
      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})
      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      result = SoapServersService.edge_server_domain(linear_channel)

      assert is_nil(result)
    end
  end

  describe "#edge_server_domain params is tuple with LinearChannel" do
    test "return DVR server domain if it exist" do
      {:ok, server_group} = Factory.insert(:server_group)

      {:ok, %{domain_name: domain_name1}} =
        Factory.insert(:server, %{status: "ACTIVE", server_group_ids: [server_group.id]})

      {:ok, %{domain_name: domain_name2}} =
        Factory.insert(:server, %{status: "ACTIVE", server_group_ids: [server_group.id]})

      Factory.insert(:server, %{status: "INACTIVE", server_group_ids: [server_group.id]})

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      {:ok, tv_stream} = Factory.insert(:tv_stream, %{linear_channel_id: linear_channel.id})
      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})
      Factory.insert(:program_record, %{program_id: program.id})

      standard = ["http://#{domain_name1}", "http://#{domain_name2}"]
      result = SoapServersService.edge_server_domain({program, linear_channel, tv_stream})

      assert result in standard
    end

    test "return nil if there is not ACTIVE DVR servers in group" do
      {:ok, server_group} = Factory.insert(:server_group)

      Factory.insert(:server, %{
        status: "INACTIVE",
        type: "DVR",
        server_group_ids: [server_group.id]
      })

      Factory.insert(:server, %{
        status: "INACTIVE",
        type: "DVR",
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

      result = SoapServersService.edge_server_domain({program, linear_channel, tv_stream})

      assert is_nil(result)
    end
  end

  describe "#edge_server_domain wrong params" do
    test "return nil #1" do
      {:ok, program} = Factory.insert(:program)

      assert is_nil(SoapServersService.edge_server_domain(program))
    end

    test "return nil #2" do
      {:ok, linear_channel} = Factory.insert(:linear_channel)

      assert is_nil(SoapServersService.edge_server_domain({linear_channel, 1, 1}))
    end

    test "return nil #3" do
      {:ok, linear_channel} = Factory.insert(:linear_channel)

      assert is_nil(SoapServersService.edge_server_domain({1, 1, linear_channel}))
    end

    test "return nil #4" do
      assert is_nil(SoapServersService.edge_server_domain(%{}))
    end
  end
end
