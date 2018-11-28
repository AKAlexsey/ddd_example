defmodule KalturaAdmin.Repo do
  use Ecto.Repo, otp_app: :kaltura_admin
  use Observable.Repo
end
