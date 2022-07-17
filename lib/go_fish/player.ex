defmodule GoFish.Player do
  use GenServer


  # Client API

  def start_link(name) do
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  def stop(name) do
    GenServer.cast(name, :stop)
  end

  def give_me_your(name, num) do
    GenServer.call(name, {:give, num})
  end

  # def go_fish(name) do
  #   GenServer.cast(name, :go_fish)
  # end


  # Server

  def init(_arg) do
    {:ok, [] # initial state
    # TODO:
    # players: []
    # isMyTurn: bool
  }
  end

  def handle_cast(:stop, _state) do
    {:stop, :normal}
  end

  def handle_call({:give, num}, state) do
    matches = Enum.filter(state,fn x -> x.value == num end)
    hand = Enum.filter(state,fn x -> x.value != num end)
    {:reply, matches, hand}
  end

  # def handle_cast(:go_fish, state) do
  #   {:ok, [GoFish.Ocean.go_fish() | state]}
  # end

  def play(:play,state) do
    #TODO:
    # ask for card


    # give turn to next person. If a person says go_fish then it is their turn next.
    [GoFish.Ocean.go_fish() | state]
  end




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
