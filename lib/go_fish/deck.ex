defmodule GoFish.Deck do

  defmodule Card do
    defstruct [:suit, :value]
  end

  def new() do
    for value <- values(), suit <- suits() do
      %Card{value: value, suit: suit}
    end |> Enum.shuffle()
  end

  # Jacks-Aces is 11-14
  defp values(), do: Enum.to_list(2..14)
  defp suits(), do: [:spades, :diamonds, :clubs, :hearts]

end
