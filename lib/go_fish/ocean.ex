defmodule GoFish.Ocean do
  use GenServer

  defmodule Card do
    defstruct [:suit, :value]
  end

  def generate_deck() do
    for value <- values(), suit <- suits() do
      %Card{value: value, suit: suit}
    end |> Enum.shuffle()
  end


  # Client API

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def stop() do
    GenServer.cast(__MODULE__, :stop)
  end

  def go_fish() do
    GenServer.call(__MODULE__, :go_fish)
  end





  # Server

  def init(_arg) do
    {:ok, generate_deck()}
  end

  def handle_cast(:stop, _state) do
    {:stop, :normal}
  end

  def handle_call(:go_fish, _from, [card|deck]) do
    {:reply, card, deck}
  end









  # Jacks-Aces is 11-14
  defp values(), do: Enum.to_list(2..14)
  defp suits(), do: [:spades, :diamonds, :clubs, :hearts]

  # defp loop([]) do
  #   IO.puts("OCEAN: receiving")
  #   receive do
  #     {:draw, caller_pid} ->
  #       send(caller_pid, :no_cards_left)
  #       loop([])
  #   end
  # end

  # defp loop([card | deck]) do
  #   IO.puts("OCEAN: receiving")
  #   receive do
  #     {:draw, caller_pid} ->
  #       IO.puts(["OCEAN: sending card: ", card])
  #       send(caller_pid, {:card card})
  #       loop(deck)
  #   end
  # end

  # def init() do
  #   IO.puts("OCEAN: initializing")
  #   spawn(fn -> loop(new()) end)
  # end

end
