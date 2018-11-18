defmodule KalturaAdmin.ContentTest do
  use KalturaAdmin.DataCase

  alias KalturaAdmin.Content

  describe "tv_streams" do
    alias KalturaAdmin.Content.TvStream

    @valid_attrs %{
      code_name: "some code_name",
      description: "some description",
      dvr_enabled: true,
      epg_id: "some epg_id",
      name: "some name",
      status: 42,
      stream_path: "some stream_path"
    }
    @update_attrs %{
      code_name: "some updated code_name",
      description: "some updated description",
      dvr_enabled: false,
      epg_id: "some updated epg_id",
      name: "some updated name",
      status: 43,
      stream_path: "some updated stream_path"
    }
    @invalid_attrs %{
      code_name: nil,
      description: nil,
      dvr_enabled: nil,
      epg_id: nil,
      name: nil,
      status: nil,
      stream_path: nil
    }

    def tv_stream_fixture(attrs \\ %{}) do
      {:ok, tv_stream} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Content.create_tv_stream()

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
      assert {:ok, %TvStream{} = tv_stream} = Content.create_tv_stream(@valid_attrs)
      assert tv_stream.code_name == "some code_name"
      assert tv_stream.description == "some description"
      assert tv_stream.dvr_enabled == true
      assert tv_stream.epg_id == "some epg_id"
      assert tv_stream.name == "some name"
      assert tv_stream.status == 42
      assert tv_stream.stream_path == "some stream_path"
    end

    test "create_tv_stream/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_tv_stream(@invalid_attrs)
    end

    test "update_tv_stream/2 with valid data updates the tv_stream" do
      tv_stream = tv_stream_fixture()
      assert {:ok, %TvStream{} = tv_stream} = Content.update_tv_stream(tv_stream, @update_attrs)
      assert tv_stream.code_name == "some updated code_name"
      assert tv_stream.description == "some updated description"
      assert tv_stream.dvr_enabled == false
      assert tv_stream.epg_id == "some updated epg_id"
      assert tv_stream.name == "some updated name"
      assert tv_stream.status == 43
      assert tv_stream.stream_path == "some updated stream_path"
    end

    test "update_tv_stream/2 with invalid data returns error changeset" do
      tv_stream = tv_stream_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_tv_stream(tv_stream, @invalid_attrs)
      assert tv_stream == Content.get_tv_stream!(tv_stream.id)
    end

    test "delete_tv_stream/1 deletes the tv_stream" do
      tv_stream = tv_stream_fixture()
      assert {:ok, %TvStream{}} = Content.delete_tv_stream(tv_stream)
      assert_raise Ecto.NoResultsError, fn -> Content.get_tv_stream!(tv_stream.id) end
    end

    test "change_tv_stream/1 returns a tv_stream changeset" do
      tv_stream = tv_stream_fixture()
      assert %Ecto.Changeset{} = Content.change_tv_stream(tv_stream)
    end
  end

  describe "programs" do
    alias KalturaAdmin.Content.Program

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
      {:ok, program} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Content.create_program()

      program
    end

    test "list_programs/0 returns all programs" do
      program = program_fixture()
      assert Content.list_programs() == [program]
    end

    test "get_program!/1 returns the program with given id" do
      program = program_fixture()
      assert Content.get_program!(program.id) == program
    end

    test "create_program/1 with valid data creates a program" do
      assert {:ok, %Program{} = program} = Content.create_program(@valid_attrs)
      assert program.end_datetime == ~N[2010-04-17 14:00:00]
      assert program.epg_id == "some epg_id"
      assert program.name == "some name"
      assert program.start_datetime == ~N[2010-04-17 14:00:00]
    end

    test "create_program/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_program(@invalid_attrs)
    end

    test "update_program/2 with valid data updates the program" do
      program = program_fixture()
      assert {:ok, %Program{} = program} = Content.update_program(program, @update_attrs)
      assert program.end_datetime == ~N[2011-05-18 15:01:01]
      assert program.epg_id == "some updated epg_id"
      assert program.name == "some updated name"
      assert program.start_datetime == ~N[2011-05-18 15:01:01]
    end

    test "update_program/2 with invalid data returns error changeset" do
      program = program_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_program(program, @invalid_attrs)
      assert program == Content.get_program!(program.id)
    end

    test "delete_program/1 deletes the program" do
      program = program_fixture()
      assert {:ok, %Program{}} = Content.delete_program(program)
      assert_raise Ecto.NoResultsError, fn -> Content.get_program!(program.id) end
    end

    test "change_program/1 returns a program changeset" do
      program = program_fixture()
      assert %Ecto.Changeset{} = Content.change_program(program)
    end
  end

  describe "program_records" do
    alias KalturaAdmin.Content.ProgramRecord

    @valid_attrs %{codec: 42, path: "some path", status: 42}
    @update_attrs %{codec: 43, path: "some updated path", status: 43}
    @invalid_attrs %{codec: nil, path: nil, status: nil}

    def program_record_fixture(attrs \\ %{}) do
      {:ok, program_record} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Content.create_program_record()

      program_record
    end

    test "list_program_records/0 returns all program_records" do
      program_record = program_record_fixture()
      assert Content.list_program_records() == [program_record]
    end

    test "get_program_record!/1 returns the program_record with given id" do
      program_record = program_record_fixture()
      assert Content.get_program_record!(program_record.id) == program_record
    end

    test "create_program_record/1 with valid data creates a program_record" do
      assert {:ok, %ProgramRecord{} = program_record} =
               Content.create_program_record(@valid_attrs)

      assert program_record.codec == 42
      assert program_record.path == "some path"
      assert program_record.status == 42
    end

    test "create_program_record/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_program_record(@invalid_attrs)
    end

    test "update_program_record/2 with valid data updates the program_record" do
      program_record = program_record_fixture()

      assert {:ok, %ProgramRecord{} = program_record} =
               Content.update_program_record(program_record, @update_attrs)

      assert program_record.codec == 43
      assert program_record.path == "some updated path"
      assert program_record.status == 43
    end

    test "update_program_record/2 with invalid data returns error changeset" do
      program_record = program_record_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Content.update_program_record(program_record, @invalid_attrs)

      assert program_record == Content.get_program_record!(program_record.id)
    end

    test "delete_program_record/1 deletes the program_record" do
      program_record = program_record_fixture()
      assert {:ok, %ProgramRecord{}} = Content.delete_program_record(program_record)
      assert_raise Ecto.NoResultsError, fn -> Content.get_program_record!(program_record.id) end
    end

    test "change_program_record/1 returns a program_record changeset" do
      program_record = program_record_fixture()
      assert %Ecto.Changeset{} = Content.change_program_record(program_record)
    end
  end
end
