defmodule GoFish.Player do
  use GenServer


  # Client API

  def start_link(name, isMyTurn) do
    GenServer.start_link(__MODULE__, isMyTurn, name: name)
  end

  def stop(name) do
    GenServer.cast(name, :stop)
  end

  # called on the taker of cards
  def take_all_your(num, taker, giver) do
    GenServer.call(taker, {:take_all_your, num, giver})
  end

  # called on the giver of cards
  def give_all_my(num, giver) do
    GenServer.call(giver, {:give_all_my, num})
  end

  def get_state(name) do
    GenServer.call(name, :get_state)
  end

  def draw_cards(name, num) do
    GenServer.call(name, {:draw_cards, num})
  end


  # Server

  def init(true) do
    {:ok,
      # initial state:
      %{:hand => [], :isMyTurn => true}}
  end

  def init(false) do
    {:ok,
      # initial state:
      %{:hand => [], :isMyTurn => false}}
  end

  def handle_cast(:stop, _state) do
    {:stop, :normal}
  end

  def handle_call({:take_all_your, num, giver}, _from, state) do
    # TODO John: refactor out into functions
    IO.puts("taking cards with value #{num} from #{giver}")
    if Map.get(state,:isMyTurn) do
      IO.puts("it is my turn")
      case give_all_my(num, giver) do
        :go_fish ->
          IO.puts("They didn't have the requested value so I go fishing")
          case GoFish.Ocean.take_card() do
              {:card, card} ->
                IO.puts("I drew the card #{inspect(card)} from the ocean")
                newState = %{state |
                              :isMyTurn => false,
                              :hand => [card | Map.get(state, :hand)]}
                {:reply, :went_fishing, newState}
              :no_cards_left ->
                IO.puts("There are no cards left in the ocean")
                {:reply, :no_cards_left, state} #TODO handle when game is over
            end
        {:matches, matches} ->
          IO.puts("Yay! I got the cards #{inspect(matches)}")
          {:reply, {:got_cards, matches}, %{state | :hand => matches ++ Map.get(state, :hand)}}
      end
    else
      IO.puts("I tried to take cards, but it wasn't my turn")
      {:reply, :not_my_turn, state}
    end
  end

  def handle_call({:give_all_my, num}, _from, state) do
    hand = Map.get(state, :hand)
    matches = Enum.filter(hand,fn x -> x.value == num end)
    new_hand = Enum.filter(hand,fn x -> x.value != num end)
    case matches do
      [] ->
        {:reply,
          :go_fish,
          %{state | :isMyTurn => true}}
      matches  ->
        {:reply,
          {:matches, matches},
          %{state | :hand => new_hand}}
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:draw_cards, num}, _from, state) do
    case GoFish.Ocean.take_card() do
      :no_cards_left -> {:reply, :no_cards_left, state}
      {:card, card1} ->
        cards = List.foldl(Enum.to_list(2..num), [], fn _x, acc ->
            case GoFish.Ocean.take_card() do
              {:card, card} -> [card| acc]
              :no_cards_left -> acc
            end
          end)
        {:reply, :got_cards, %{state | :hand => [card1|cards] ++ Map.get(state, :hand)} }
    end
  end



  # def handle_cast(:go_fish, state) do
  #   {:ok, [GoFish.Ocean.go_fish() | state]}
  # end

  # def play_turn(:play_turn, state) do
  #   #TODO:
  #   # ask for card
  #   # if it is my turn

  #   # give turn to next person. If a person says go_fish then it is their turn next.
  #   [GoFish.Ocean.go_fish() | state]
  # end

  # defp loop(hand) do
  #   IO.puts(["Player has the hand: ",hand])
  #   receive
  #     :go-fish ->
  #       send(ocean, {:draw, self()})
  #       # TODO: register name ocean in registry
  #     {:card, card} ->
  #       loop([card|hand])
  #     {:cards, cards} ->
  #       loop(cards ++ hand)
  #     {:give-me-all-your, taker, asking-value} ->
  #       IO.puts("not implemented") #TODO
  # end
end
