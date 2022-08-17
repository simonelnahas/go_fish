defmodule GoFish.OceanTest do
  use ExUnit.Case

  test "initializing game" do
    {:ok, pid} = GoFish.Ocean.start_link(nil)
    assert pid # not nil
  end

  test "new deck contain 52 cards" do
    deck = GoFish.Ocean.generate_deck()
    assert length(deck) == 52
  end

  test "drawing a card" do
    # TODO: use start_supervised! instead
      {:ok, _} = GoFish.Ocean.start_link(nil)
      {:card, card} = GoFish.Ocean.take_card()
      assert card.__struct__ == GoFish.Ocean.Card
      assert card.value > 1 and card.value < 15
  end
end
