# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     KalturaAdmin.Repo.insert!(%KalturaAdmin.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will halt execution if something goes wrong.

alias KalturaAdmin.{Repo, User}

%User{}
|> User.changeset(%{
  email: "admin@cti.ru",
  first_name: "Admin",
  last_name: "Admin",
  password: "qwe"
})
|> Repo.insert!()
