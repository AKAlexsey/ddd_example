defmodule KalturaAdmin.ServerGroupTest do
  use KalturaAdmin.DataCase

  alias KalturaAdmin.Servers.ServerGroup

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
end
