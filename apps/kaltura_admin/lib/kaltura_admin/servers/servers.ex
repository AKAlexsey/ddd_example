defmodule KalturaAdmin.Servers do
  @moduledoc """
  The Servers context.
  """

  import Ecto.Query, warn: false
  alias KalturaAdmin.Area.RegionServerGroup
  alias KalturaAdmin.Repo

  alias KalturaAdmin.Servers.{
    Server,
    ServerGroupServer
  }

  alias KalturaAdmin.Content.LinearChannel

  @doc """
  Returns the list of servers.

  ## Examples

      iex> list_servers()
      [%Server{}, ...]

  """
  def list_servers(preload \\ []) do
    Server
    |> Repo.all()
    |> Repo.preload(preload)
  end

  def list_dvr_servers(preload \\ []) do
    from(s in Server, where: s.type == ^:dvr)
    |> Repo.all()
    |> Repo.preload(preload)
  end

  @doc """
  Gets a single server.

  Raises `Ecto.NoResultsError` if the Server does not exist.

  ## Examples

      iex> get_server!(123)
      %Server{}

      iex> get_server!(456)
      ** (Ecto.NoResultsError)

  """
  def get_server!(id), do: Repo.get!(Server, id)

  @doc """
  Creates a server.

  ## Examples

      iex> create_server(%{field: value})
      {:ok, %Server{}}

      iex> create_server(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_server(attrs \\ %{}) do
    %Server{}
    |> Server.changeset(attrs)
    |> Repo.insert_and_notify()
  end

  @doc """
  Updates a server.

  ## Examples

      iex> update_server(server, %{field: new_value})
      {:ok, %Server{}}

      iex> update_server(server, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_server(%Server{} = server, attrs) do
    server
    |> Server.changeset(add_empty_server_group_ids(attrs))
    |> Repo.update_and_notify()
  end

  defp add_empty_server_group_ids(%{server_group_ids: _ids} = attrs), do: attrs
  defp add_empty_server_group_ids(%{"server_group_ids" => _ids} = attrs), do: attrs

  defp add_empty_server_group_ids(attrs) do
    Map.put(attrs, appropriate_map_key(attrs, :server_group_ids), [])
  end

  defp appropriate_map_key(attrs, key_name) do
    attrs
    |> Map.keys()
    |> List.first()
    |> (fn first_element ->
          if(is_atom(first_element), do: key_name, else: to_string(key_name))
        end).()
  end

  @doc """
  Deletes a Server.

  ## Examples

      iex> delete_server(server)
      {:ok, %Server{}}

      iex> delete_server(server)
      {:error, %Ecto.Changeset{}}

  """
  def delete_server(%Server{} = server) do
    Repo.delete_and_notify(server)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking server changes.

  ## Examples

      iex> change_server(server)
      %Ecto.Changeset{source: %Server{}}

  """
  def change_server(%Server{} = server) do
    Server.changeset(server, %{})
  end

  alias KalturaAdmin.Servers.ServerGroup

  @doc """
  Returns the list of server_groups.

  ## Examples

      iex> list_server_groups()
      [%ServerGroup{}, ...]

  """
  def list_server_groups(preload \\ []) do
    ServerGroup
    |> Repo.all()
    |> Repo.preload(preload)
  end

  @doc """
  Gets a single server_group.

  Raises `Ecto.NoResultsError` if the Server group does not exist.

  ## Examples

      iex> get_server_group!(123)
      %ServerGroup{}

      iex> get_server_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_server_group!(id), do: Repo.get!(ServerGroup, id)

  @doc """
  Creates a server_group.

  ## Examples

      iex> create_server_group(%{field: value})
      {:ok, %ServerGroup{}}

      iex> create_server_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_server_group(attrs \\ %{}) do
    %ServerGroup{}
    |> ServerGroup.changeset(attrs)
    |> Repo.insert_and_notify()
  end

  @doc """
  Updates a server_group.

  ## Examples

      iex> update_server_group(server_group, %{field: new_value})
      {:ok, %ServerGroup{}}

      iex> update_server_group(server_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_server_group(%ServerGroup{} = server_group, attrs) do
    update_attrs =
      attrs
      |> add_empty_server_ids()
      |> add_empty_region_ids()

    server_group
    |> ServerGroup.changeset(update_attrs)
    |> Repo.update_and_notify()
  end

  defp add_empty_server_ids(%{server_ids: _ids} = attrs), do: attrs
  defp add_empty_server_ids(%{"server_ids" => _ids} = attrs), do: attrs

  defp add_empty_server_ids(attrs) do
    Map.put(attrs, appropriate_map_key(attrs, :server_ids), [])
  end

  defp add_empty_region_ids(%{region_ids: _ids} = attrs), do: attrs
  defp add_empty_region_ids(%{"region_ids" => _ids} = attrs), do: attrs

  defp add_empty_region_ids(attrs) do
    Map.put(attrs, appropriate_map_key(attrs, :region_ids), [])
  end

  @doc """
  Deletes a ServerGroup.

  ## Examples

      iex> delete_server_group(server_group)
      {:ok, %ServerGroup{}}

      iex> delete_server_group(server_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_server_group(%ServerGroup{} = server_group) do
    Repo.delete_and_notify(server_group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking server_group changes.

  ## Examples

      iex> change_server_group(server_group)
      %Ecto.Changeset{source: %ServerGroup{}}

  """
  def change_server_group(%ServerGroup{} = server_group) do
    ServerGroup.changeset(server_group, %{})
  end

  def linear_channel_ids_for_server_group(server_group_id) do
    from(lc in LinearChannel, where: lc.server_group_id == ^server_group_id)
    |> Repo.all()
    |> Enum.map(& &1.id)
  end

  def server_ids_for_server_group(server_group_id) do
    from(sgs in ServerGroupServer, where: sgs.server_group_id == ^server_group_id)
    |> Repo.all()
    |> Enum.map(fn %{server_id: server_id} -> server_id end)
  end

  def server_groups_ids_for_server(server_id) do
    from(sgs in ServerGroupServer, where: sgs.server_id == ^server_id)
    |> Repo.all()
    |> Enum.map(fn %{server_group_id: server_group_id} -> server_group_id end)
  end

  def server_name(server) do
    server.domain_name <> " [" <> String.upcase(to_string(server.type)) <> "]"
  end

  # TODO there is a lot of duplication in make_request_region_params,
  # Area.make_request_server_group_params. Remove duplication.
  def make_request_region_params(nil, region_ids) do
    Enum.map(region_ids, fn reg_id -> %{region_id: reg_id} end)
  end

  def make_request_region_params(server_group_id, region_ids) do
    region_ids = ids_to_integer(region_ids)

    existing_rsg =
      from(
        rsg in RegionServerGroup,
        where: rsg.server_group_id == ^server_group_id and rsg.region_id in ^region_ids
      )
      |> Repo.all()
      |> Enum.map(&Map.from_struct(&1))

    new_rsg_ids = region_ids -- Enum.map(existing_rsg, fn %{region_id: reg_id} -> reg_id end)

    existing_rsg ++ make_request_region_params(nil, new_rsg_ids)
  end

  def make_request_server_params(nil, server_ids) do
    Enum.map(server_ids, fn server_id -> %{server_id: server_id} end)
  end

  def make_request_server_params(server_group_id, server_ids) do
    server_ids = ids_to_integer(server_ids)

    existing_sgs =
      from(
        sgs in ServerGroupServer,
        where: sgs.server_group_id == ^server_group_id and sgs.server_id in ^server_ids
      )
      |> Repo.all()
      |> Enum.map(&Map.from_struct(&1))

    new_sgs_ids =
      server_ids -- Enum.map(existing_sgs, fn %{server_id: server_id} -> server_id end)

    existing_sgs ++ make_request_server_params(nil, new_sgs_ids)
  end

  def make_request_server_group_for_server_params(nil, server_group_ids) do
    Enum.map(server_group_ids, fn server_group_id -> %{server_group_id: server_group_id} end)
  end

  def make_request_server_group_for_server_params(server_id, server_group_ids) do
    server_group_ids = ids_to_integer(server_group_ids)

    existing_sgs =
      from(
        sgs in ServerGroupServer,
        where: sgs.server_id == ^server_id and sgs.server_group_id in ^server_group_ids
      )
      |> Repo.all()
      |> Enum.map(&Map.from_struct(&1))

    new_sgs_ids =
      server_group_ids --
        Enum.map(existing_sgs, fn %{server_group_id: server_group_id} -> server_group_id end)

    existing_sgs ++ make_request_server_group_for_server_params(nil, new_sgs_ids)
  end

  defp ids_to_integer(ids) do
    ids
    |> Enum.map(fn
      id when is_binary(id) ->
        {number_id, ""} = Integer.parse(id)
        number_id

      id when is_integer(id) ->
        id
    end)
  end
end
