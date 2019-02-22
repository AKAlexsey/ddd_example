defmodule KalturaServer.DomainModelContextTest do
  use KalturaServer.TestCase

  alias KalturaServer.DomainModelContext
  alias DomainModel.LinearChannel
  alias KalturaServer.DomainModelFactories.Region

  describe "#find_linear_channel" do
    setup do
      %{id: id, epg_id: epg_id} = linear_channel = Factory.insert(:linear_channel)

      {:ok, id: id, epg_id: epg_id, linear_channel: linear_channel}
    end

    test "Return LinearChannel if it exist", %{
      epg_id: epg_id,
      linear_channel: linear_channel
    } do
      assert linear_channel == DomainModelContext.find_linear_channel(epg_id)
    end

    test "Return nil if LinearChannel with given epg_id not exist", %{
      id: id,
      epg_id: epg_id
    } do
      Amnesia.transaction(fn -> DomainModel.LinearChannel.delete(id) end)
      assert is_nil(DomainModelContext.find_linear_channel(epg_id))
    end
  end

  describe "#find_tv_streams" do
    setup do
      protocol = "MPD"
      wrong_protocol = "HLS"

      %{id: linear_channel_id} = Factory.insert(:linear_channel)

      %{id: id1} =
        Factory.insert(:tv_stream, %{
          protocol: protocol,
          status: "ACTIVE",
          encryption: "NONE",
          linear_channel_id: linear_channel_id
        })

      %{id: inactive_id} =
        Factory.insert(:tv_stream, %{
          protocol: protocol,
          status: "INACTIVE",
          encryption: "NONE",
          linear_channel_id: linear_channel_id
        })

      %{id: id2} =
        Factory.insert(:tv_stream, %{
          protocol: protocol,
          status: "ACTIVE",
          encryption: "WIDEVINE",
          linear_channel_id: linear_channel_id
        })

      {:ok,
       tv_stream_ids: [id1, id2],
       inactive_id: inactive_id,
       protocol: protocol,
       wrong_protocol: wrong_protocol}
    end

    test "Return all active TvStreams with given protocol #1", %{
      tv_stream_ids: ids,
      protocol: protocol
    } do
      assert Enum.sort(ids) ==
               Enum.sort(get_ids(DomainModelContext.find_tv_streams(ids, protocol)))
    end

    test "Return all active TvStreams with given protocol #2", %{
      tv_stream_ids: [id1, id2],
      protocol: protocol
    } do
      Amnesia.transaction(fn -> DomainModel.TvStream.delete(id1) end)
      assert [id2] == get_ids(DomainModelContext.find_tv_streams([id1, id2], protocol))
    end

    test "Return empty list if TvStream with given id and protocol does not exist", %{
      tv_stream_ids: ids,
      wrong_protocol: protocol
    } do
      assert [] == DomainModelContext.find_tv_streams(ids, protocol)
    end

    test "Return empty list if TvStream with given id and protocol inactive", %{
      inactive_id: inactive_id,
      protocol: protocol
    } do
      assert [] == DomainModelContext.find_tv_streams([inactive_id], protocol)
    end

    test "Return empty list if TvStream with given ids does not exist", %{
      tv_stream_ids: ids,
      protocol: protocol
    } do
      Amnesia.transaction(fn ->
        Enum.each(ids, fn id -> DomainModel.TvStream.delete(id) end)
      end)

      assert [] == DomainModelContext.find_tv_streams(ids, protocol)
    end
  end

  describe "#normalize_enum" do
    test "Return UPCASEBINARY if given is :atom" do
      assert "ACTIVE" == DomainModelContext.normalize_enum(:active)
    end

    test "Return UPCASEBINARY if given is \"binary\"" do
      assert "ACTIVE" == DomainModelContext.normalize_enum("active")
    end

    test "Return UPCASEBINARY if given is \"bInaRy\"" do
      assert "ACTIVE" == DomainModelContext.normalize_enum("aCtiVe")
    end

    test "Raise error if given argument is number" do
      assert_raise(FunctionClauseError, fn ->
        DomainModelContext.normalize_enum(4)
      end)
    end
  end

  describe "#find_program" do
    test "Return Program if it exist" do
      program = Factory.insert(:program)
      assert program == DomainModelContext.find_program(program.epg_id)
    end

    test "Return nil if program does not exist" do
      assert is_nil(DomainModelContext.find_program("p_epg_123412341234"))
    end
  end

  describe "#find_program_record" do
    test "Return ProgramRecord if it exist" do
      %{id: program_id} = Factory.insert(:program)
      program_record = Factory.insert(:program_record, %{program_id: program_id, protocol: :MPD})
      assert program_record == DomainModelContext.find_program_record(program_id, :MPD)
    end

    test "Return nil if ProgramRecord with given protocol does not exist" do
      %{id: program_id} = Factory.insert(:program)
      Factory.insert(:program_record, %{program_id: program_id, protocol: :MPD})
      assert is_nil(DomainModelContext.find_program_record(program_id, :HLS))
    end

    test "Return nil if ProgramRecord for given Program does not exist" do
      %{id: program_id} = Factory.insert(:program)
      assert is_nil(DomainModelContext.find_program_record(program_id, :HLS))
    end
  end

  describe "#find_dvr_server" do
    test "Return Server if it exist and have appropriate rights" do
      server = Factory.insert(:server, %{type: :dvr, state: :active})
      assert server == DomainModelContext.find_dvr_server(server.id)
    end

    test "Return nil if Server is not DVR" do
      %{id: server_id} = Factory.insert(:server, %{type: :edge, status: :active})
      assert is_nil(DomainModelContext.find_dvr_server(server_id))
    end

    test "Return nil if Server is not Active" do
      %{id: server_id} = Factory.insert(:server, %{type: :dvr, status: :inactive})
      assert is_nil(DomainModelContext.find_dvr_server(server_id))
    end

    test "Return nil if Server does not exist" do
      assert is_nil(DomainModelContext.find_dvr_server(-1))
    end
  end

  describe "#get_subnets_for_ip" do
    setup do
      cidr1 = "147.147.147.147/30"
      cidr2 = "147.147.147.144/28"
      cidr3 = "147.147.147.130/26"

      [%{id: id1}, %{id: id2}, %{id: id3}] =
        [%{cidr: cidr1}, %{cidr: cidr2}, %{cidr: cidr3}]
        |> Enum.map(fn attrs -> Factory.insert(:subnet, attrs) end)

      {:ok, id1: id1, id2: id2, id3: id3}
    end

    test "Return appropriate subnets if ip matches. Order from most accurate to least", %{
      id1: id1,
      id2: id2,
      id3: id3
    } do
      assert [^id1, ^id2, ^id3] =
               DomainModelContext.get_subnets_for_ip("147.147.147.145") |> get_ids()

      assert [^id2, ^id3] = DomainModelContext.get_subnets_for_ip("147.147.147.150") |> get_ids()

      assert [^id3] = DomainModelContext.get_subnets_for_ip("147.147.147.180") |> get_ids()

      Amnesia.transaction(fn ->
        LinearChannel.delete(id1)
        LinearChannel.delete(id2)
        LinearChannel.delete(id3)
      end)
    end

    test "Return empty string if ip address does not match any subnet", %{
      id1: id1,
      id2: id2,
      id3: id3
    } do
      assert [] = DomainModelContext.get_subnets_for_ip("147.147.124.70") |> get_ids()

      Amnesia.transaction(fn ->
        LinearChannel.delete(id1)
        LinearChannel.delete(id2)
        LinearChannel.delete(id3)
      end)
    end
  end

  describe "#get_subnet_region" do
    setup do
      region = Factory.insert(:region)
      subnet = Factory.insert(:subnet, %{region_id: region.id})

      {:ok, subnet: subnet, region: region}
    end

    test "Return subnet region", %{subnet: subnet, region: region} do
      assert region == DomainModelContext.get_subnet_region(subnet)
    end
  end

  describe "#get_appropriate_server_group_ids #1 check best server choosing" do
    setup do
      server_group1_id = 1
      server_group2_id = 2
      server_group3_id = 3

      region1_id = 1
      region2_id = 2
      region3_id = 3

      %{id: server1_id} =
        Factory.insert(:server, %{
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          server_group_ids: [server_group1_id]
        })

      %{id: server2_id} =
        Factory.insert(:server, %{
          status: :active,
          type: :dvr,
          healthcheck_enabled: true,
          server_group_ids: [server_group1_id, server_group3_id]
        })

      %{id: server3_id} =
        Factory.insert(:server, %{
          status: :active,
          type: :edge,
          healthcheck_enabled: false,
          server_group_ids: [server_group1_id, server_group3_id]
        })

      %{id: server4_id} =
        Factory.insert(:server, %{
          status: :inactive,
          type: :edge,
          healthcheck_enabled: true,
          server_group_ids: [server_group1_id, server_group2_id, server_group3_id]
        })

      %{id: server5_id} =
        Factory.insert(:server, %{
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          server_group_ids: [server_group1_id, server_group2_id]
        })

      %{id: linear_channel_id} = Factory.insert(:linear_channel)

      Factory.insert(:server_group, %{
        id: server_group1_id,
        server_ids: [server1_id, server2_id, server3_id, server4_id, server5_id],
        region_ids: [region1_id],
        linear_channel_ids: [linear_channel_id]
      })

      Factory.insert(:server_group, %{
        id: server_group2_id,
        server_ids: [server4_id, server5_id],
        region_ids: [region2_id, region3_id],
        linear_channel_ids: [linear_channel_id]
      })

      Factory.insert(:server_group, %{
        id: server_group3_id,
        server_ids: [server2_id, server3_id, server4_id],
        region_ids: [region3_id]
      })

      region1 = Factory.insert(:region, %{id: region1_id, server_group_ids: [server_group1_id]})
      region2 = Factory.insert(:region, %{id: region2_id, server_group_ids: [server_group2_id]})
      region3 = Factory.insert(:region, %{id: region3_id, server_group_ids: [server_group3_id]})

      {:ok,
       linear_channel_id: linear_channel_id,
       region1_server_ids: [server1_id, server2_id, server3_id, server4_id, server5_id],
       region2_server_ids: [server4_id, server5_id],
       region1: region1,
       region2: region2,
       region3: region3}
    end

    test "Return appropriate server_ids #1", %{
      linear_channel_id: linear_channel_id,
      region1_server_ids: server_ids,
      region1: region
    } do
      assert server_ids ==
               DomainModelContext.get_appropriate_server_group_ids(region, linear_channel_id)
    end

    test "Return appropriate server_ids #2 return only server_groups those references to LinearChannels",
         %{
           linear_channel_id: linear_channel_id,
           region2_server_ids: server_ids,
           region2: region
         } do
      assert server_ids ==
               DomainModelContext.get_appropriate_server_group_ids(region, linear_channel_id)
    end

    test "Return appropriate server_ids #3 return [] if no linked to LinearChannel ServerGroups",
         %{
           linear_channel_id: linear_channel_id,
           region3: region
         } do
      assert [] == DomainModelContext.get_appropriate_server_group_ids(region, linear_channel_id)
    end

    test "Return empty list if region does not have valid servers", %{
      linear_channel_id: linear_channel_id,
      region3: region
    } do
      assert [] == DomainModelContext.get_appropriate_server_group_ids(region, linear_channel_id)
    end
  end

  describe "#get_appropriate_server_group_ids #2 return empty list if appropriate data is missing" do
    setup do
      %{id: linear_channel_id} = Factory.insert(:linear_channel)

      {:ok, linear_channel_id: linear_channel_id}
    end

    test "Return [] if Region does not have ServerGroups", %{linear_channel_id: linear_channel_id} do
      region = Factory.insert(:region)

      assert [] == DomainModelContext.get_appropriate_server_group_ids(region, linear_channel_id)
    end

    test "Return [] if Region does not have Servers", %{linear_channel_id: linear_channel_id} do
      server_group_id = 777

      region =
        Factory.insert(:region, %{
          subnet_ids: [],
          server_group_id: [server_group_id]
        })

      Factory.insert(:server_group, %{id: server_group_id, region_ids: [region.id]})

      assert [] == DomainModelContext.get_appropriate_server_group_ids(region, linear_channel_id)
    end

    test "Return [] if Region does not have valid Servers", %{
      linear_channel_id: linear_channel_id
    } do
      server_group_id = 777

      region =
        Factory.insert(:region, %{
          subnet_ids: [],
          server_group_id: [server_group_id]
        })

      %{id: s1_id} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :inactive,
          type: :edge,
          healthcheck_enabled: true
        })

      %{id: s2_id} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :dvr,
          healthcheck_enabled: true
        })

      %{id: s3_id} =
        Factory.insert(:server, %{
          server_group_ids: [server_group_id],
          status: :active,
          type: :edge,
          healthcheck_enabled: false
        })

      Factory.insert(:server_group, %{
        id: server_group_id,
        region_ids: [region.id],
        server_ids: [s1_id, s2_id, s3_id]
      })

      assert [] == DomainModelContext.get_appropriate_server_group_ids(region, linear_channel_id)
    end
  end

  describe "#get_region_server_ids #1 check best server choosing" do
    setup do
      server_group1_id = 1
      server_group2_id = 2
      server_group3_id = 3

      region1_id = 1
      region2_id = 2
      region3_id = 3

      %{id: server1_id} =
        Factory.insert(:server, %{
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          server_group_ids: [server_group1_id]
        })

      %{id: server2_id} =
        Factory.insert(:server, %{
          status: :active,
          type: :dvr,
          healthcheck_enabled: true,
          server_group_ids: [server_group1_id, server_group3_id]
        })

      %{id: server3_id} =
        Factory.insert(:server, %{
          status: :active,
          type: :edge,
          healthcheck_enabled: false,
          server_group_ids: [server_group1_id, server_group3_id]
        })

      %{id: server4_id} =
        Factory.insert(:server, %{
          status: :inactive,
          type: :edge,
          healthcheck_enabled: true,
          server_group_ids: [server_group1_id, server_group2_id, server_group3_id]
        })

      %{id: server5_id} =
        Factory.insert(:server, %{
          status: :active,
          type: :edge,
          healthcheck_enabled: true,
          server_group_ids: [server_group1_id, server_group2_id]
        })

      Factory.insert(:server_group, %{
        id: server_group1_id,
        server_ids: [server1_id, server2_id, server3_id, server4_id, server5_id],
        region_ids: [region1_id]
      })

      Factory.insert(:server_group, %{
        id: server_group2_id,
        server_ids: [server4_id, server5_id],
        region_ids: [region2_id, region3_id]
      })

      Factory.insert(:server_group, %{
        id: server_group3_id,
        region_ids: [region3_id]
      })

      region1 = Factory.insert(:region, %{id: region1_id, server_group_ids: [server_group1_id]})
      region2 = Factory.insert(:region, %{id: region2_id, server_group_ids: [server_group2_id]})
      region3 = Factory.insert(:region, %{id: region3_id, server_group_ids: [server_group3_id]})

      {:ok,
       region1_server_ids: [server1_id, server2_id, server3_id, server4_id, server5_id],
       region2_server_ids: [server4_id, server5_id],
       region1: region1,
       region2: region2,
       region3: region3}
    end

    test "Return appropriate server_ids #1", %{
      region1_server_ids: server_ids,
      region1: region
    } do
      assert server_ids == DomainModelContext.get_region_server_ids(region)
    end

    test "Return appropriate server_ids #2", %{
      region2_server_ids: server_ids,
      region2: region
    } do
      assert server_ids == DomainModelContext.get_region_server_ids(region)
    end

    test "Return [] if region does not have servers", %{
      region3: region
    } do
      assert [] == DomainModelContext.get_region_server_ids(region)
    end
  end

  describe "#get_appropriate_servers #2 return empty list if appropriate data is missing" do
    test "Return [] if empty list passed as argument" do
      assert [] == DomainModelContext.get_appropriate_servers([])
    end

    test "Return :actvie, :edge severs with healthcheck_enabled: true" do
      %{id: s1_id} =
        Factory.insert(:server, %{
          status: :inactive,
          type: :edge,
          healthcheck_enabled: true
        })

      %{id: s2_id} =
        Factory.insert(:server, %{
          status: :active,
          type: :dvr,
          healthcheck_enabled: true
        })

      %{id: s3_id} =
        Factory.insert(:server, %{
          status: :active,
          type: :edge,
          healthcheck_enabled: false
        })

      %{id: s4_id} =
        appropriate_server =
        Factory.insert(:server, %{
          status: :active,
          type: :edge,
          healthcheck_enabled: true
        })

      assert [appropriate_server] ==
               DomainModelContext.get_appropriate_servers([s1_id, s2_id, s3_id, s4_id])
    end
  end

  describe "#make_in_mnesia_clause" do
    setup do: {:ok, variable_name: :"$1"}

    test "Values list is empty", %{variable_name: name} do
      assert is_nil(DomainModelContext.make_in_mnesia_clause([], name))
    end

    test "Values list is one element long", %{variable_name: name} do
      assert {:==, name, 1} == DomainModelContext.make_in_mnesia_clause([1], name)
    end

    test "Values list length is more than 1", %{variable_name: name} do
      assert {:orelse, {:==, name, 2}, {:==, name, 1}} ==
               DomainModelContext.make_in_mnesia_clause([1, 2], name)

      assert {:orelse, {:==, name, 3}, {:orelse, {:==, name, 2}, {:==, name, 1}}} ==
               DomainModelContext.make_in_mnesia_clause([1, 2, 3], name)
    end
  end

  describe "#make_and_mnesia_clause" do
    test "Values list is empty" do
      assert is_nil(DomainModelContext.make_and_mnesia_clause([]))
    end

    test "Values list is one element long" do
      assert {:==, :"$1", 1} == DomainModelContext.make_and_mnesia_clause([{:==, :"$1", 1}])
    end

    test "Values list length is more than 1" do
      assert {:andalso, {:==, :"$1", 1}, {:==, :"$2", 2}} ==
               DomainModelContext.make_and_mnesia_clause([{:==, :"$1", 1}, {:==, :"$2", 2}])

      assert {:andalso, {:andalso, {:==, :"$1", 1}, {:==, :"$2", 2}}, {:==, :"$3", 3}} ==
               DomainModelContext.make_and_mnesia_clause([
                 {:==, :"$1", 1},
                 {:==, :"$2", 2},
                 {:==, :"$3", 3}
               ])
    end
  end

  describe "#make_domain_model_table_result" do
    test "Return nil if nil is given" do
      assert is_nil(DomainModelContext.make_domain_model_table_result(nil))
    end

    test "Create new record" do
      table_name = DomainModel.Region
      id = Region.next_table_id()
      name = Faker.Lorem.word()
      status = :active
      subnet_ids = []
      server_group_ids = []

      param_list = [table_name, id, name, status, subnet_ids, server_group_ids]

      assert %{
               __struct__: ^table_name,
               id: ^id,
               name: ^name,
               status: ^status,
               subnet_ids: ^subnet_ids,
               server_group_ids: ^server_group_ids
             } = DomainModelContext.make_domain_model_table_result(param_list)
    end
  end

  def get_ids(collection) do
    Enum.map(collection, & &1.id)
  end
end
