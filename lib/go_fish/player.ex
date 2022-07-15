# defmodule GoFish.Player do
#   defp loop(hand) do
#     IO.puts(["Player has the hand: ",hand])
#     receive
#       :go-fish ->
#         send(ocean, {:draw, self()})
#         # TODO: register name ocean in registry
#       {:card, card} ->
#         loop([card|hand])
#       {:cards, cards} ->
#         loop(cards ++ hand)
#       {:give-me-all-your, taker, asking-value} ->
#         IO.puts("not implemented") #TODO
#   end
# end
