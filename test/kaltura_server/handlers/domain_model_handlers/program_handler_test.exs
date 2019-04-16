defmodule CtiKaltura.DomainModelHandlers.ProgramHandlerTest do
  use CtiKaltura.MnesiaTestCase
  use CtiKaltura.DataCase

  import Mock

  alias CtiKaltura.Content.{Program, ProgramRecord}
  alias CtiKaltura.DomainModelHandlers.ProgramHandler
  alias CtiKaltura.Protocols.NotifyServerAttrs
  alias CtiKaltura.Repo

  @cti_kaltura_public_api Application.get_env(:cti_kaltura, :public_api)[:module]

  describe "#handle :insert" do
    setup do
      {:ok, linear_channel} = Factory.insert(:linear_channel)

      {:ok, %{id: program_id}} =
        Factory.insert_and_notify(:program, %{linear_channel_id: linear_channel.id})

      {:ok, %{id: program_record_id1}} =
        Factory.insert_and_notify(:program_record, %{program_id: program_id, protocol: "HLS"})

      {:ok, %{id: program_record_id2}} =
        Factory.insert_and_notify(:program_record, %{program_id: program_id, protocol: "MPD"})

      Amnesia.transaction(fn -> DomainModel.Program.delete(program_id) end)

      {
        :ok,
        program_id: program_id,
        program_record_id1: program_record_id1,
        program_record_id2: program_record_id2,
        linear_channel_id: linear_channel.id
      }
    end

    test "Notify all joined models if new Program created #1", %{
      linear_channel_id: linear_channel_id,
      program_id: program_id,
      program_record_id1: program_record_id1,
      program_record_id2: program_record_id2
    } do
      program = Repo.get(Program, program_id)

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        ProgramHandler.handle(:insert, NotifyServerAttrs.get(program))

        assert_called(
          @cti_kaltura_public_api.cache_model_record("LinearChannel", linear_channel_id)
        )

        assert_called(
          @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id1)
        )

        assert_called(
          @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id2)
        )
      end
    end
  end

  describe "#handle :update" do
    setup do
      {:ok, linear_channel} = Factory.insert_and_notify(:linear_channel)

      {:ok, %{id: program_id}} =
        Factory.insert_and_notify(:program, %{linear_channel_id: linear_channel.id})

      {:ok, %{id: program_record_id1}} =
        Factory.insert_and_notify(:program_record, %{program_id: program_id, protocol: "HLS"})

      {:ok, %{id: program_record_id2}} =
        Factory.insert_and_notify(:program_record, %{program_id: program_id, protocol: "MPD"})

      {
        :ok,
        program_id: program_id,
        program_record_id1: program_record_id1,
        program_record_id2: program_record_id2,
        linear_channel_id: linear_channel.id
      }
    end

    test "Notify all joined models those associations has been updated #1", %{
      program_id: program_id,
      program_record_id1: program_record_id1,
      program_record_id2: program_record_id2,
      linear_channel_id: linear_channel_id
    } do
      ProgramRecord
      |> Repo.get(program_record_id1)
      |> Repo.delete()

      updated_program = Repo.get(Program, program_id)

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        ProgramHandler.handle(:update, NotifyServerAttrs.get(updated_program))

        refute called(
                 @cti_kaltura_public_api.cache_model_record("LinearChannel", linear_channel_id)
               )

        assert_called(
          @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id1)
        )

        refute called(
                 @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id2)
               )
      end
    end

    test "Notify all joined models those associations has been updated #2", %{
      program_id: program_id,
      program_record_id1: program_record_id1,
      program_record_id2: program_record_id2,
      linear_channel_id: linear_channel_id
    } do
      ProgramRecord
      |> Repo.get(program_record_id2)
      |> Repo.delete()

      updated_program = Repo.get(Program, program_id)

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        ProgramHandler.handle(:update, NotifyServerAttrs.get(updated_program))

        refute called(
                 @cti_kaltura_public_api.cache_model_record("LinearChannel", linear_channel_id)
               )

        refute called(
                 @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id1)
               )

        assert_called(
          @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id2)
        )
      end
    end

    test "Does not notify joined models if their associations has not changed", %{
      program_id: program_id,
      program_record_id1: program_record_id1,
      program_record_id2: program_record_id2,
      linear_channel_id: linear_channel_id
    } do
      program =
        Program
        |> Repo.get(program_id)

      updated_program =
        program
        |> Program.changeset(%{name: "new_#{inspect(program.name)}"})
        |> Repo.update!()

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        ProgramHandler.handle(:update, NotifyServerAttrs.get(updated_program))

        refute called(
                 @cti_kaltura_public_api.cache_model_record("LinearChannel", linear_channel_id)
               )

        refute called(
                 @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id1)
               )

        refute called(
                 @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id2)
               )
      end
    end

    test "Notify models with injected attributes", %{
      program_id: program_id,
      program_record_id1: program_record_id1,
      program_record_id2: program_record_id2,
      linear_channel_id: linear_channel_id
    } do
      program =
        Program
        |> Repo.get(program_id)

      updated_program =
        program
        |> Program.changeset(%{epg_id: "new_#{inspect(program.epg_id)}"})
        |> Repo.update!()

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        ProgramHandler.handle(:update, NotifyServerAttrs.get(updated_program))

        refute called(
                 @cti_kaltura_public_api.cache_model_record("LinearChannel", linear_channel_id)
               )

        assert_called(
          @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id1)
        )

        assert_called(
          @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id2)
        )
      end
    end

    test "Does not notify models with injected attributes if attribute does not changed", %{
      program_id: program_id,
      program_record_id1: program_record_id1,
      program_record_id2: program_record_id2,
      linear_channel_id: linear_channel_id
    } do
      program =
        Program
        |> Repo.get(program_id)

      updated_program =
        program
        |> Program.changeset(%{name: "new_#{inspect(program.name)}"})
        |> Repo.update!()

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        ProgramHandler.handle(:update, NotifyServerAttrs.get(updated_program))

        refute called(
                 @cti_kaltura_public_api.cache_model_record("LinearChannel", linear_channel_id)
               )

        refute called(
                 @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id1)
               )

        refute called(
                 @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id2)
               )
      end
    end
  end

  describe "#handle :delete" do
    setup do
      {:ok, linear_channel} = Factory.insert(:linear_channel)

      {:ok, %{id: program_id}} =
        Factory.insert_and_notify(:program, %{linear_channel_id: linear_channel.id})

      {:ok, %{id: program_record_id1}} =
        Factory.insert_and_notify(:program_record, %{program_id: program_id, protocol: "HLS"})

      {:ok, %{id: program_record_id2}} =
        Factory.insert_and_notify(:program_record, %{program_id: program_id, protocol: "MPD"})

      Amnesia.transaction(fn -> DomainModel.Program.delete(linear_channel.id) end)

      {
        :ok,
        program_id: program_id,
        program_record_id1: program_record_id1,
        program_record_id2: program_record_id2,
        linear_channel_id: linear_channel.id
      }
    end

    test "Notify all joined models if Program has been deleted", %{
      program_id: program_id,
      program_record_id1: program_record_id1,
      program_record_id2: program_record_id2,
      linear_channel_id: linear_channel_id
    } do
      program = Repo.get(Program, program_id)

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        ProgramHandler.handle(:delete, NotifyServerAttrs.get(program))

        assert_called(
          @cti_kaltura_public_api.cache_model_record("LinearChannel", linear_channel_id)
        )

        assert_called(
          @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id1)
        )

        assert_called(
          @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id2)
        )
      end
    end
  end
end
