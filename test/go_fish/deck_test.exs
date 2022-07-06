defmodule GoFish.DeckTest do
  use ExUnit.Case

  test "new deck contain 52 cards" do
    deck = GoFish.Deck.new()
    assert length(deck) == 52
  end
end
