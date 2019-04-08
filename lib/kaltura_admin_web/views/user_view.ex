defmodule CtiKaltura.UserView do
  use CtiKalturaWeb, :view

  alias CtiKaltura.Users

  defdelegate has_permissions_to_create?(user), to: Users, as: :has_permissions_to_create?

  def meta do
    [
      %{
        :header => "Email",
        :type => :string,
        :field => :email,
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "First name",
        :type => :string,
        :field => :first_name,
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "Last name",
        :type => :string,
        :field => :last_name,
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "Role",
        :type => :select,
        :field => :role,
        :items => roles(),
        :mode => [:table, :show, :edit, :create]
      },
      %{:header => "Password", :type => :password, :field => :password, :mode => [:edit, :create]}
    ]
  end
end
