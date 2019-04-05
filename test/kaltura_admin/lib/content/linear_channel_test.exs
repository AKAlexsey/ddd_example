defmodule KalturaAdmin.LinearChannelTest do
  use CtiKaltura.DataCase

  alias CtiKaltura.Content
  alias CtiKaltura.Content.LinearChannel

  describe "Delete linear channel: " do
    setup do
      {:ok, %{:id => server_group_id}} = Factory.insert(:server_group)

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{:server_group_id => server_group_id})

      Factory.insert(:tv_stream, %{:linear_channel_id => linear_channel.id})

      {:ok, linear_channel: linear_channel}
    end

    test "linear channel without Program dependency", %{linear_channel: linear_channel} do
      cur_linear_channel = Repo.get(LinearChannel, linear_channel.id)
      assert cur_linear_channel != nil
      Content.delete_linear_channel(cur_linear_channel)
      assert Repo.get(LinearChannel, linear_channel.id) == nil
    end

    test "linear channel with Program dependency", %{linear_channel: linear_channel} do
      Factory.insert(:program, %{:linear_channel_id => linear_channel.id})

      cur_linear_channel = Repo.get(LinearChannel, linear_channel.id)
      assert cur_linear_channel != nil

      {:error, %{errors: errors}} = Content.delete_linear_channel(cur_linear_channel)

      assert errors == [
               programs:
                 {"There are programs for current channel. Remove related programs and try again",
                  [constraint: :foreign, constraint_name: "programs_linear_channel_id_fkey"]}
             ]

      assert Repo.get(LinearChannel, linear_channel.id) != nil
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
