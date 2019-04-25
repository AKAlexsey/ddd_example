defmodule CtiKaltura.Area do
  @moduledoc """
  The Area context.
  """

  import Ecto.Query, warn: false
  alias CtiKaltura.Repo

  alias CtiKaltura.Area.{Region, RegionServerGroup, Subnet}

  @doc """
  Returns the list of regions.

  ## Examples

      iex> list_regions()
      [%Region{}, ...]

  """
  def list_regions(preload \\ []) do
    Region
    |> Repo.all()
    |> Repo.preload(preload)
  end

  @doc """
  Gets a single region.

  Raises `Ecto.NoResultsError` if the Region does not exist.

  ## Examples

      iex> get_region!(123)
      %Region{}

      iex> get_region!(456)
      ** (Ecto.NoResultsError)

  """
  def get_region!(id), do: Repo.get!(Region, id)

  @doc """
  Creates a region.

  ## Examples

      iex> create_region(%{field: value})
      {:ok, %Region{}}

      iex> create_region(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_region(attrs \\ %{}) do
    %Region{}
    |> Region.changeset(add_empty_server_group_ids(attrs))
    |> Repo.insert_and_notify()
  end

  @doc """
  Updates a region.

  ## Examples

      iex> update_region(region, %{field: new_value})
      {:ok, %Region{}}

      iex> update_region(region, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_region(%Region{} = region, attrs) do
    region
    |> Region.changeset(add_empty_server_group_ids(attrs))
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
  Deletes a Region.

  ## Examples

      iex> delete_region(region)
      {:ok, %Region{}}

      iex> delete_region(region)
      {:error, %Ecto.Changeset{}}

  """
  def delete_region(%Region{} = region) do
    region
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.foreign_key_constraint(
      :subnets,
      name: :subnets_region_id_fkey,
      message: "There are Subnets for Region. Remove related Subnets and than try again."
    )
    |> Repo.delete_and_notify()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking region changes.

  ## Examples

      iex> change_region(region)
      %Ecto.Changeset{source: %Region{}}

  """
  def change_region(%Region{} = region) do
    Region.changeset(region, %{})
  end

  def make_request_server_group_params(nil, server_group_ids) do
    Enum.map(server_group_ids, fn sg_id -> %{server_group_id: sg_id} end)
  end

  def make_request_server_group_params(region_id, server_group_ids) do
    server_group_ids =
      Enum.map(server_group_ids, fn id ->
        {number_id, ""} = Integer.parse(id)
        number_id
      end)

    existing_rsg =
      from(
        rsg in RegionServerGroup,
        where: rsg.region_id == ^region_id and rsg.server_group_id in ^server_group_ids
      )
      |> Repo.all()
      |> Enum.map(&Map.from_struct(&1))

    new_rsg_ids =
      server_group_ids -- Enum.map(existing_rsg, fn %{server_group_id: sg_id} -> sg_id end)

    existing_rsg ++ make_request_server_group_params(nil, new_rsg_ids)
  end

  def server_group_ids_for_region(region_id) do
    from(sg in RegionServerGroup, where: sg.region_id == ^region_id)
    |> Repo.all()
    |> Enum.map(& &1.server_group_id)
  end

  def region_ids_for_server_group(server_group_id) do
    from(sg in RegionServerGroup, where: sg.server_group_id == ^server_group_id)
    |> Repo.all()
    |> Enum.map(& &1.region_id)
  end

  alias CtiKaltura.Area.Subnet

  @doc """
  Returns the list of subnets.

  ## Examples

      iex> list_subnets()
      [%Subnet{}, ...]

  """
  def list_subnets(preload \\ []) do
    Subnet
    |> Repo.all()
    |> Repo.preload(preload)
  end

  @doc """
  Gets a single subnet.

  Raises `Ecto.NoResultsError` if the Subnet does not exist.

  ## Examples

      iex> get_subnet!(123)
      %Subnet{}

      iex> get_subnet!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subnet!(id), do: Repo.get!(Subnet, id)

  @doc """
  Creates a subnet.

  ## Examples

      iex> create_subnet(%{field: value})
      {:ok, %Subnet{}}

      iex> create_subnet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subnet(attrs \\ %{}) do
    %Subnet{}
    |> Subnet.changeset(attrs)
    |> Repo.insert_and_notify()
  end

  @doc """
  Updates a subnet.

  ## Examples

      iex> update_subnet(subnet, %{field: new_value})
      {:ok, %Subnet{}}

      iex> update_subnet(subnet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subnet(%Subnet{} = subnet, attrs) do
    subnet
    |> Subnet.changeset(attrs)
    |> Repo.update_and_notify()
  end

  @doc """
  Deletes a Subnet.

  ## Examples

      iex> delete_subnet(subnet)
      {:ok, %Subnet{}}

      iex> delete_subnet(subnet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subnet(%Subnet{} = subnet) do
    Repo.delete_and_notify(subnet)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subnet changes.

  ## Examples

      iex> change_subnet(subnet)
      %Ecto.Changeset{source: %Subnet{}}

  """
  def change_subnet(%Subnet{} = subnet) do
    Subnet.changeset(subnet, %{})
  end
end
