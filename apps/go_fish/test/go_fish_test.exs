defmodule GoFishTest do
  require Logger
  use ExUnit.Case, async: false

  setup do
    assert start_supervised!({GoFish.Ocean, :sorted})
    assert start_supervised!({GoFish.Controller,[]})
    assert start_supervised!(Supervisor.child_spec({GoFish.Player, {:john, true}}, id: :john))
    assert start_supervised!(Supervisor.child_spec({GoFish.Player, {:simon, false}}, id: :simon))
    :ok
  end

  test "take card on empty hands" do
    Logger.debug("Test: take card on empty hands")
    assert :went_fishing == GoFish.Player.take_all_your(3, :john, :simon)
  end

  test "draw 7 cards" do
    Logger.debug("Test: draw 7 cards")
    assert :got_cards == GoFish.Player.draw_cards(:simon, 7)
    assert %{:hand => hand} = GoFish.Player.get_state(:simon)
    assert 3 == length(hand) # only 3 cards in the hand since the first 4 cards of the sorted deck will form a book
  end


  test "draw cards and give me all your" do
    Logger.debug("Test: draw cards and give me all your")
    assert :got_cards == GoFish.Player.draw_cards(:simon, 7)
    case GoFish.Player.take_all_your(4, :john, :simon) do
      {:matches, matches} ->
          Enum.map(matches, fn card -> assert 4 == card.value end)
      _ -> :ok
    end
  end


  test "draw more cards than available in ocean" do
    Logger.debug("Test: draw more cards than available in ocean")
    assert :got_cards == GoFish.Player.draw_cards(:simon, 55)
  end

  test "draw cards on empty ocean" do
    Logger.debug("Test: draw cards on empty ocean")
    assert :got_cards == GoFish.Player.draw_cards(:simon, 10)
    assert :got_cards == GoFish.Player.draw_cards(:john, 10)
    assert :got_cards == GoFish.Player.draw_cards(:simon, 10)
    assert :got_cards == GoFish.Player.draw_cards(:john, 10)
    assert :got_cards == GoFish.Player.draw_cards(:simon, 12)
    assert :no_cards_left == GoFish.Player.draw_cards(:john, 2)
  end



  test "example game play" do
    Logger.debug("Test: example game play")
    assert :ok == GoFish.Controller.start_game([:simon, :john])
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
    Logger.debug("Test: creating books")
    assert :got_cards == GoFish.Player.draw_cards(:simon, 7) #gets 4 2's and 3 3's.
    %{:hand => hand, :books => books} = GoFish.Player.get_state(:simon)
    # assert that hand only contains three values, since the first form should have been made into a book.
    assert 3 == length(hand)
    # assert that we have a book of 2's
    assert Enum.find(books, fn x -> x == 2 end)
  end

  test "new game" do
    Logger.debug("Test: new game")
    assert length(GoFish.Ocean.get_state()) == 52
    assert %{books: [], hand: [], is_my_turn: true} == GoFish.Player.get_state(:john)
    assert %{books: [], hand: [], is_my_turn: false} == GoFish.Player.get_state(:simon)
  end

  test "game over" do
    Logger.debug("Test: game over")
    assert :ok == GoFish.Controller.start_game([:simon, :john])

    # Simon draws all the remaining cards and automatically creates books
    assert :got_cards == GoFish.Player.draw_cards(:simon, 52-7*2)

    # Simon gets the remaining 5's and 3's from John
    assert {:got_cards, _} = GoFish.Player.take_all_your(3, :simon, :john)
    assert {:got_cards, _} = GoFish.Player.take_all_your(5, :simon, :john)

    assert %{:game_state => :game_over, :winner => {:simon, 12}} = GoFish.Controller.get_state()
  end

end
