defmodule GoFishTest do
  use ExUnit.Case

  setup do
    assert start_supervised!({GoFish.Ocean, :sorted})
    assert start_supervised!({GoFish.Controller,[]})
    assert start_supervised!(Supervisor.child_spec({GoFish.Player, {:john, true}}, id: :john))
    assert start_supervised!(Supervisor.child_spec({GoFish.Player, {:simon, false}}, id: :simon))
    :ok
  end

  test "take card on empty hands" do
    assert :went_fishing == GoFish.Player.take_all_your(3, :john, :simon)
  end

  test "draw 7 cards" do
    assert :got_cards == GoFish.Player.draw_cards(:simon, 7)
    assert %{:hand => hand} = GoFish.Player.get_state(:simon)
    assert 3 == length(hand) # only 3 cards in the hand since the first 4 cards of the sorted deck will form a book
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
    :timer.sleep(500)
    assert :got_cards == GoFish.Player.draw_cards(:john, 7)
  end

  test "example game play" do
    start_example_game()
    assert {:got_cards, matches} = GoFish.Player.take_all_your(3, :john, :simon)
    to_match =  [%GoFish.Ocean.Card{suit: :clubs, value: 3},
                  %GoFish.Ocean.Card{suit: :diamonds, value: 3},
                  %GoFish.Ocean.Card{suit: :spades, value: 3}]

    assert Enum.all?(to_match, fn match -> match in matches end)

    assert :went_fishing = GoFish.Player.take_all_your(2, :john, :simon)

    assert {:got_cards, _matches} = GoFish.Player.take_all_your(5, :simon, :john)
    assert :went_fishing = GoFish.Player.take_all_your(6, :simon, :john)

    # Simon has the books for 2's and 5's
    assert %{:books => simons_books} = GoFish.Player.get_state(:simon)
    assert Enum.all?(simons_books, fn book -> book in [2, 5] end)

    # John has the books for 3's and 4's
    assert %{:books => johns_books} = GoFish.Player.get_state(:john)
    assert Enum.all?(johns_books, fn book -> book in [3, 4] end)

  end

  test "creating books" do
    assert :got_cards == GoFish.Player.draw_cards(:simon, 7) #gets 4 2's and 3 3's.
    %{:hand => hand, :books => books} = GoFish.Player.get_state(:simon)
    # assert that hand only contains three values, since the first form should have been made into a book.
    assert 3 == length(hand)
    # assert that we have a book of 2's
    assert Enum.find(books, fn x -> x == 2 end)
  end

  test "new game" do
    assert :new_game == GoFish.Controller.start_game([:john, :simon])
    assert length(GoFish.Ocean.get_state()) == 52
    assert %{books: [], hand: [], is_my_turn: true} == GoFish.Player.get_state(:john)
    assert %{books: [], hand: [], is_my_turn: false} == GoFish.Player.get_state(:simon)
  end

  test "game over" do
    assert :got_cards == GoFish.Player.draw_cards(:simon, 26)
    assert :got_cards == GoFish.Player.draw_cards(:john, 26)
    # Ocean is now empty
    assert :no_cards_left == GoFish.Player.take_all_your(2, :john, :simon)
    assert :no_cards_left = GoFish.Player.take_all_your(14, :simon, :john)
    assert %{:ocean_empty => true} = GoFish.Controller.get_state()
    # John and Simon both only have two 8s
    assert {:got_cards, _matches} = GoFish.Player.take_all_your(8, :john, :simon)
    # John gets the final book and the game ends
    assert %{:players => [], :game_state => :game_over, :ocean_empty => true, :winner => {:john, 7}} = GoFish.Controller.get_state()
  end

end
