defmodule KalturaServerTest do
  use ExUnit.Case
  doctest KalturaServer

  test "greets the world" do
    assert KalturaServer.hello() == :world
  end
end
