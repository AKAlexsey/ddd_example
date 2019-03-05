defmodule KalturaAdmin.ProgramRecordTest do
  use KalturaAdmin.DataCase

  alias KalturaAdmin.Content.ProgramRecord

  describe "#changeset" do
    setup do
      {:ok, program_record} = Factory.insert(:program_record)

      {:ok, program_record: program_record}
    end

    test "Validate :status presence", %{program_record: program_record} do
      refute is_nil(program_record.status)
      changeset = ProgramRecord.changeset(program_record, %{status: nil})

      assert %{valid?: false, errors: [status: _]} = changeset
    end

    test "Validate :protocol presence", %{program_record: program_record} do
      refute is_nil(program_record.protocol)
      changeset = ProgramRecord.changeset(program_record, %{protocol: nil})

      assert %{valid?: false, errors: [protocol: _]} = changeset
    end

    test "Validate :path presence", %{program_record: program_record} do
      refute is_nil(program_record.path)
      changeset = ProgramRecord.changeset(program_record, %{path: nil})

      assert %{valid?: false, errors: [path: _]} = changeset
    end

    test "Validate :server_id presence", %{program_record: program_record} do
      refute is_nil(program_record.server_id)
      changeset = ProgramRecord.changeset(program_record, %{server_id: nil})

      assert %{valid?: false, errors: [server_id: _]} = changeset
    end

    test "Validate :program_id presence", %{program_record: program_record} do
      refute is_nil(program_record.program_id)
      changeset = ProgramRecord.changeset(program_record, %{program_id: nil})

      assert %{valid?: false, errors: [program_id: _]} = changeset
    end

    test "Validate :server exist", %{program_record: program_record} do
      changeset = ProgramRecord.changeset(program_record, %{server_id: 777})
      assert {:error, %{valid?: false, errors: [server: _]}} = Repo.update(changeset)
    end

    test "Validate :program exist", %{program_record: program_record} do
      changeset = ProgramRecord.changeset(program_record, %{program_id: 777})
      assert {:error, %{valid?: false, errors: [program: _]}} = Repo.update(changeset)
    end
  end
end
