defmodule GoFish.OceanTest do
  use ExUnit.Case

  test "initializing game" do
    {:ok, pid} = GoFish.Ocean.start_link()
    assert pid # not nil
  end


  test "drawing a card" do
      {:ok, _} = GoFish.Ocean.start_link()
      {:card, card} = GoFish.Ocean.take_card()
      assert card.__struct__ == GoFish.Ocean.Card
      assert card.value > 1 and card.value < 15
  end

end
