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

  def start_example_game() do
    assert :got_cards == GoFish.Player.draw_cards(:simon, 7)
    assert :got_cards == GoFish.Player.draw_cards(:john, 7)
  end

  test "example game play" do
    start_example_game()
    assert {:got_cards, matches} = GoFish.Player.take_all_your(3, :john, :simon)
    to_match =  [%GoFish.Ocean.Card{suit: :clubs, value: 3},
                  %GoFish.Ocean.Card{suit: :diamonds, value: 3},
                  %GoFish.Ocean.Card{suit: :spades, value: 3}]

    assert Enum.all?(to_match, fn match -> match in matches end)

    # TODO: add rest of sequence diagram.
  end

  test "creating books" do
    #TODO create books for the player
    assert :got_cards == GoFish.Player.draw_cards(:simon, 7) #gets 4 2's and 3 3's.
    %{:hand => hand, :books => books} = GoFish.Player.get_state(:simon)
    # assert that hand only contains three values, since the first form should have been made into a book.
    assert 3 == length(hand)
    # assert that books holds the number 2
    assert Enum.find(books, fn x -> x == 2 end)
  end

end
