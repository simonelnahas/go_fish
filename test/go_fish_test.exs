defmodule GoFishTest do
  use ExUnit.Case

  setup do
    assert {:ok,_} = GoFish.Ocean.start_link()
    assert {:ok,_} = GoFish.Player.start_link(:simon, false)
    assert {:ok,_} = GoFish.Player.start_link(:john, true)
    on_exit(fn ->
      GoFish.Player.stop(:simon)
      GoFish.Player.stop(:john)
      :timer.sleep(1000)
      end)
  end

  test "take card on empty hands" do
    assert :went_fishing == GoFish.Player.take_all_your(3, :john, :simon)
  end


  test "draw 7 cards" do
    assert :got_cards == GoFish.Player.draw_cards(:simon, 7)
    assert %{:hand => hand} = GoFish.Player.get_state(:simon)
    assert 7 == length(hand)
  end



end
