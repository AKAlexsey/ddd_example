defmodule CtiKaltura.User do
  @moduledoc false

  use CtiKalturaWeb, :model

  alias Comeonin.Argon2

  @type t :: %__MODULE__{}

  schema "users" do
    field(:email, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    field(:role, :string)
    timestamps()
  end

  @user_fields [:email, :first_name, :last_name, :password, :role]
  @user_fields_without_pass [:email, :first_name, :last_name, :role]
  @mail_regex ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/
  @min_password_length 6

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{})

  def changeset(%CtiKaltura.User{:id => nil} = struct, params) do
    changeset_with_password(struct, params)
  end

  def changeset(struct, %{:password => pass} = params) do
    if pass == nil or byte_size(pass) == 0 do
      changeset_without_password(struct, params)
    else
      changeset_with_password(struct, params)
    end
  end

  def changeset(struct, %{"password" => pass} = params) do
    if pass == nil or byte_size(pass) == 0 do
      changeset_without_password(struct, params)
    else
      changeset_with_password(struct, params)
    end
  end

  def changeset(struct, params) do
    changeset_without_password(struct, params)
  end

  defp changeset_with_password(struct, params) do
    struct
    |> cast(params, @user_fields)
    |> validate_required(@user_fields)
    |> unique_constraint(:email)
    |> validate_format(:email, @mail_regex)
    |> validate_length(:password, min: @min_password_length)
    |> put_password_hash()
  end

  defp changeset_without_password(struct, params) do
    struct
    |> cast(params, @user_fields_without_pass)
    |> validate_required(@user_fields_without_pass)
    |> unique_constraint(:email)
    |> validate_format(:email, @mail_regex)
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Argon2.hashpwsalt(password))

      _ ->
        changeset
    end
  end
end
