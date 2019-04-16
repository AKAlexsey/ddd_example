defmodule CtiKaltura.DomainModelHandlers.LinearChannelHandlerTest do
  use CtiKaltura.MnesiaTestCase
  use CtiKaltura.DataCase

  import Mock

  alias CtiKaltura.Content.{LinearChannel, Program, TvStream}
  alias CtiKaltura.DomainModelHandlers.LinearChannelHandler
  alias CtiKaltura.Protocols.NotifyServerAttrs
  alias CtiKaltura.Repo

  @cti_kaltura_public_api Application.get_env(:cti_kaltura, :public_api)[:module]

  describe "#handle :insert" do
    setup do
      {:ok, %{id: server_group_id}} = Factory.insert_and_notify(:server_group)

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{
          server_group_id: server_group_id
        })

      {:ok, %{id: program_id1}} =
        Factory.insert_and_notify(:program, %{linear_channel_id: linear_channel.id})

      {:ok, %{id: program_id2}} =
        Factory.insert_and_notify(:program, %{linear_channel_id: linear_channel.id})

      {:ok, %{id: tv_stream_id1}} =
        Factory.insert_and_notify(:tv_stream, %{linear_channel_id: linear_channel.id})

      {:ok, %{id: tv_stream_id2}} =
        Factory.insert_and_notify(:tv_stream, %{linear_channel_id: linear_channel.id})

      Amnesia.transaction(fn -> DomainModel.LinearChannel.delete(linear_channel.id) end)

      {
        :ok,
        server_group_id: server_group_id,
        program_id1: program_id1,
        program_id2: program_id2,
        tv_stream_id1: tv_stream_id1,
        tv_stream_id2: tv_stream_id2,
        linear_channel_id: linear_channel.id
      }
    end

    test "Notify all joined models if new LinearChannel created #1", %{
      server_group_id: server_group_id,
      program_id1: program_id1,
      program_id2: program_id2,
      tv_stream_id1: tv_stream_id1,
      tv_stream_id2: tv_stream_id2,
      linear_channel_id: linear_channel_id
    } do
      linear_channel = Repo.get(LinearChannel, linear_channel_id)

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        LinearChannelHandler.handle(:insert, NotifyServerAttrs.get(linear_channel))

        assert_called(@cti_kaltura_public_api.cache_model_record("ServerGroup", server_group_id))
        assert_called(@cti_kaltura_public_api.cache_model_record("Program", program_id1))
        assert_called(@cti_kaltura_public_api.cache_model_record("Program", program_id2))
        assert_called(@cti_kaltura_public_api.cache_model_record("TvStream", tv_stream_id1))
        assert_called(@cti_kaltura_public_api.cache_model_record("TvStream", tv_stream_id2))
      end
    end
  end

  describe "#handle :update" do
    setup do
      {:ok, %{id: server_group_id}} = Factory.insert_and_notify(:server_group)

      {:ok, linear_channel} =
        Factory.insert_and_notify(:linear_channel, %{server_group_id: server_group_id})

      {:ok, %{id: program_id1}} =
        Factory.insert_and_notify(:program, %{linear_channel_id: linear_channel.id})

      {:ok, %{id: program_id2}} =
        Factory.insert_and_notify(:program, %{linear_channel_id: linear_channel.id})

      {:ok, %{id: tv_stream_id1}} =
        Factory.insert_and_notify(:tv_stream, %{linear_channel_id: linear_channel.id})

      {:ok, %{id: tv_stream_id2}} =
        Factory.insert_and_notify(:tv_stream, %{linear_channel_id: linear_channel.id})

      {
        :ok,
        server_group_id: server_group_id,
        program_id1: program_id1,
        program_id2: program_id2,
        tv_stream_id1: tv_stream_id1,
        tv_stream_id2: tv_stream_id2,
        linear_channel_id: linear_channel.id
      }
    end

    test "Notify all joined models those associations has been updated #1", %{
      server_group_id: server_group_id,
      program_id1: program_id1,
      program_id2: program_id2,
      tv_stream_id1: tv_stream_id1,
      tv_stream_id2: tv_stream_id2,
      linear_channel_id: linear_channel_id
    } do
      {:ok, other_linear_channel} = Factory.insert(:linear_channel)

      Program
      |> Repo.get(program_id1)
      |> Program.changeset(%{linear_channel_id: other_linear_channel.id})
      |> Repo.update!()

      TvStream
      |> Repo.get(tv_stream_id1)
      |> TvStream.changeset(%{linear_channel_id: other_linear_channel.id})
      |> Repo.update!()

      updated_linear_channel = Repo.get(LinearChannel, linear_channel_id)

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        LinearChannelHandler.handle(:update, NotifyServerAttrs.get(updated_linear_channel))

        refute called(@cti_kaltura_public_api.cache_model_record("ServerGroup", server_group_id))
        assert_called(@cti_kaltura_public_api.cache_model_record("Program", program_id1))
        refute called(@cti_kaltura_public_api.cache_model_record("Program", program_id2))
        assert_called(@cti_kaltura_public_api.cache_model_record("TvStream", tv_stream_id1))
        refute called(@cti_kaltura_public_api.cache_model_record("TvStream", tv_stream_id2))
      end
    end

    test "Notify all joined models those associations has been updated #2", %{
      server_group_id: server_group_id,
      program_id1: program_id1,
      program_id2: program_id2,
      tv_stream_id1: tv_stream_id1,
      tv_stream_id2: tv_stream_id2,
      linear_channel_id: linear_channel_id
    } do
      {:ok, other_linear_channel} = Factory.insert(:linear_channel)

      Program
      |> Repo.get(program_id2)
      |> Program.changeset(%{linear_channel_id: other_linear_channel.id})
      |> Repo.update!()

      TvStream
      |> Repo.get(tv_stream_id2)
      |> TvStream.changeset(%{linear_channel_id: other_linear_channel.id})
      |> Repo.update!()

      updated_linear_channel = Repo.get(LinearChannel, linear_channel_id)

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        LinearChannelHandler.handle(:update, NotifyServerAttrs.get(updated_linear_channel))

        refute called(@cti_kaltura_public_api.cache_model_record("ServerGroup", server_group_id))
        refute called(@cti_kaltura_public_api.cache_model_record("Program", program_id1))
        assert_called(@cti_kaltura_public_api.cache_model_record("Program", program_id2))
        refute called(@cti_kaltura_public_api.cache_model_record("TvStream", tv_stream_id1))
        assert_called(@cti_kaltura_public_api.cache_model_record("TvStream", tv_stream_id2))
      end
    end

    test "Does not notify joined models if their associations has not changed", %{
      server_group_id: server_group_id,
      program_id1: program_id1,
      program_id2: program_id2,
      tv_stream_id1: tv_stream_id1,
      tv_stream_id2: tv_stream_id2,
      linear_channel_id: linear_channel_id
    } do
      linear_channel =
        LinearChannel
        |> Repo.get(linear_channel_id)

      updated_linear_channel =
        linear_channel
        |> LinearChannel.changeset(%{name: "new_#{inspect(linear_channel.name)}"})
        |> Repo.update!()

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        LinearChannelHandler.handle(:update, NotifyServerAttrs.get(updated_linear_channel))

        refute called(@cti_kaltura_public_api.cache_model_record("ServerGroup", server_group_id))
        refute called(@cti_kaltura_public_api.cache_model_record("Program", program_id1))
        refute called(@cti_kaltura_public_api.cache_model_record("Program", program_id2))
        refute called(@cti_kaltura_public_api.cache_model_record("TvStream", tv_stream_id1))
        refute called(@cti_kaltura_public_api.cache_model_record("TvStream", tv_stream_id2))
      end
    end

    test "Notify models with injected attributes", %{
      server_group_id: server_group_id,
      program_id1: program_id1,
      program_id2: program_id2,
      tv_stream_id1: tv_stream_id1,
      tv_stream_id2: tv_stream_id2,
      linear_channel_id: linear_channel_id
    } do
      linear_channel =
        LinearChannel
        |> Repo.get(linear_channel_id)

      updated_linear_channel =
        linear_channel
        |> LinearChannel.changeset(%{epg_id: "new_#{inspect(linear_channel.epg_id)}"})
        |> Repo.update!()

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        LinearChannelHandler.handle(:update, NotifyServerAttrs.get(updated_linear_channel))

        refute called(@cti_kaltura_public_api.cache_model_record("ServerGroup", server_group_id))
        refute called(@cti_kaltura_public_api.cache_model_record("Program", program_id1))
        refute called(@cti_kaltura_public_api.cache_model_record("Program", program_id2))
        assert_called(@cti_kaltura_public_api.cache_model_record("TvStream", tv_stream_id1))
        assert_called(@cti_kaltura_public_api.cache_model_record("TvStream", tv_stream_id2))
      end
    end

    test "Does not notify models with injected attributes if attribute does not changed", %{
      tv_stream_id1: tv_stream_id1,
      tv_stream_id2: tv_stream_id2,
      linear_channel_id: linear_channel_id
    } do
      linear_channel =
        LinearChannel
        |> Repo.get(linear_channel_id)

      updated_linear_channel =
        linear_channel
        |> LinearChannel.changeset(%{name: "new_#{inspect(linear_channel.name)}"})
        |> Repo.update!()

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        LinearChannelHandler.handle(:update, NotifyServerAttrs.get(updated_linear_channel))

        refute called(@cti_kaltura_public_api.cache_model_record("TvStream", tv_stream_id1))
        refute called(@cti_kaltura_public_api.cache_model_record("TvStream", tv_stream_id2))
      end
    end
  end

  describe "#handle :delete" do
    setup do
      {:ok, %{id: server_group_id}} = Factory.insert_and_notify(:server_group)

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{
          server_group_id: server_group_id
        })

      {:ok, %{id: program_id1}} =
        Factory.insert_and_notify(:program, %{linear_channel_id: linear_channel.id})

      {:ok, %{id: program_id2}} =
        Factory.insert_and_notify(:program, %{linear_channel_id: linear_channel.id})

      {:ok, %{id: tv_stream_id1}} =
        Factory.insert_and_notify(:tv_stream, %{linear_channel_id: linear_channel.id})

      {:ok, %{id: tv_stream_id2}} =
        Factory.insert_and_notify(:tv_stream, %{linear_channel_id: linear_channel.id})

      Amnesia.transaction(fn -> DomainModel.LinearChannel.delete(linear_channel.id) end)

      {
        :ok,
        server_group_id: server_group_id,
        program_id1: program_id1,
        program_id2: program_id2,
        tv_stream_id1: tv_stream_id1,
        tv_stream_id2: tv_stream_id2,
        linear_channel_id: linear_channel.id
      }
    end

    test "Notify all joined models if LinearChannel has been deleted", %{
      server_group_id: server_group_id,
      program_id1: program_id1,
      program_id2: program_id2,
      tv_stream_id1: tv_stream_id1,
      tv_stream_id2: tv_stream_id2,
      linear_channel_id: linear_channel_id
    } do
      linear_channel = Repo.get(LinearChannel, linear_channel_id)

      with_mock(
        @cti_kaltura_public_api,
        cache_model_record: fn _model_name, _model_id -> :ok end
      ) do
        LinearChannelHandler.handle(:delete, NotifyServerAttrs.get(linear_channel))

        assert_called(@cti_kaltura_public_api.cache_model_record("ServerGroup", server_group_id))
        assert_called(@cti_kaltura_public_api.cache_model_record("Program", program_id1))
        assert_called(@cti_kaltura_public_api.cache_model_record("Program", program_id2))
        assert_called(@cti_kaltura_public_api.cache_model_record("TvStream", tv_stream_id1))
        assert_called(@cti_kaltura_public_api.cache_model_record("TvStream", tv_stream_id2))
      end
    end
  end
end
