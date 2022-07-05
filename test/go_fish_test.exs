defmodule GoFishTest do
  use ExUnit.Case
  doctest GoFish

  test "greets the world" do
    assert GoFish.hello() == :world
  end
end
