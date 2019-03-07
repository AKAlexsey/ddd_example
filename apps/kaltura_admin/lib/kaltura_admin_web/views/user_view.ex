defmodule KalturaAdmin.UserView do
  use KalturaAdminWeb, :view

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
      %{:header => "Password", :type => :password, :field => :password, :mode => [:edit, :create]}
    ]
  end
end
