defmodule KalturaAdmin.ChannelTest do
  use KalturaAdmin.ModelCase

  alias KalturaAdmin.Channel

  @valid_attrs %{name: "some name", url: "some url"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Channel.changeset(%Channel{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Channel.changeset(%Channel{}, @invalid_attrs)
    refute changeset.valid?
  end
end
