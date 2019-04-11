defmodule CtiKaltura.UsersTest do
  # use ExUnit.Case
  use CtiKaltura.ConnCase

  import CtiKaltura.Users

  describe "Method update_with_permissions_check by ADMIN : " do
    setup do
      {:ok, logged_user} = Factory.insert(:admin)
      {:ok, another_user} = Factory.insert(:user)
      {:ok, logged_user: logged_user, another_user: another_user}
    end

    test "update yourself", %{logged_user: logged_user} do
      assert {:ok, _} =
               update_with_permissions_check(
                 logged_user,
                 %{:first_name => "FirstName"},
                 logged_user.id
               )
    end

    test "update yourself role", %{logged_user: logged_user} do
      assert {:error, changeset} =
               update_with_permissions_check(logged_user, %{:role => "MANAGER"}, logged_user.id)

      assert changeset.errors == [role: {"You cannot change role!", []}]
    end

    test "update another user", %{logged_user: logged_user, another_user: another_user} do
      assert {:ok, _} =
               update_with_permissions_check(
                 logged_user,
                 %{:first_name => "FirstName"},
                 another_user.id
               )
    end

    test "update another user role", %{logged_user: logged_user, another_user: another_user} do
      assert {:ok, _} =
               update_with_permissions_check(logged_user, %{:role => "ADMIN"}, another_user.id)
    end
  end

  describe "Method update_with_permissions_check by MANAGER : " do
    setup do
      {:ok, logged_user} = Factory.insert(:user)
      {:ok, another_user} = Factory.insert(:admin)
      {:ok, logged_user: logged_user, another_user: another_user}
    end

    test "update yourself", %{logged_user: logged_user} do
      assert {:ok, _} =
               update_with_permissions_check(
                 logged_user,
                 %{:first_name => "FirstName"},
                 logged_user.id
               )
    end

    test "update yourself role", %{logged_user: logged_user} do
      assert {:error, changeset} =
               update_with_permissions_check(logged_user, %{:role => "ADMIN"}, logged_user.id)

      assert changeset.errors == [role: {"You cannot change role!", []}]
    end

    test "update another user", %{logged_user: logged_user, another_user: another_user} do
      assert {:error, :forbidden} =
               update_with_permissions_check(
                 logged_user,
                 %{:first_name => "FirstName"},
                 another_user.id
               )
    end

    test "update another user role", %{logged_user: logged_user, another_user: another_user} do
      assert {:error, :forbidden} =
               update_with_permissions_check(logged_user, %{:role => "ADMIN"}, another_user.id)
    end
  end
end
