defmodule GoFishTest do
  use ExUnit.Case

  test "starting game" do
    assert {:ok,_} = GoFish.Ocean.start_link()
    assert {:ok,_} = GoFish.Player.start_link(:simon, false)
    assert {:ok,_} = GoFish.Player.start_link(:john, true)
    assert {:ok,_} = GoFish.Player.take_all_your(3, :john, :simon)
  end
end
