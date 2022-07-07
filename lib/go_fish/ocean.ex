defmodule GoFish.Ocean do
  use Agent

  def start_link() do
    Agent.start_link(fn -> GoFish.Deck.new() end, name: __MODULE__)
  end

  def draw_card() do
    Agent.get(__MODULE__, fn [card|rest_deck] -> rest_deck )
  end


end
