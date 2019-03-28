defmodule CtiKaltura.ContentTest do
  use CtiKaltura.DataCase

  alias CtiKaltura.Content
  alias CtiKaltura.Servers.ServerGroup
  import Mock
  @domain_model_handler_module Application.get_env(:cti_kaltura, :domain_model_handler)

  describe "linear_channels" do
    alias CtiKaltura.Content.LinearChannel

    @valid_attrs %{
      code_name: "some code_name",
      description: "some description",
      dvr_enabled: false,
      epg_id: "some epg_id",
      name: "some name"
    }
    @update_attrs %{
      code_name: "some updated code_name",
      description: "some updated description",
      dvr_enabled: true,
      epg_id: "some updated epg_id",
      name: "some updated name"
    }
    @invalid_attrs %{
      code_name: nil,
      description: nil,
      dvr_enabled: nil,
      epg_id: nil,
      name: nil
    }

    def linear_channel_fixture(attrs \\ %{}) do
      {:ok, linear_channel} = Factory.insert(:linear_channel, Enum.into(attrs, @valid_attrs))

      linear_channel
    end

    test "list_linear_channels/0 returns all linear_channels" do
      linear_channel = linear_channel_fixture()
      assert Enum.map(Content.list_linear_channels(), & &1.id) == [linear_channel.id]
    end

    test "get_linear_channel!/1 returns the linear_channel with given id" do
      linear_channel = linear_channel_fixture()
      assert Content.get_linear_channel!(linear_channel.id).id == linear_channel.id
    end

    test "create_linear_channel/1 with valid data creates a linear_channel" do
      with_mock @domain_model_handler_module, handle: fn :insert, %{} -> :ok end do
        {:ok, %ServerGroup{id: server_group_id}} = Factory.insert(:server_group)

        create_attrs =
          Map.merge(@valid_attrs, %{server_group_id: server_group_id, dvr_enabled: true})

        assert {:ok, %LinearChannel{} = linear_channel} =
                 Content.create_linear_channel(create_attrs)

        assert linear_channel.code_name == "some code_name"
        assert linear_channel.description == "some description"
        assert linear_channel.dvr_enabled == true
        assert linear_channel.epg_id == "some epg_id"
        assert linear_channel.name == "some name"
        assert linear_channel.server_group_id == server_group_id

        assert_called(
          @domain_model_handler_module.handle(:insert, %{model_name: "LinearChannel"})
        )
      end
    end

    test "create_linear_channel/1 validate server_group_id if dvr_enabled = true" do
      attrs_without_server_group_id = Map.put(@valid_attrs, :dvr_enabled, true)

      assert {:error, changeset} = Content.create_linear_channel(attrs_without_server_group_id)
      assert changeset.errors == [server_group_id: {"can't be blank", [validation: :required]}]
    end

    test "create_linear_channel/1 does not validate server_group_id if dvr_enabled = false" do
      with_mock @domain_model_handler_module, handle: fn :insert, %{} -> :ok end do
        assert {:ok, %LinearChannel{} = linear_channel} =
                 Content.create_linear_channel(@valid_attrs)

        assert linear_channel.code_name == "some code_name"
        assert linear_channel.description == "some description"
        assert linear_channel.dvr_enabled == false
        assert linear_channel.epg_id == "some epg_id"
        assert linear_channel.name == "some name"
        assert is_nil(linear_channel.server_group_id)

        assert_called(
          @domain_model_handler_module.handle(:insert, %{model_name: "LinearChannel"})
        )
      end
    end

    test "create_linear_channel/1 validate name uniques" do
      {:ok, linear_channel} = Content.create_linear_channel(@valid_attrs)

      duplicate_attrs =
        Map.merge(@valid_attrs, %{
          name: linear_channel.name,
          code_name: Faker.Lorem.word(),
          epg_id: "#{Faker.Lorem.word()}_#{:rand.uniform(100)}"
        })

      {:error, %{errors: errors}} = Content.create_linear_channel(duplicate_attrs)

      assert errors == [
               name:
                 {"has already been taken",
                  [constraint: :unique, constraint_name: "linear_channels_name_index"]}
             ]
    end

    test "create_linear_channel/1 validate code_name" do
      {:ok, linear_channel} = Content.create_linear_channel(@valid_attrs)

      duplicate_attrs =
        Map.merge(@valid_attrs, %{
          name: Faker.Lorem.word(),
          code_name: linear_channel.code_name,
          epg_id: "#{Faker.Lorem.word()}_#{:rand.uniform(100)}"
        })

      {:error, %{errors: errors}} = Content.create_linear_channel(duplicate_attrs)

      assert errors == [
               code_name:
                 {"has already been taken",
                  [constraint: :unique, constraint_name: "linear_channels_code_name_index"]}
             ]
    end

    test "create_linear_channel/1 validate epg_id is unique" do
      {:ok, linear_channel} = Content.create_linear_channel(@valid_attrs)

      duplicate_attrs =
        Map.merge(@valid_attrs, %{
          name: Faker.Lorem.word(),
          code_name: "#{Faker.Lorem.word()}_#{:rand.uniform(100)}",
          epg_id: linear_channel.epg_id
        })

      {:error, %{errors: errors}} = Content.create_linear_channel(duplicate_attrs)

      assert errors == [
               epg_id:
                 {"has already been taken",
                  [constraint: :unique, constraint_name: "linear_channels_epg_id_index"]}
             ]
    end

    test "create_linear_channel/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_linear_channel(@invalid_attrs)
    end

    test "update_linear_channel/2 with valid data updates the linear_channel #1" do
      with_mock @domain_model_handler_module, handle: fn :update, %{} -> :ok end do
        {:ok, server_group} = Factory.insert(:server_group)
        linear_channel = linear_channel_fixture()
        update_attrs = Map.put(@update_attrs, :server_group_id, server_group.id)

        assert {:ok, %LinearChannel{} = linear_channel} =
                 Content.update_linear_channel(linear_channel, update_attrs)

        assert linear_channel.code_name == "some updated code_name"
        assert linear_channel.description == "some updated description"
        assert linear_channel.dvr_enabled == true
        assert linear_channel.epg_id == "some updated epg_id"
        assert linear_channel.name == "some updated name"
        assert linear_channel.server_group_id == server_group.id

        assert_called(
          @domain_model_handler_module.handle(:update, %{model_name: "LinearChannel"})
        )
      end
    end

    test "update_linear_channel/2 with valid data updates the linear_channel #2" do
      with_mock @domain_model_handler_module, handle: fn :update, %{} -> :ok end do
        linear_channel = linear_channel_fixture()
        update_attrs = Map.put(@update_attrs, :dvr_enabled, false)

        assert {:ok, %LinearChannel{} = linear_channel} =
                 Content.update_linear_channel(linear_channel, update_attrs)

        assert linear_channel.code_name == "some updated code_name"
        assert linear_channel.description == "some updated description"
        assert linear_channel.dvr_enabled == false
        assert linear_channel.epg_id == "some updated epg_id"
        assert linear_channel.name == "some updated name"
        assert is_nil(linear_channel.server_group_id)

        assert_called(
          @domain_model_handler_module.handle(:update, %{model_name: "LinearChannel"})
        )
      end
    end

    test "udpate_linear_channel/1 validate name is unique" do
      {:ok, linear_channel} = Content.create_linear_channel(@valid_attrs)

      valid_attrs_2 =
        Map.merge(@valid_attrs, %{
          code_name: Faker.Lorem.word(),
          epg_id: "#{Faker.Lorem.word()}_#{:rand.uniform(100)}",
          name: "#{Faker.Lorem.word()}"
        })

      {:ok, linear_channel_2} = Content.create_linear_channel(valid_attrs_2)

      {:error, %{errors: errors}} =
        Content.update_linear_channel(linear_channel_2, %{:code_name => linear_channel.code_name})

      assert errors == [
               code_name:
                 {"has already been taken",
                  [constraint: :unique, constraint_name: "linear_channels_code_name_index"]}
             ]
    end

    test "udpate_linear_channel/1 validate code_name is unique" do
      {:ok, linear_channel} = Content.create_linear_channel(@valid_attrs)

      valid_attrs_2 =
        Map.merge(@valid_attrs, %{
          code_name: Faker.Lorem.word(),
          epg_id: "#{Faker.Lorem.word()}_#{:rand.uniform(100)}",
          name: "#{Faker.Lorem.word()}"
        })

      {:ok, linear_channel_2} = Content.create_linear_channel(valid_attrs_2)

      {:error, %{errors: errors}} =
        Content.update_linear_channel(linear_channel_2, %{:code_name => linear_channel.code_name})

      assert errors == [
               code_name:
                 {"has already been taken",
                  [constraint: :unique, constraint_name: "linear_channels_code_name_index"]}
             ]
    end

    test "udpate_linear_channel/1 validate epg_id is unique" do
      {:ok, linear_channel} = Content.create_linear_channel(@valid_attrs)

      valid_attrs_2 =
        Map.merge(@valid_attrs, %{
          code_name: Faker.Lorem.word(),
          epg_id: "#{Faker.Lorem.word()}_#{:rand.uniform(100)}",
          name: "#{Faker.Lorem.word()}"
        })

      {:ok, linear_channel_2} = Content.create_linear_channel(valid_attrs_2)

      {:error, %{errors: errors}} =
        Content.update_linear_channel(linear_channel_2, %{epg_id: linear_channel.epg_id})

      assert errors == [
               epg_id:
                 {"has already been taken",
                  [constraint: :unique, constraint_name: "linear_channels_epg_id_index"]}
             ]
    end

    test "update_linear_channel/2 with invalid data returns error changeset" do
      linear_channel = linear_channel_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Content.update_linear_channel(linear_channel, @invalid_attrs)

      assert linear_channel.id == Content.get_linear_channel!(linear_channel.id).id
    end

    test "delete_linear_channel/1 deletes the linear_channel" do
      with_mock @domain_model_handler_module, handle: fn :delete, %{} -> :ok end do
        linear_channel = linear_channel_fixture()
        assert {:ok, %LinearChannel{}} = Content.delete_linear_channel(linear_channel)
        assert_raise Ecto.NoResultsError, fn -> Content.get_linear_channel!(linear_channel.id) end

        assert_called(
          @domain_model_handler_module.handle(:delete, %{model_name: "LinearChannel"})
        )
      end
    end

    test "change_linear_channel/1 returns a linear_channel changeset" do
      linear_channel = linear_channel_fixture()
      assert %Ecto.Changeset{} = Content.change_linear_channel(linear_channel)
    end
  end

  describe "programs" do
    alias CtiKaltura.Content.Program

    @valid_attrs %{
      end_datetime: ~N[2010-04-17 14:00:00],
      epg_id: "some epg_id",
      name: "some name",
      start_datetime: ~N[2010-04-17 14:00:00]
    }
    @update_attrs %{
      end_datetime: ~N[2011-05-18 15:01:01],
      epg_id: "some updated epg_id",
      name: "some updated name",
      start_datetime: ~N[2011-05-18 15:01:01]
    }
    @invalid_attrs %{end_datetime: nil, epg_id: nil, name: nil, start_datetime: nil}

    def program_fixture(attrs \\ %{}) do
      {:ok, program} = Factory.insert(:program, Enum.into(attrs, @valid_attrs))

      program
    end

    test "list_programs/0 returns all programs" do
      program = program_fixture()
      assert Enum.map(Content.list_programs(), & &1.id) == [program.id]
    end

    test "get_program!/1 returns the program with given id" do
      program = program_fixture()
      assert Content.get_program!(program.id).id == program.id
    end

    test "create_program/1 with valid data creates a program" do
      with_mock @domain_model_handler_module, handle: fn :insert, %{} -> :ok end do
        {:ok, linear_channel} = Factory.insert(:linear_channel)
        attrs = Map.put(@valid_attrs, :linear_channel_id, linear_channel.id)
        assert {:ok, %Program{} = program} = Content.create_program(attrs)
        assert program.end_datetime == ~N[2010-04-17 14:00:00]
        assert program.epg_id == "some epg_id"
        assert program.name == "some name"
        assert program.start_datetime == ~N[2010-04-17 14:00:00]
        assert_called(@domain_model_handler_module.handle(:insert, %{model_name: "Program"}))
      end
    end

    test "create_program/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_program(@invalid_attrs)
    end

    test "update_program/2 with valid data updates the program" do
      with_mock @domain_model_handler_module, handle: fn :update, %{} -> :ok end do
        program = program_fixture()
        {:ok, linear_channel} = Factory.insert(:linear_channel)
        attrs = Map.put(@update_attrs, :linear_channel_id, linear_channel.id)
        assert {:ok, %Program{} = program} = Content.update_program(program, attrs)
        assert program.end_datetime == ~N[2011-05-18 15:01:01]
        assert program.epg_id == "some updated epg_id"
        assert program.name == "some updated name"
        assert program.start_datetime == ~N[2011-05-18 15:01:01]
        assert_called(@domain_model_handler_module.handle(:update, %{model_name: "Program"}))
      end
    end

    test "update_program/2 with invalid data returns error changeset" do
      program = program_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_program(program, @invalid_attrs)
      assert program.id == Content.get_program!(program.id).id
    end

    test "delete_program/1 deletes the program" do
      with_mock @domain_model_handler_module, handle: fn :delete, %{} -> :ok end do
        program = program_fixture()
        assert {:ok, %Program{}} = Content.delete_program(program)
        assert_raise Ecto.NoResultsError, fn -> Content.get_program!(program.id) end
        assert_called(@domain_model_handler_module.handle(:delete, %{model_name: "Program"}))
      end
    end

    test "change_program/1 returns a program changeset" do
      program = program_fixture()
      assert %Ecto.Changeset{} = Content.change_program(program)
    end
  end

  describe "program_records" do
    alias CtiKaltura.Content.ProgramRecord

    @valid_attrs %{protocol: "HLS", encryption: "NONE", path: "some path", status: "PLANNED"}
    @update_attrs %{
      protocol: "MPD",
      encryption: "NONE",
      path: "some updated path",
      status: "RUNNING"
    }
    @invalid_attrs %{protocol: nil, encryption: nil, path: nil, status: nil}

    def program_record_fixture(attrs \\ %{}) do
      {:ok, program_record} = Factory.insert(:program_record, Enum.into(attrs, @valid_attrs))

      program_record
    end

    test "list_program_records/0 returns all program_records" do
      program_record = program_record_fixture()
      assert Enum.map(Content.list_program_records(), & &1.id) == [program_record.id]
    end

    test "get_program_record!/1 returns the program_record with given id" do
      program_record = program_record_fixture()
      assert Content.get_program_record!(program_record.id) == program_record
    end

    test "create_program_record/1 with valid data creates a program_record" do
      with_mock @domain_model_handler_module, handle: fn :insert, %{} -> :ok end do
        {:ok, program} = Factory.insert(:program)
        {:ok, server} = Factory.insert(:server)
        attrs = Map.merge(@valid_attrs, %{server_id: server.id, program_id: program.id})
        assert {:ok, %ProgramRecord{} = program_record} = Content.create_program_record(attrs)

        assert program_record.protocol == "HLS"
        assert program_record.path == "some path"
        assert program_record.status == "PLANNED"

        assert_called(
          @domain_model_handler_module.handle(:insert, %{model_name: "ProgramRecord"})
        )
      end
    end

    test "create_program_record/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_program_record(@invalid_attrs)
    end

    test "update_program_record/2 with valid data updates the program_record" do
      with_mock @domain_model_handler_module, handle: fn :update, %{} -> :ok end do
        program_record = program_record_fixture()
        {:ok, program} = Factory.insert(:program)
        {:ok, server} = Factory.insert(:server)
        attrs = Map.merge(@update_attrs, %{server_id: server.id, program_id: program.id})

        assert {:ok, %ProgramRecord{} = program_record} =
                 Content.update_program_record(program_record, attrs)

        assert program_record.protocol == "MPD"
        assert program_record.path == "some updated path"
        assert program_record.status == "RUNNING"

        assert_called(
          @domain_model_handler_module.handle(:update, %{model_name: "ProgramRecord"})
        )
      end
    end

    test "update_program_record/2 with invalid data returns error changeset" do
      program_record = program_record_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Content.update_program_record(program_record, @invalid_attrs)

      assert program_record.id == Content.get_program_record!(program_record.id).id
    end

    test "delete_program_record/1 deletes the program_record" do
      with_mock @domain_model_handler_module, handle: fn :delete, %{} -> :ok end do
        program_record = program_record_fixture()
        assert {:ok, %ProgramRecord{}} = Content.delete_program_record(program_record)
        assert_raise Ecto.NoResultsError, fn -> Content.get_program_record!(program_record.id) end

        assert_called(
          @domain_model_handler_module.handle(:delete, %{model_name: "ProgramRecord"})
        )
      end
    end

    test "change_program_record/1 returns a program_record changeset" do
      program_record = program_record_fixture()
      assert %Ecto.Changeset{} = Content.change_program_record(program_record)
    end
  end

  describe "tv_streams" do
    alias CtiKaltura.Content.TvStream

    @valid_attrs %{
      encryption: "some encryption",
      protocol: "some protocol",
      status: "some status",
      stream_path: "some stream_path"
    }
    @update_attrs %{
      encryption: "some updated encryption",
      protocol: "some updated protocol",
      status: "some updated status",
      stream_path: "some updated stream_path"
    }
    @invalid_attrs %{encryption: nil, protocol: nil, status: nil, stream_path: nil}

    def valid_attrs do
      {:ok, %{id: linear_channel_id}} = Factory.insert(:linear_channel)
      Map.put(@valid_attrs, :linear_channel_id, linear_channel_id)
    end

    def tv_stream_fixture(attrs \\ %{}) do
      {:ok, tv_stream} = Factory.insert(:tv_stream, Enum.into(attrs, valid_attrs()))

      tv_stream
    end

    test "list_tv_streams/0 returns all tv_streams" do
      tv_stream = tv_stream_fixture()
      assert Content.list_tv_streams() == [tv_stream]
    end

    test "get_tv_stream!/1 returns the tv_stream with given id" do
      tv_stream = tv_stream_fixture()
      assert Content.get_tv_stream!(tv_stream.id) == tv_stream
    end

    test "create_tv_stream/1 with valid data creates a tv_stream" do
      with_mock @domain_model_handler_module, handle: fn :insert, %{} -> :ok end do
        assert {:ok, %TvStream{} = tv_stream} = Content.create_tv_stream(valid_attrs())
        assert tv_stream.encryption == "some encryption"
        assert tv_stream.protocol == "some protocol"
        assert tv_stream.status == "some status"
        assert tv_stream.stream_path == "some stream_path"

        assert_called(@domain_model_handler_module.handle(:insert, %{model_name: "TvStream"}))
      end
    end

    test "create_tv_stream/1 validate stream_path uniques" do
      {:ok, %TvStream{}} = Content.create_tv_stream(valid_attrs())

      assert {:error, %Ecto.Changeset{}} = Content.create_tv_stream(valid_attrs())
    end

    test "create_tv_stream/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_tv_stream(@invalid_attrs)
    end

    test "update_tv_stream/2 with valid data updates the tv_stream" do
      with_mock @domain_model_handler_module, handle: fn :update, %{} -> :ok end do
        tv_stream = tv_stream_fixture()
        assert {:ok, %TvStream{} = tv_stream} = Content.update_tv_stream(tv_stream, @update_attrs)
        assert tv_stream.encryption == "some updated encryption"
        assert tv_stream.protocol == "some updated protocol"
        assert tv_stream.status == "some updated status"
        assert tv_stream.stream_path == "some updated stream_path"

        assert_called(@domain_model_handler_module.handle(:update, %{model_name: "TvStream"}))
      end
    end

    test "udpate_tv_stream/1 validate stream_path uniques" do
      {:ok, %TvStream{}} = Content.create_tv_stream(valid_attrs())

      valid_attrs_2 = Map.merge(valid_attrs(), %{stream_path: "#{Faker.Lorem.word()}"})
      {:ok, %TvStream{} = tv_stream} = Content.create_tv_stream(valid_attrs_2)

      assert {:error, %Ecto.Changeset{}} =
               Content.update_tv_stream(tv_stream, %{stream_path: valid_attrs().stream_path})
    end

    test "update_tv_stream/2 with invalid data returns error changeset" do
      tv_stream = tv_stream_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_tv_stream(tv_stream, @invalid_attrs)
      assert tv_stream == Content.get_tv_stream!(tv_stream.id)
    end

    test "delete_tv_stream/1 deletes the tv_stream" do
      with_mock @domain_model_handler_module, handle: fn :delete, %{} -> :ok end do
        tv_stream = tv_stream_fixture()
        assert {:ok, %TvStream{}} = Content.delete_tv_stream(tv_stream)
        assert_raise Ecto.NoResultsError, fn -> Content.get_tv_stream!(tv_stream.id) end

        assert_called(@domain_model_handler_module.handle(:delete, %{model_name: "TvStream"}))
      end
    end

    test "change_tv_stream/1 returns a tv_stream changeset" do
      tv_stream = tv_stream_fixture()
      assert %Ecto.Changeset{} = Content.change_tv_stream(tv_stream)
    end
  end
end
