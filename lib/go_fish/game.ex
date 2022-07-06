defmodule GoFish.Game do
  @moduledoc """
  Structure for a game
  """

  defstruct users: %{}, #Example :user1 => %{:cards => [{:suit :hearts, :value 2}]}
            deck: GoFish.Deck.new(),
            status: :not_started

  def new() do
    # TODO
  end
end
