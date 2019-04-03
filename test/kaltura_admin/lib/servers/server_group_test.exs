defmodule CtiKaltura.ServerGroupTest do
  use CtiKaltura.DataCase

  alias CtiKaltura.Servers
  alias CtiKaltura.Servers.ServerGroup

  describe "#changeset" do
    setup do
      {:ok, server_group} = Factory.insert(:server_group)

      {:ok, server_group: server_group}
    end

    test "Validate :name presence", %{server_group: server_group} do
      refute is_nil(server_group.name)
      changeset = ServerGroup.changeset(server_group, %{name: nil})

      assert %{valid?: false, errors: [name: _]} = changeset
    end

    test "Validate :status presence", %{server_group: server_group} do
      refute is_nil(server_group.status)
      changeset = ServerGroup.changeset(server_group, %{status: nil})

      assert %{valid?: false, errors: [status: _]} = changeset
    end

    test "Validate :name is uniq", %{server_group: server_group} do
      {:ok, other_server_group} = Factory.insert(:server_group)

      refute server_group.name == other_server_group.name
      changeset = ServerGroup.changeset(server_group, %{name: other_server_group.name})
      assert {:error, %{valid?: false, errors: [name: _]}} = Repo.update(changeset)
    end
  end

  describe "Removing : " do
    setup do
      {:ok, %{:id => server_group_id}} = Factory.insert(:server_group)
      Factory.insert(:region, %{:server_group_ids => [server_group_id]})
      Factory.insert(:server, %{:server_group_ids => [server_group_id]})
      Factory.insert(:linear_channel, %{:server_group_id => server_group_id})

      {:ok, server_group_id: server_group_id}
    end

    test "remove ServerGroup", %{server_group_id: server_group_id} do
      server_group = Servers.get_server_group!(server_group_id)
      assert server_group != nil
      Servers.delete_server_group(server_group)
      assert Repo.get(ServerGroup, server_group_id) == nil
    end
  end
end
