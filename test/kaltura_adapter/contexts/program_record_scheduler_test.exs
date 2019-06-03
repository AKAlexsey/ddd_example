defmodule CtiKaltura.ProgramScheduling.ProgramRecordSchedulerTest do
  use CtiKaltura.ModelCase, async: false

  alias CtiKaltura.Content.ProgramRecord
  alias CtiKaltura.ProgramScheduling.{ProgramRecordScheduler, SoapRequests}
  alias CtiKaltura.Repo
  alias CtiKaltura.Servers.Server

  import Mock

  describe "#perform" do
    setup do
      now = NaiveDateTime.utc_now()

      {:ok, server_group} = Factory.insert(:server_group)

      Factory.insert(:server, %{
        status: "ACTIVE",
        type: "EDGE",
        server_group_ids: [server_group.id]
      })

      {:ok, dvr_server} =
        Factory.insert(:server, %{
          status: "ACTIVE",
          type: "DVR",
          server_group_ids: [server_group.id]
        })

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{dvr_enabled: true, server_group_id: server_group.id})

      {:ok, tv_stream} = Factory.insert(:tv_stream, %{linear_channel_id: linear_channel.id})

      {:ok, program1} =
        Factory.insert(:program, %{
          start_datetime: NaiveDateTime.add(now, 1100, :seconds),
          linear_channel_id: linear_channel.id
        })

      {:ok, program2} =
        Factory.insert(:program, %{
          start_datetime: NaiveDateTime.add(now, 2100, :seconds),
          linear_channel_id: linear_channel.id
        })

      {:ok, program3} =
        Factory.insert(:program, %{
          start_datetime: NaiveDateTime.add(now, 3100, :seconds),
          linear_channel_id: linear_channel.id
        })

      {
        :ok,
        program1: program1,
        program2: program2,
        program3: program3,
        tv_stream: tv_stream,
        dvr_server: dvr_server,
        server_group: server_group
      }
    end

    test "Create ProgramRecords for coming soon Programs #1", %{
      program1: program1,
      tv_stream: %{protocol: protocol, encryption: encryption},
      dvr_server: %{id: dvr_server_id}
    } do
      before_program_records_count = Repo.aggregate(ProgramRecord, :count, :id)
      program1_id = program1.id

      with_mocks([
        {SoapRequests, [], schedule_recording: fn {_, _, _} -> {:ok, "/cowex/rebel/one"} end}
      ]) do
        {:ok, %{created_ids: [created_program_record_id], errors: []}} =
          ProgramRecordScheduler.perform(1200)

        assert %{
                 path: "/cowex/rebel/one",
                 status: "NEW",
                 program_id: ^program1_id,
                 protocol: ^protocol,
                 encryption: ^encryption,
                 server_id: ^dvr_server_id
               } = Repo.get(ProgramRecord, created_program_record_id)

        assert before_program_records_count + 1 == Repo.aggregate(ProgramRecord, :count, :id)
      end
    end

    test "Create ProgramRecords for coming soon Programs #2", %{
      program1: program1,
      program2: program2
    } do
      before_program_records_count = Repo.aggregate(ProgramRecord, :count, :id)
      program1_id = program1.id
      program2_id = program2.id

      with_mocks([
        {SoapRequests, [], schedule_recording: fn {_, _, _} -> {:ok, "/cowex/rebel/one"} end}
      ]) do
        {:ok,
         %{created_ids: [created_program_record1_id, created_program_record2_id], errors: []}} =
          ProgramRecordScheduler.perform(2200)

        assert %{program_id: ^program1_id} = Repo.get(ProgramRecord, created_program_record1_id)
        assert %{program_id: ^program2_id} = Repo.get(ProgramRecord, created_program_record2_id)
        assert before_program_records_count + 2 == Repo.aggregate(ProgramRecord, :count, :id)
      end
    end

    test "Create ProgramRecords for coming soon Programs #3", %{
      program1: program1,
      program2: program2,
      program3: program3
    } do
      before_program_records_count = Repo.aggregate(ProgramRecord, :count, :id)
      program1_id = program1.id
      program2_id = program2.id
      program3_id = program3.id

      with_mocks([
        {SoapRequests, [], schedule_recording: fn {_, _, _} -> {:ok, "/cowex/rebel/one"} end}
      ]) do
        {:ok,
         %{
           created_ids: [
             created_program_record1_id,
             created_program_record2_id,
             created_program_record3_id
           ],
           errors: []
         }} = ProgramRecordScheduler.perform(3200)

        assert %{program_id: ^program1_id} = Repo.get(ProgramRecord, created_program_record1_id)
        assert %{program_id: ^program2_id} = Repo.get(ProgramRecord, created_program_record2_id)
        assert %{program_id: ^program3_id} = Repo.get(ProgramRecord, created_program_record3_id)
        assert before_program_records_count + 3 == Repo.aggregate(ProgramRecord, :count, :id)
      end
    end

    test "Return error if there are no active DVR server does not create ProgramRecords", %{
      dvr_server: %{id: dvr_server_id},
      server_group: server_group
    } do
      Server
      |> Repo.get(dvr_server_id)
      |> Server.changeset(%{status: "INACTIVE"})
      |> Repo.update!()

      before_program_records_count = Repo.aggregate(ProgramRecord, :count, :id)

      error_message =
        "No active dvr server in ServerGroup #{server_group.name} with ID: #{server_group.id}"

      with_mocks([
        {SoapRequests, [], schedule_recording: fn {_, _, _} -> {:ok, "/cowex/rebel/one"} end}
      ]) do
        assert {:ok, %{created_ids: [], errors: [error]}} = ProgramRecordScheduler.perform(1200)
        assert String.contains?(error, error_message)
        assert before_program_records_count == Repo.aggregate(ProgramRecord, :count, :id)
      end
    end

    test "Return {:ok, :no_programs} if there are no programs in given interval" do
      assert {:ok, :no_programs} == ProgramRecordScheduler.perform(1)
    end
  end

  describe "#clean_obsolete" do
    test "Remove obsolete ProgramRecords" do
      now = NaiveDateTime.utc_now()

      {:ok, program0} =
        Factory.insert(:program, %{start_datetime: NaiveDateTime.add(now, -3_500, :seconds)})

      Factory.insert(:program_record, %{program_id: program0.id})

      {:ok, program1} =
        Factory.insert(:program, %{start_datetime: NaiveDateTime.add(now, -3_700, :seconds)})

      {:ok, program_record1} = Factory.insert(:program_record, %{program_id: program1.id})

      {:ok, program2} =
        Factory.insert(:program, %{start_datetime: NaiveDateTime.add(now, -7_300, :seconds)})

      {:ok, program_record2} = Factory.insert(:program_record, %{program_id: program2.id})

      {:ok, program3} =
        Factory.insert(:program, %{start_datetime: NaiveDateTime.add(now, -11_900, :seconds)})

      {:ok, program_record3} = Factory.insert(:program_record, %{program_id: program3.id})

      {:ok, program4} =
        Factory.insert(:program, %{start_datetime: NaiveDateTime.add(now, -14_500, :seconds)})

      {:ok, program_record4} = Factory.insert(:program_record, %{program_id: program4.id})

      assert [program_record4.id] == get_ids(ProgramRecordScheduler.clean_obsolete(4))
      assert [program_record3.id] == get_ids(ProgramRecordScheduler.clean_obsolete(3))
      assert [program_record2.id] == get_ids(ProgramRecordScheduler.clean_obsolete(2))
      assert [program_record1.id] == get_ids(ProgramRecordScheduler.clean_obsolete(1))
    end

    test "Return {:ok, :no_program_records} if there are no obsolete programs" do
      assert {:ok, :no_program_records} = ProgramRecordScheduler.clean_obsolete(1)
    end
  end

  def get_ids({:ok, %{removed_ids: collection}}), do: Enum.sort(collection)
end
