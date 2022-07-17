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

  def handle_call({:take_all_your, num, giver}, state) do
    if Map.get(state,:isMyTurn) do
      case give_all_my(num, giver) do
        :go_fish ->
            case GoFish.Ocean.take_card() do
              {:card, card} ->
                {:noreply,
                  %{state |
                    :isMyTurn => false,
                    :hand => [card | Map.get(state, :hand)]}}
              :no_cards_left -> {:reply, :no_cards_left, state} #TODO handle when game is over
            end
        {:matches, matches} -> {:reply, {:got_cards, matches}, %{state | :hand => matches ++ Map.get(state, :hand)}}
      end
    else
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
          %{state | :hand => new_hand, :isMyTurn => true}}
      {:matches, matches}  ->
        {:reply,
          {:matches, matches},
          %{state | :hand => new_hand}}
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
