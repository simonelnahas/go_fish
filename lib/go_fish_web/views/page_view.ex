defmodule GoFishWeb.PageView do
  def uppercase(atom) when is_atom(atom), do: uppercase(to_string(atom))
  def uppercase(<<first::utf8, rest::binary>>), do: String.upcase(<<first::utf8>>) <> rest

  def suit_to_emoji(:spades), do: "♠️"
  def suit_to_emoji(:diamonds), do: "♦️"
  def suit_to_emoji(:clubs), do: "♣️"
  def suit_to_emoji(:hearts), do: "♥️"


  use GoFishWeb, :view
end
