defmodule GoFish.Ocean do

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

  defp loop([]) do
    IO.puts("OCEAN: receiving")
    receive do
      {:draw, caller_pid} ->
        send(caller_pid, :no_cards_left)
        loop([])
    end
  end

  defp loop([card | deck]) do
    IO.puts("OCEAN: receiving")
    receive do
      {:draw, caller_pid} ->
        IO.puts(["OCEAN: sending card: ", card])
        send(caller_pid, {:card card})
        loop(deck)
    end
  end

  def init() do
    IO.puts("OCEAN: initializing")
    spawn(fn -> loop(new()) end)
  end

end
