defmodule CtiKaltura.Area.Subnet do
  @moduledoc false

  use Ecto.Schema
  use Observable, :notifier
  import Ecto.Changeset
  alias CtiKaltura.Area.Region
  alias CtiKaltura.Observers.{DomainModelNotifier, DomainModelObserver}
  use DomainModelNotifier, observers: [DomainModelObserver]

  @cast_fields [:cidr, :region_id, :name]
  @required_fields [:cidr, :region_id, :name]

  @cidr_format ~r/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\/(\d{1,2})$/

  schema "subnets" do
    field(:cidr, :string)
    field(:name, :string)

    belongs_to(:region, Region)

    timestamps()
  end

  @doc false
  def changeset(subnet, attrs) do
    subnet
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_name()
    |> validate_cidr()
  end

  defp validate_name(changeset) do
    changeset
    |> unique_constraint(:name)
  end

  defp validate_cidr(changeset) do
    changeset
    |> validate_format(:cidr, @cidr_format)
    |> validate_cidr_values()
  end

  defp validate_cidr_values(%{changes: changes, errors: errors} = changeset) do
    with cidr when not is_nil(cidr) <- Map.get(changes, :cidr, nil),
         nil <- Keyword.get(errors, :cidr, nil),
         [_cidr, ip, mask] <- Regex.run(@cidr_format, cidr),
         {:ip_address_valid, true} <- ip_address_range_valid?(ip),
         {:mask_valid, true} <- mask_range_valid?(mask) do
      changeset
    else
      {:ip_address_valid, false} ->
        changeset
        |> add_error(:cidr, "IP address out of range")

      {:mask_valid, false} ->
        changeset
        |> add_error(:cidr, "Bit mask out of range")

      nil ->
        changeset

      _ ->
        changeset
    end
  end

  defp ip_address_range_valid?(ip_address) do
    valid =
      ip_address
      |> String.split(".")
      |> Enum.map(fn ip -> string_to_integer(ip) end)
      |> Enum.all?(fn num -> num in 0..255 end)

    {:ip_address_valid, valid}
  end

  defp mask_range_valid?(mask) do
    {:mask_valid, string_to_integer(mask) in 0..32}
  end

  defp string_to_integer(string) do
    {integer, ""} = Integer.parse(string)
    integer
  end
end
