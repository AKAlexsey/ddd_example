defmodule KalturaAdmin.Area.Subnet do
  use Ecto.Schema
  use Observable, :notifier
  import Ecto.Changeset
  alias KalturaAdmin.Area.Region
  alias KalturaAdmin.Observers.{DomainModelObserver, DomainModelNotifier}
  use DomainModelNotifier, observers: [DomainModelObserver]

  @cast_fields [:cidr, :region_id, :name]
  @required_fields [:cidr, :region_id]

  schema "subnetss" do
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
  end
end
