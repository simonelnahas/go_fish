defmodule GoFish.Ocean do
  use GenServer

  defmodule Card do
    defstruct [:suit, :value]
  end

  # Jacks-Aces is 11-14
  defp values(), do: Enum.to_list(2..14)
  defp suits(), do: [:spades, :diamonds, :clubs, :hearts]

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

  def take_card() do
    GenServer.call(__MODULE__, :take_card)
  end


  # Server

  def init(_arg) do
    {:ok, generate_deck()}
  end

  def handle_cast(:stop, _state) do
    {:stop, :normal}
  end

  def handle_call(:take_card, _from, [card|deck]) do
    {:reply, {:card, card}, deck}
  end

  def handle_call(:take_card, _from, []) do
    {:reply, :no_cards_left, []}
  end

end
