defmodule CtiKaltura.ProgramScheduling.ProgramRecordStatusMonitorTest do
  use CtiKaltura.ModelCase, async: false

  alias CtiKaltura.Content
  alias CtiKaltura.ProgramScheduling.{ProgramRecordStatusMonitor, SoapRequests}

  import Mock

  describe "#perform" do
    test "Request ProgramRecord. Update status if it's different. Does not update if it's same as DB." do
      now = NaiveDateTime.utc_now()

      {:ok, program1} =
        Factory.insert(:program, %{
          start_datetime: NaiveDateTime.add(now, -10, :seconds),
          end_datetime: NaiveDateTime.add(now, 10, :seconds)
        })

      {:ok, %{path: path1} = program_record1} =
        Factory.insert(:program_record, %{status: "NEW", program_id: program1.id})

      {:ok, program2} =
        Factory.insert(:program, %{
          start_datetime: NaiveDateTime.add(now, -5, :seconds),
          end_datetime: NaiveDateTime.add(now, 5, :seconds)
        })

      {:ok, %{path: path2} = program_record2} =
        Factory.insert(:program_record, %{
          status: "PLANNED",
          program_id: program2.id
        })

      {:ok, program3} =
        Factory.insert(:program, %{
          start_datetime: NaiveDateTime.add(now, -5, :seconds),
          end_datetime: NaiveDateTime.add(now, 5, :seconds)
        })

      Factory.insert(:program_record, %{
        status: "RUNNING",
        program_id: program3.id
      })

      {:ok, program4} =
        Factory.insert(:program, %{
          start_datetime: NaiveDateTime.add(now, -5, :seconds),
          end_datetime: NaiveDateTime.add(now, 5, :seconds)
        })

      Factory.insert(:program_record, %{
        status: "ERROR",
        program_id: program4.id
      })

      {:ok, program5} =
        Factory.insert(:program, %{
          start_datetime: NaiveDateTime.add(now, -5, :seconds),
          end_datetime: NaiveDateTime.add(now, 5, :seconds)
        })

      Factory.insert(:program_record, %{
        status: "COMPLETED",
        program_id: program5.id
      })

      {:ok, program6} =
        Factory.insert(:program, %{
          start_datetime: NaiveDateTime.add(now, -20, :seconds),
          end_datetime: NaiveDateTime.add(now, -5, :seconds)
        })

      {:ok, %{path: path3} = program_record3} =
        Factory.insert(:program_record, %{
          status: "NEW",
          program_id: program6.id
        })

      {:ok, program7} =
        Factory.insert(:program, %{
          start_datetime: NaiveDateTime.add(now, -20, :seconds),
          end_datetime: NaiveDateTime.add(now, -5, :seconds)
        })

      {:ok, %{path: path4} = program_record4} =
        Factory.insert(:program_record, %{
          status: "PLANNED",
          program_id: program7.id
        })

      {:ok, program8} =
        Factory.insert(:program, %{
          start_datetime: NaiveDateTime.add(now, -20, :seconds),
          end_datetime: NaiveDateTime.add(now, -5, :seconds)
        })

      {:ok, %{path: path5} = program_record5} =
        Factory.insert(:program_record, %{
          status: "RUNNING",
          program_id: program8.id
        })

      {:ok, program9} =
        Factory.insert(:program, %{
          start_datetime: NaiveDateTime.add(now, -20, :seconds),
          end_datetime: NaiveDateTime.add(now, -10, :seconds)
        })

      Factory.insert(:program_record, %{
        status: "ERROR",
        program_id: program9.id
      })

      {:ok, program10} =
        Factory.insert(:program, %{
          start_datetime: NaiveDateTime.add(now, -20, :seconds),
          end_datetime: NaiveDateTime.add(now, -5, :seconds)
        })

      Factory.insert(:program_record, %{
        status: "COMPLETED",
        program_id: program10.id
      })

      with_mocks([
        {SoapRequests, [],
         get_recording: fn
           %{path: ^path1} -> {:ok, %{recordingStatus: "PLANNED"}}
           %{path: ^path2} -> {:ok, %{recordingStatus: "PLANNED"}}
           %{path: ^path3} -> {:ok, %{recordingStatus: "ERROR"}}
           %{path: ^path4} -> {:ok, %{recordingStatus: "COMPLETED"}}
           %{path: ^path5} -> {:ok, %{recordingStatus: "COMPLETED"}}
         end}
      ]) do
        standard = [
          "ProgramRecord id: #{program_record1.id} changed status from \"NEW\" to \"PLANNED\"",
          "ProgramRecord id: #{program_record2.id} status_does_not_changed",
          "ProgramRecord id: #{program_record3.id} changed status from \"NEW\" to \"ERROR\"",
          "ProgramRecord id: #{program_record4.id} changed status from \"PLANNED\" to \"COMPLETED\"",
          "ProgramRecord id: #{program_record5.id} changed status from \"RUNNING\" to \"COMPLETED\""
        ]

        {:ok, %{changed_program_records: changed_program_records, errors: []}} =
          ProgramRecordStatusMonitor.perform()

        assert changed_program_records == standard
      end
    end

    test "Return error if there is no ProgramRecord on server. Update ProgramRecord status to ERROR" do
      now = NaiveDateTime.utc_now()

      {:ok, program1} =
        Factory.insert(:program, %{
          start_datetime: NaiveDateTime.add(now, -10, :seconds),
          end_datetime: NaiveDateTime.add(now, 10, :seconds)
        })

      {:ok, %{path: path1} = program_record} =
        Factory.insert(:program_record, %{status: "NEW", program_id: program1.id})

      with_mocks([
        {SoapRequests, [],
         get_recording: fn %{path: ^path1} ->
           {:error, %{faultstring: "Fake message. No program record"}}
         end}
      ]) do
        {:ok, %{changed_program_records: [], errors: errors}} =
          ProgramRecordStatusMonitor.perform()

        updated_program_record = Content.get_program_record!(program_record.id, :program)

        standard = [
          ~s(Error occurred: %{faultstring: \"Fake message. No program record\"} with params: #{
            inspect({:ok, updated_program_record})
          })
        ]

        assert errors == standard
        assert %{status: "ERROR"} = updated_program_record
      end
    end

    test "Return {:ok, :no_program_records} if there are no current program records" do
      assert {:ok, :no_program_records} == ProgramRecordStatusMonitor.perform()
    end
  end
end
