defmodule GoFish.Server do
  use GenServer

  # Client API

  @impl true
  def start_link(player_count) when is_integer(player_count) do
    GenServer.start_link(__MODULE__,player_count)
  end

  @impl true
  def take_card(pid) do
    GenServer.call(pid, :take_card)
  end

  # Server Side

  @impl true
  def init(player_count) do
    {:ok, %GoFish.Game{}}
  end

  # def card_taker(1,[card|deck]), do card
  # def card_taker(n) when n>1, do: card_taker(n-1, [card|deck])

  @impl true
  def handle_call(:take_card, _from, game = %GoFish.Game{deck: [card|deck]}) do
    {:reply, card, %{game | deck: deck}}
  end

end
