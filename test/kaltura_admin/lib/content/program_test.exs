defmodule CtiKaltura.ProgramTest do
  use CtiKaltura.DataCase

  alias CtiKaltura.Content
  alias CtiKaltura.Content.Program

  describe "#changeset" do
    setup do
      {:ok, program} = Factory.insert(:program)
      Factory.insert(:program_record, %{:program_id => program.id})

      {:ok, program: program}
    end

    test "Validate :name presence", %{program: program} do
      refute is_nil(program.name)
      changeset = Program.changeset(program, %{name: nil})

      assert %{valid?: false, errors: [name: _]} = changeset
    end

    test "Validate :start_datetime presence", %{program: program} do
      refute is_nil(program.start_datetime)
      changeset = Program.changeset(program, %{start_datetime: nil})

      assert %{valid?: false, errors: [start_datetime: _]} = changeset
    end

    test "Validate :end_datetime presence", %{program: program} do
      refute is_nil(program.end_datetime)
      changeset = Program.changeset(program, %{end_datetime: nil})

      assert %{valid?: false, errors: [end_datetime: _]} = changeset
    end

    test "Validate :epg_id presence", %{program: program} do
      refute is_nil(program.epg_id)
      changeset = Program.changeset(program, %{epg_id: nil})

      assert %{valid?: false, errors: [epg_id: _]} = changeset
    end

    test "Validate :linear_channel_id presence", %{program: program} do
      refute is_nil(program.linear_channel_id)
      changeset = Program.changeset(program, %{linear_channel_id: nil})

      assert %{valid?: false, errors: [linear_channel_id: _]} = changeset
    end

    test "Validate :epg_id is unique", %{program: program} do
      {:ok, other_program} = Factory.insert(:program)

      refute program.epg_id == other_program.epg_id
      changeset = Program.changeset(program, %{epg_id: other_program.epg_id})
      assert {:error, %{valid?: false, errors: [epg_id: _]}} = Repo.update(changeset)
    end

    test "Validate :linear_channel exist", %{program: program} do
      changeset = Program.changeset(program, %{linear_channel_id: 777})
      assert {:error, %{valid?: false, errors: [linear_channel: _]}} = Repo.update(changeset)
    end

    test " Remove linear channel with Program dependency", %{program: program} do
      {:error, %{errors: errors}} = Content.delete_program(program)

      assert errors == [
               program_records:
                 {"There are program records for current program. Remove related program records and try again",
                  [constraint: :foreign, constraint_name: "program_records_program_id_fkey"]}
             ]
    end
  end
end
