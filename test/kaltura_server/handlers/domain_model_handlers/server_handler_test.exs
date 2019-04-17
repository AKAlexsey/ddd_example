defmodule CtiKaltura.DomainModelHandlers.ServerHandlerTest do
  use CtiKaltura.MnesiaTestCase
  use CtiKaltura.DataCase

  import Mock

  alias CtiKaltura.Content.ProgramRecord
  alias CtiKaltura.DomainModelHandlers.ServerHandler
  alias CtiKaltura.Protocols.NotifyServerAttrs
  alias CtiKaltura.Repo
  alias CtiKaltura.Servers.Server

  @cti_kaltura_public_api Application.get_env(:cti_kaltura, :public_api)[:module]

  describe "#handle :insert" do
    setup do
      {:ok, %{id: server_group_id}} = Factory.insert_and_notify(:server_group)

      {:ok, server} = Factory.insert(:server, %{server_group_ids: [server_group_id]})

      {:ok, %{id: program_record_id1}} =
        Factory.insert_and_notify(:program_record, %{server_id: server.id, protocol: "HLS"})

      {:ok, %{id: program_record_id2}} =
        Factory.insert_and_notify(:program_record, %{server_id: server.id, protocol: "MPD"})

      Amnesia.transaction(fn -> DomainModel.Server.delete(server.id) end)

      {
        :ok,
        server_group_id: server_group_id,
        program_record_id1: program_record_id1,
        program_record_id2: program_record_id2,
        server_id: server.id
      }
    end

    test "Notify all joined models if new Server created #1", %{
      server_group_id: server_group_id,
      program_record_id1: program_record_id1,
      program_record_id2: program_record_id2,
      server_id: server_id
    } do
      server = Repo.get(Server, server_id)

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        ServerHandler.handle(:insert, NotifyServerAttrs.get(server))

        assert_called(@cti_kaltura_public_api.cache_model_record("ServerGroup", server_group_id))

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
      {:ok, %{id: server_group_id}} = Factory.insert_and_notify(:server_group)

      {:ok, server} = Factory.insert(:server, %{server_group_ids: [server_group_id]})

      {:ok, %{id: program_record_id1}} =
        Factory.insert_and_notify(:program_record, %{server_id: server.id, protocol: "HLS"})

      {:ok, %{id: program_record_id2}} =
        Factory.insert_and_notify(:program_record, %{server_id: server.id, protocol: "MPD"})

      {
        :ok,
        server_group_id: server_group_id,
        program_record_id1: program_record_id1,
        program_record_id2: program_record_id2,
        server_id: server.id
      }
    end

    test "Notify all joined models those associations has been updated #1", %{
      server_group_id: server_group_id,
      program_record_id1: program_record_id1,
      program_record_id2: program_record_id2,
      server_id: server_id
    } do
      {:ok, other_server} = Factory.insert(:server)

      ProgramRecord
      |> Repo.get(program_record_id1)
      |> ProgramRecord.changeset(%{server_id: other_server.id})
      |> Repo.update!()

      updated_server = Repo.get(Server, server_id)

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        ServerHandler.handle(:update, NotifyServerAttrs.get(updated_server))

        refute called(@cti_kaltura_public_api.cache_model_record("ServerGroup", server_group_id))

        assert_called(
          @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id1)
        )

        refute called(
                 @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id2)
               )
      end
    end

    test "Notify all joined models those associations has been updated #2", %{
      server_group_id: server_group_id,
      program_record_id1: program_record_id1,
      program_record_id2: program_record_id2,
      server_id: server_id
    } do
      {:ok, other_server} = Factory.insert(:server)

      ProgramRecord
      |> Repo.get(program_record_id2)
      |> ProgramRecord.changeset(%{server_id: other_server.id})
      |> Repo.update!()

      updated_server = Repo.get(Server, server_id)

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        ServerHandler.handle(:update, NotifyServerAttrs.get(updated_server))

        refute called(@cti_kaltura_public_api.cache_model_record("ServerGroup", server_group_id))

        refute called(
                 @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id1)
               )

        assert_called(
          @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id2)
        )
      end
    end

    test "Does not notify joined models if their associations has not changed", %{
      server_group_id: server_group_id,
      program_record_id1: program_record_id1,
      program_record_id2: program_record_id2,
      server_id: server_id
    } do
      server =
        Server
        |> Repo.get(server_id)

      updated_server =
        server
        |> Server.changeset(%{domain_name: server.domain_name <> ".new"})
        |> Repo.update!()

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        ServerHandler.handle(:update, NotifyServerAttrs.get(updated_server))

        refute called(@cti_kaltura_public_api.cache_model_record("ServerGroup", server_group_id))

        refute called(
                 @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id1)
               )

        refute called(
                 @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id2)
               )
      end
    end

    test "Notify models with injected attributes", %{
      server_group_id: server_group_id,
      program_record_id1: program_record_id1,
      program_record_id2: program_record_id2,
      server_id: server_id
    } do
      server =
        Server
        |> Repo.get(server_id)

      updated_server =
        server
        |> Server.changeset(%{prefix: "new-#{server.prefix}"})
        |> Repo.update!()

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        ServerHandler.handle(:update, NotifyServerAttrs.get(updated_server))

        refute called(@cti_kaltura_public_api.cache_model_record("ServerGroup", server_group_id))

        assert_called(
          @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id1)
        )

        assert_called(
          @cti_kaltura_public_api.cache_model_record("ProgramRecord", program_record_id2)
        )
      end
    end

    test "Does not notify models with injected attributes if attribute does not changed", %{
      server_group_id: server_group_id,
      program_record_id1: program_record_id1,
      program_record_id2: program_record_id2,
      server_id: server_id
    } do
      server =
        Server
        |> Repo.get(server_id)

      updated_server =
        server
        |> Server.changeset(%{domain_name: server.domain_name <> ".new"})
        |> Repo.update!()

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        ServerHandler.handle(:update, NotifyServerAttrs.get(updated_server))

        refute called(@cti_kaltura_public_api.cache_model_record("ServerGroup", server_group_id))

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
      {:ok, %{id: server_group_id}} = Factory.insert_and_notify(:server_group)

      {:ok, server} = Factory.insert(:server, %{server_group_ids: [server_group_id]})

      {:ok, %{id: program_record_id1}} =
        Factory.insert_and_notify(:program_record, %{server_id: server.id, protocol: "HLS"})

      {:ok, %{id: program_record_id2}} =
        Factory.insert_and_notify(:program_record, %{server_id: server.id, protocol: "MPD"})

      Amnesia.transaction(fn -> DomainModel.Server.delete(server.id) end)

      {
        :ok,
        server_group_id: server_group_id,
        program_record_id1: program_record_id1,
        program_record_id2: program_record_id2,
        server_id: server.id
      }
    end

    test "Notify all joined models if Server has been deleted", %{
      server_group_id: server_group_id,
      program_record_id1: program_record_id1,
      program_record_id2: program_record_id2,
      server_id: server_id
    } do
      server = Repo.get(Server, server_id)

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        ServerHandler.handle(:delete, NotifyServerAttrs.get(server))

        assert_called(@cti_kaltura_public_api.cache_model_record("ServerGroup", server_group_id))

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
