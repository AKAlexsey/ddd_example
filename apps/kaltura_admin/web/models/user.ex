defmodule KalturaAdmin.User do
  use KalturaAdmin.Web, :model

  alias Comeonin.Argon2

  @type t :: %__MODULE__{}

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    timestamps()
  end

  @user_fields [:email, :first_name, :last_name, :password]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @user_fields)
    |> validate_required(@user_fields)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true,
        changes: %{password: password}} ->
        put_change(changeset,
          :password_hash,
          Argon2.hashpwsalt(password))
      _ ->
        changeset
    end
  end
end
