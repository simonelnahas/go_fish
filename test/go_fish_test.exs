defmodule GoFishTest do
  use ExUnit.Case

  setup do
    assert {:ok,_} = GoFish.Ocean.start_link(:sorted)
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

  def start_example_game() do
    assert :got_cards == GoFish.Player.draw_cards(:simon, 7)
    assert :got_cards == GoFish.Player.draw_cards(:john, 7)
  end

  test "draw 7 cards" do
    assert :got_cards == GoFish.Player.draw_cards(:simon, 7)
    assert %{:hand => hand} = GoFish.Player.get_state(:simon)
    assert 7 == length(hand)
  end


  test "draw cards and give me all your" do
    assert :got_cards == GoFish.Player.draw_cards(:simon, 52)
    case GoFish.Player.take_all_your(3, :john, :simon) do
      {:matches, matches} ->
          Enum.map(matches, fn card -> assert 3 == card.value end)
      _ -> :ok
    end
  end


  test "draw more cards than available in ocean" do
    assert :got_cards == GoFish.Player.draw_cards(:simon, 55)
  end

  test "draw cards on empty ocean" do
    assert :got_cards == GoFish.Player.draw_cards(:simon, 52)
    assert :no_cards_left == GoFish.Player.draw_cards(:john, 2)
  end

  test "example game play" do
    start_example_game()
    assert {:got_cards, matches} = GoFish.Player.take_all_your(3, :john, :simon)
    assert matches == [%GoFish.Ocean.Card{suit: :clubs, value: 3},
                        %GoFish.Ocean.Card{suit: :diamonds, value: 3},
                        %GoFish.Ocean.Card{suit: :spades, value: 3}]
                        #TODO: consider using sets to check if cards

    # TODO: add rest of sequence diagram.
  end

  test "creating books" do
    #TODO create books.
  end

end
