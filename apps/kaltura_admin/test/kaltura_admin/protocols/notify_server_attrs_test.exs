defmodule KalturaAdmin.Protocols.NotifyServerAttrsTest do
  use KalturaAdmin.DataCase

  alias KalturaAdmin.Protocols.NotifyServerAttrs
  alias KalturaAdmin.Repo
  alias KalturaAdmin.Area.Region
  alias KalturaAdmin.Servers.ServerGroup

  describe "#get" do
    test "For Program schema" do
      {:ok, program} = Factory.insert(:program)
      result = NotifyServerAttrs.get(program)
      assert map_has_keys?(result, [:id, :name, :linear_channel_id, :epg_id, :program_record_ids])
    end

    test "For ProgramRecord schema" do
      {:ok, program_record} = Factory.insert(:program_record)
      result = NotifyServerAttrs.get(program_record)

      assert map_has_keys?(result, [
               :id,
               :program_id,
               :server_id,
               :status,
               :protocol,
               :path,
               :epg_id,
               :prefix
             ])
    end

    test "For Region schema" do
      {:ok, region} = Factory.insert(:region)
      result = NotifyServerAttrs.get(region)
      assert map_has_keys?(result, [:id, :name, :status, :subnet_ids, :server_group_ids])
    end

    test "For Server schema" do
      {:ok, server} = Factory.insert(:server)
      result = NotifyServerAttrs.get(server)

      assert map_has_keys?(result, [
               :id,
               :type,
               :domain_name,
               :ip,
               :port,
               :status,
               :weight,
               :prefix,
               :healthcheck_enabled,
               :server_group_ids,
               :program_record_ids,
               :subnet_ids
             ])
    end

    test "For ServerGroup schema" do
      {:ok, server_group} = Factory.insert(:server_group)
      result = NotifyServerAttrs.get(server_group)

      assert map_has_keys?(result, [
               :id,
               :name,
               :status,
               :server_ids,
               :region_ids,
               :linear_channel_ids,
               :subnet_ids
             ])
    end

    test "For Subnet schema" do
      {:ok, subnet} = Factory.insert(:subnet)
      result = NotifyServerAttrs.get(subnet)
      assert map_has_keys?(result, [:id, :region_id, :cidr, :name, :server_ids])
    end

    test "For LinearChannel schema" do
      {:ok, linear_channel} = Factory.insert(:linear_channel)
      result = NotifyServerAttrs.get(linear_channel)

      assert map_has_keys?(result, [
               :id,
               :epg_id,
               :name,
               :code_name,
               :server_group_id,
               :program_ids,
               :tv_stream_ids
             ])
    end
  end

  describe "#get for subnet filters :server_ids only for :active ServerGroup and Region" do
    setup do
      {:ok, server_group} = Factory.insert(:server_group, %{status: :active})
      {:ok, server1} = Factory.insert(:server, %{server_group_ids: [server_group.id]})
      {:ok, server2} = Factory.insert(:server, %{server_group_ids: [server_group.id]})
      {:ok, region} = Factory.insert(:region, %{server_group_ids: [server_group.id]})
      {:ok, subnet} = Factory.insert(:subnet, %{region_id: region.id})

      {:ok,
       server_ids: [server1.id, server2.id],
       server_group: server_group,
       region: region,
       subnet: subnet,
       s1: server1,
       s2: server2}
    end

    test "Gets server id if server_group and region is ACTIVE", %{
      server_ids: server_ids,
      subnet: subnet
    } do
      result = NotifyServerAttrs.get(subnet)
      assert result.server_ids == server_ids
    end

    test "Return [] if join ServerGroup is :inactive", %{server_group: server_group, subnet: sn} do
      server_group
      |> ServerGroup.changeset(%{status: :inactive})
      |> Repo.update()

      result = NotifyServerAttrs.get(sn)
      assert result.server_ids == []
    end

    test "Return [] if join Region is :inactive", %{region: region, subnet: subnet} do
      region
      |> Region.changeset(%{status: :inactive})
      |> Repo.update()

      result = NotifyServerAttrs.get(subnet)
      assert result.server_ids == []
    end
  end

  defp map_has_keys?(map, keys) do
    Enum.sort(Map.keys(map)) == Enum.sort(keys)
  end
end
