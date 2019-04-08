defmodule CtiKaltura.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias CtiKaltura.Repo
  alias CtiKaltura.User

  @role_admin "ADMIN"

  @doc """
  The method creates changeset for User type. Argument is one of follow: empty, map, number or string
  """
  @spec changeset(map | number | String.t() | term) :: Ecto.Changeset.t()
  def changeset(user_params \\ %{})

  def changeset(user_params) when is_map(user_params) do
    User.changeset(%User{}, user_params)
  end

  def changeset(id) when is_integer(id) or is_binary(id) do
    User |> Repo.get!(id) |> User.changeset()
  end

  @doc """
  The method returns all users, available in order to the logged_user's role.
  For ADMIN role will be returned all users
  For MANAGER role will be returned 'logged_user' only
  """
  @spec get_available_users_with_permissions_check(User.t()) :: [User.t()]
  def get_available_users_with_permissions_check(logged_user) do
    if admin?(logged_user) do
      User
      |> Repo.all()
    else
      from(u in User, where: u.id == ^logged_user.id)
      |> Repo.all()
    end
  end

  @doc """
  The method returns single user, available in order to the logged_user's role.
  For ADMIN role will be returned requested user.
  For MANAGER role will be returned 'logged_user' only if logged_user.id == id
  """
  @spec get_user_with_permissions_check(User.t(), number | String.t()) ::
          {:ok, User.t()} | {:error, :forbidden}
  def get_user_with_permissions_check(logged_user, id) do
    if has_permissions_to_show?(logged_user, id) do
      {:ok, Repo.get(User, id)}
    else
      {:error, :forbidden}
    end
  end

  defp has_permissions_to_show?(logged_user, id) do
    admin?(logged_user) or equals?(logged_user.id, id)
  end

  @doc """
  The method updates particular user in order of the logged_user's role.
  """
  @spec update_with_permissions_check(User.t(), map, number | String.t()) ::
          {:ok, Ecto.Changeset.t()} | {:error, Ecto.Changeset.t()} | {:error, :forbidden}
  def update_with_permissions_check(logged_user, user_params, id) do
    changeset = User |> Repo.get!(id) |> User.changeset(user_params)

    with permissions_to_edit <- has_permissions_to_edit?(logged_user, id),
         role_was_changed <- role_was_changed?(changeset),
         can_change_role <- can_change_role?(logged_user, id) do
      cond do
        !permissions_to_edit ->
          {:error, :forbidden}

        !role_was_changed ->
          Repo.update(changeset)

        can_change_role ->
          Repo.update(changeset)

        !can_change_role ->
          Ecto.Changeset.add_error(changeset, :role, "You cannot change role!")
          |> Repo.update()
      end
    end
  end

  def role_was_changed?(changeset) do
    Map.has_key?(changeset.changes, :role)
  end

  @doc """
  The method checks permissions for edit-operation
  """
  @spec has_permissions_to_edit?(User.t(), number | String.t()) :: boolean
  def has_permissions_to_edit?(logged_user, id) do
    admin?(logged_user) or equals?(logged_user.id, id)
  end

  @doc """
  The method checks permissions for create-operation
  """
  @spec has_permissions_to_create?(User.t()) :: boolean
  def has_permissions_to_create?(logged_user) do
    admin?(logged_user)
  end

  @doc """
  The method checks permissions and creates new user entity
  """
  @spec create_with_permissions_check(User.t(), map) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()} | {:error, :forbidden}
  def create_with_permissions_check(logged_user, user_params) do
    if has_permissions_to_create?(logged_user) do
      Repo.insert(changeset(user_params))
    else
      {:error, :forbidden}
    end
  end

  @doc """
  The method checks permissions and deletes particular user.
  """
  @spec delete_with_permissions_check(User.t(), number | String.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, :forbidden}
  def delete_with_permissions_check(logged_user, id) do
    if has_permissions_to_delete?(logged_user, id) do
      user = Repo.get!(User, id)
      {:ok, Repo.delete!(user)}
    else
      {:error, :forbidden}
    end
  end

  @doc """
  The method checks the logged user can rights to change role for user with particular ID
  """
  @spec can_change_role?(User.t(), number | String.t()) :: boolean
  def can_change_role?(logged_user, id) do
    admin?(logged_user) and !equals?(logged_user.id, id)
  end

  defp has_permissions_to_delete?(logged_user, id) do
    admin?(logged_user) and !equals?(logged_user.id, id)
  end

  defp admin?(user) do
    user.role == @role_admin
  end

  defp equals?(val1, val2) do
    to_string(val1) == to_string(val2)
  end
end
