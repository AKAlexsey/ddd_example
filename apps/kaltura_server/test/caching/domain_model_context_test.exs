defmodule KalturaServer.DomainModelContextTest do
  use KalturaServer.TestCase

  alias KalturaServer.DomainModelContext
  alias DomainModel.LinearChannel
  alias KalturaServer.DomainModelFactories.Region

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

  describe "#get_appropriate_servers #2 return empty list if appropriate data is missing" do
    test "Return [] if empty list passed as argument" do
      assert [] == DomainModelContext.get_appropriate_servers([])
    end

    test "Return ACTIVE, EDGE severs with healthcheck_enabled: true" do
      %{id: s1_id} =
        Factory.insert(:server, %{
          status: "INACTIVE",
          type: "EDGE",
          healthcheck_enabled: true
        })

      %{id: s2_id} =
        Factory.insert(:server, %{
          status: "ACTIVE",
          type: "DVR",
          healthcheck_enabled: true
        })

      %{id: s3_id} =
        Factory.insert(:server, %{
          status: "ACTIVE",
          type: "EDGE",
          healthcheck_enabled: false
        })

      %{id: s4_id} =
        appropriate_server =
        Factory.insert(:server, %{
          status: "ACTIVE",
          type: "EDGE",
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
