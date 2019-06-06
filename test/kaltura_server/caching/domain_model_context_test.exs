defmodule CtiKaltura.DomainModelContextTest do
  use CtiKaltura.MnesiaTestCase

  alias CtiKaltura.DomainModelContext
  alias CtiKaltura.DomainModelFactories.Region
  alias DomainModel.LinearChannel

  describe "#find_tv_streams" do
    setup do
      protocol = "MPD"
      wrong_protocol = "HLS"

      %{id: linear_channel_id, epg_id: epg_id} = Factory.insert(:linear_channel)

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
       epg_id: epg_id,
       wrong_protocol: wrong_protocol}
    end

    test "Return all active TvStreams with given protocol #1", %{
      tv_stream_ids: ids,
      epg_id: epg_id,
      protocol: protocol
    } do
      assert Enum.sort(ids) ==
               Enum.sort(get_ids(DomainModelContext.find_tv_streams(epg_id, protocol)))
    end

    test "Return all active TvStreams with given protocol #2", %{
      tv_stream_ids: [id1, id2],
      epg_id: epg_id,
      protocol: protocol
    } do
      Amnesia.transaction(fn -> DomainModel.TvStream.delete(id1) end)
      assert [id2] == get_ids(DomainModelContext.find_tv_streams(epg_id, protocol))
    end

    test "Return empty list if TvStream with given id and protocol does not exist", %{
      epg_id: epg_id,
      wrong_protocol: protocol
    } do
      assert [] == DomainModelContext.find_tv_streams(epg_id, protocol)
    end

    test "Return empty list if TvStream with given id and protocol inactive", %{
      inactive_id: inactive_id,
      epg_id: epg_id,
      protocol: protocol
    } do
      tv_streams = DomainModelContext.find_tv_streams(epg_id, protocol)
      refute Enum.any?(get_ids(tv_streams), fn id -> id == inactive_id end)
    end

    test "Return empty list if there is no ACTIVE streams with given epg_id", %{
      tv_stream_ids: ids,
      epg_id: epg_id,
      protocol: protocol
    } do
      Amnesia.transaction(fn ->
        Enum.each(ids, fn id -> DomainModel.TvStream.delete(id) end)
      end)

      assert [] == DomainModelContext.find_tv_streams(epg_id, protocol)
    end
  end

  describe "#find_program_records" do
    test "Return only program record if it exist" do
      protocol = "HLS"
      program_record = Factory.insert(:program_record, %{status: "COMPLETED", protocol: protocol})
      {epg_id, _, _} = program_record.complex_search_index

      assert [program_record] == DomainModelContext.find_program_records(epg_id, "hls")
    end

    test "Return several program records it they exist" do
      protocol = "HLS"
      program = Factory.insert(:program)

      program_record1 =
        Factory.insert(:program_record, %{
          program_id: program.id,
          status: "COMPLETED",
          protocol: protocol,
          encryption: "NONE"
        })

      program_record2 =
        Factory.insert(:program_record, %{
          program_id: program.id,
          status: "COMPLETED",
          protocol: protocol,
          encryption: "WIDEVINE"
        })

      result = DomainModelContext.find_program_records(program.epg_id, "hls")

      sort_by_id = fn collection -> Enum.sort_by(collection, & &1.id) end
      assert sort_by_id.(result) == sort_by_id.([program_record1, program_record2])
    end

    test "Return empty list if no mathing records" do
      protocol = "HLS"
      program_record = Factory.insert(:program_record, %{status: "COMPLETED", protocol: protocol})
      {epg_id, _, _} = program_record.complex_search_index

      assert [] == DomainModelContext.find_program_records(epg_id, "mpd")
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
               DomainModelContext.get_subnets_for_ip({147, 147, 147, 145}) |> get_ids()

      assert [^id2, ^id3] =
               DomainModelContext.get_subnets_for_ip({147, 147, 147, 150}) |> get_ids()

      assert [^id3] = DomainModelContext.get_subnets_for_ip({147, 147, 147, 180}) |> get_ids()

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
      assert [] = DomainModelContext.get_subnets_for_ip({147, 147, 124, 70}) |> get_ids()

      Amnesia.transaction(fn ->
        LinearChannel.delete(id1)
        LinearChannel.delete(id2)
        LinearChannel.delete(id3)
      end)
    end
  end

  describe "#get_subnet_appropriate_servers" do
    setup do
      %{id: linear_channel_id} = Factory.insert(:linear_channel)

      subnet_id = 777
      region_id = 777
      server_group_id = 777
      s_id1 = 777
      s_id2 = 778
      s_id3 = 779
      s_id4 = 780
      s_id5 = 781

      subnet =
        Factory.insert(:subnet, %{
          id: subnet_id,
          cidr: "123.123.123.123/29",
          region_id: region_id,
          server_ids: [s_id1, s_id2, s_id3, s_id4, s_id5]
        })

      Factory.insert(:region, %{
        id: region_id,
        subnet_ids: [subnet_id],
        server_group_ids: [server_group_id]
      })

      Factory.insert(:server, %{
        id: s_id1,
        server_group_ids: [server_group_id],
        status: "INACTIVE",
        availability: true,
        type: "EDGE",
        healthcheck_enabled: true
      })

      Factory.insert(:server, %{
        id: s_id2,
        server_group_ids: [server_group_id],
        status: "ACTIVE",
        availability: true,
        type: "EDGE",
        healthcheck_enabled: true
      })

      Factory.insert(:server, %{
        id: s_id3,
        server_group_ids: [server_group_id],
        status: "ACTIVE",
        availability: true,
        type: "EDGE",
        healthcheck_enabled: false
      })

      Factory.insert(:server, %{
        id: s_id4,
        server_group_ids: [server_group_id],
        status: "ACTIVE",
        availability: true,
        type: "EDGE",
        healthcheck_enabled: true,
        weight: 10
      })

      Factory.insert(:server, %{
        id: s_id5,
        server_group_ids: [server_group_id],
        status: "ACTIVE",
        availability: true,
        type: "EDGE",
        healthcheck_enabled: true,
        weight: 20
      })

      Factory.insert(:server_group, %{
        id: server_group_id,
        region_ids: [region_id],
        server_ids: [s_id1, s_id2, s_id3, s_id4, s_id5],
        linear_channel_ids: [linear_channel_id]
      })

      {:ok,
       subnet: subnet,
       server_group_id: server_group_id,
       server_ids: [s_id1, s_id2, s_id3, s_id4, s_id5],
       region_id: region_id}
    end

    test "Return Server if it exist", %{subnet: subnet, server_ids: server_ids} do
      assert hd(Enum.map(DomainModelContext.get_subnet_appropriate_servers(subnet), & &1.id)) in server_ids
    end

    test "Return empty list if ServerGroup inactive", %{
      subnet: subnet,
      server_group_id: server_group_id
    } do
      Amnesia.transaction(fn ->
        server_group_id
        |> DomainModel.ServerGroup.read()
        |> Map.put(:status, "INACTIVE")
        |> DomainModel.ServerGroup.write()
      end)

      assert DomainModelContext.get_subnet_appropriate_servers(subnet) == []
    end

    test "Return empty list if Region inactive", %{
      subnet: subnet,
      region_id: region_id
    } do
      Amnesia.transaction(fn ->
        region_id
        |> DomainModel.Region.read()
        |> Map.put(:status, "INACTIVE")
        |> DomainModel.Region.write()
      end)

      assert DomainModelContext.get_subnet_appropriate_servers(subnet) == []
    end

    test "Return empty list if all Servers INACTIVE", %{
      subnet: subnet,
      server_ids: server_ids
    } do
      Amnesia.transaction(fn ->
        server_ids
        |> Enum.each(fn server_id ->
          server_id
          |> DomainModel.Server.read()
          |> Map.put(:status, "INACTIVE")
          |> DomainModel.Server.write()
        end)
      end)

      assert DomainModelContext.get_subnet_appropriate_servers(subnet) == []
    end

    test "Return empty list if all Servers are unavailable", %{
      subnet: subnet,
      server_ids: server_ids
    } do
      Amnesia.transaction(fn ->
        server_ids
        |> Enum.each(fn server_id ->
          server_id
          |> DomainModel.Server.read()
          |> Map.put(:availability, false)
          |> DomainModel.Server.write()
        end)
      end)

      assert DomainModelContext.get_subnet_appropriate_servers(subnet) == []
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

  describe "#make_domain_model_table_record" do
    test "Return nil if nil is given" do
      assert is_nil(DomainModelContext.make_domain_model_table_record(nil))
    end

    test "Create new record" do
      table_name = DomainModel.Region
      id = Region.next_table_id()
      name = Faker.Lorem.word()
      status = "ACTIVE"
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
             } = DomainModelContext.make_domain_model_table_record(param_list)
    end
  end

  def get_ids(collection) do
    Enum.map(collection, & &1.id)
  end
end
