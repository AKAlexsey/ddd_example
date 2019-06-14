defmodule KalturaAdmin.LinearChannelTest do
  use CtiKaltura.DataCase

  alias CtiKaltura.Content
  alias CtiKaltura.Content.LinearChannel

  describe "Delete linear channel: " do
    setup do
      {:ok, %{:id => server_group_id}} = Factory.insert(:server_group)

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{:server_group_id => server_group_id})

      {:ok, tv_stream} = Factory.insert(:tv_stream, %{:linear_channel_id => linear_channel.id})

      {:ok, linear_channel: linear_channel, tv_stream: tv_stream}
    end

    test "LinearChannel without Program dependency but with Associated TvStreams", %{
      linear_channel: linear_channel
    } do
      cur_linear_channel = Repo.get(LinearChannel, linear_channel.id)
      assert cur_linear_channel != nil
      {:error, %{errors: errors}} = Content.delete_linear_channel(cur_linear_channel)
      assert [tv_streams: _] = errors
      refute is_nil(Repo.get(LinearChannel, linear_channel.id))
    end

    test "LinearChannel does not have nor Programs nor TvStreams", %{
      linear_channel: linear_channel,
      tv_stream: tv_stream
    } do
      Content.delete_tv_stream(tv_stream)
      cur_linear_channel = Repo.get(LinearChannel, linear_channel.id)
      assert cur_linear_channel != nil
      assert {:ok, _} = Content.delete_linear_channel(cur_linear_channel)
      assert is_nil(Repo.get(LinearChannel, linear_channel.id))
    end

    test "linear channel with Program dependency", %{linear_channel: linear_channel} do
      Factory.insert(:program, %{:linear_channel_id => linear_channel.id})

      cur_linear_channel = Repo.get(LinearChannel, linear_channel.id)
      assert cur_linear_channel != nil

      {:error, %{errors: errors}} = Content.delete_linear_channel(cur_linear_channel)

      assert errors == [
               programs:
                 {"There are programs for LinearChannel. Remove related programs and try again",
                  [constraint: :foreign, constraint_name: "programs_linear_channel_id_fkey"]}
             ]

      assert Repo.get(LinearChannel, linear_channel.id) != nil
    end
  end

  describe "Validations" do
    setup do
      {:ok, linear_channel} = Factory.insert(:linear_channel)
      {:ok, linear_channel: linear_channel}
    end

    test "Valid if storage_id is nil", %{linear_channel: linear_channel} do
      changeset = LinearChannel.changeset(linear_channel, %{storage_id: nil})
      assert %{valid?: true} = changeset
    end

    test "Invalid if storage_id less than 1 #1", %{linear_channel: linear_channel} do
      changeset = LinearChannel.changeset(linear_channel, %{storage_id: 0})
      assert %{valid?: false, errors: [storage_id: _]} = changeset
    end

    test "Invalid if storage_id less than 1 #2", %{linear_channel: linear_channel} do
      changeset = LinearChannel.changeset(linear_channel, %{storage_id: -5})
      assert %{valid?: false, errors: [storage_id: _]} = changeset
    end

    test "Valid if storage_id is 1", %{linear_channel: linear_channel} do
      changeset = LinearChannel.changeset(linear_channel, %{storage_id: 1})
      assert %{valid?: true} = changeset
    end

    test "Valid if storage_id is 10", %{linear_channel: linear_channel} do
      changeset = LinearChannel.changeset(linear_channel, %{storage_id: 10})
      assert %{valid?: true} = changeset
    end

    test "Invalid if storage_id more than 1", %{linear_channel: linear_channel} do
      changeset = LinearChannel.changeset(linear_channel, %{storage_id: 11})
      assert %{valid?: false, errors: [storage_id: _]} = changeset
    end
  end

  describe "UNIQUE constraints : " do
    setup do
      {:ok, linear_channel} = Factory.insert(:linear_channel)

      {:ok, linear_channel: linear_channel}
    end

    test "for name", %{linear_channel: linear_channel} do
      {:ok, new_linear_channel} = Factory.insert(:linear_channel)

      {:error, %{:errors => errors}} =
        Content.update_linear_channel(new_linear_channel, %{:name => linear_channel.name})

      assert errors == [
               name:
                 {"has already been taken",
                  [constraint: :unique, constraint_name: "linear_channels_name_index"]}
             ]
    end

    test "for code_name", %{linear_channel: linear_channel} do
      {:ok, new_linear_channel} = Factory.insert(:linear_channel)

      {:error, %{:errors => errors}} =
        Content.update_linear_channel(new_linear_channel, %{
          :code_name => linear_channel.code_name
        })

      assert errors == [
               code_name:
                 {"has already been taken",
                  [constraint: :unique, constraint_name: "linear_channels_code_name_index"]}
             ]
    end

    test "for epg_id", %{linear_channel: linear_channel} do
      {:ok, new_linear_channel} = Factory.insert(:linear_channel)

      {:error, %{:errors => errors}} =
        Content.update_linear_channel(new_linear_channel, %{:epg_id => linear_channel.epg_id})

      assert errors == [
               epg_id:
                 {"has already been taken",
                  [constraint: :unique, constraint_name: "linear_channels_epg_id_index"]}
             ]
    end
  end
end
