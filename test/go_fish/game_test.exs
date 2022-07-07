defmodule GoFish.GameTest do
  use ExUnit.Case



  test "initializing game" do
    {:ok, pid} = GoFish.Server.start_link(3)
    assert pid # not nil
  end


  test "drawing a card" do
    {:ok, pid} = GoFish.Server.start_link(3)
    card = GoFish.Server.take_card(pid)
    assert card.__struct__ == GoFish.Deck.Card
    assert card.value > 1 and card.value < 15
  end
end
