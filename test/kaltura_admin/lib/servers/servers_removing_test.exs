defmodule CtiKaltura.ServersRemovingTest do
  use CtiKaltura.DataCase

  alias CtiKaltura.Servers
  alias CtiKaltura.Servers.Server

  setup do
    # ServerGroup
    {:ok, %{:id => server_group_id}} = Factory.insert(:server_group, %{})

    # LinearChannel 
    {:ok, %{:id => linear_channel_id}} =
      Factory.insert(:linear_channel, %{
        server_group_id: server_group_id
      })

    # Program 
    {:ok, %{:id => program_id}} =
      Factory.insert(:program, %{
        linear_channel_id: linear_channel_id
      })

    {:ok, server_group_id: server_group_id, program_id: program_id}
  end

  describe "removing server: " do
    test "server without dependencies" do
      {:ok, server} = Factory.insert(:server)
      Servers.delete_server(server)
      assert Repo.get(Server, server.id) == nil
    end

    test "server with ServerGroup dependency", %{server_group_id: server_group_id} do
      {:ok, server} = Factory.insert(:server, %{server_group_ids: [server_group_id]})
      Servers.delete_server(server)
      assert Repo.get(Server, server.id) == nil
    end

    test "server with ServerGroup and ProgramRecord dependencies", %{
      server_group_id: server_group_id,
      program_id: program_id
    } do
      {:ok, server} = Factory.insert(:server, %{server_group_ids: [server_group_id]})
      Factory.insert(:program_record, %{server_id: server.id, program_id: program_id})

      {:error, %{errors: errors}} = Servers.delete_server(server)

      assert errors == [
               program_records:
                 {"There are program records on this server. Remove related program records and try again",
                  [constraint: :foreign, constraint_name: "program_records_server_id_fkey"]}
             ]
    end
  end
end
