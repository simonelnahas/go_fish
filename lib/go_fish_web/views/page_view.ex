defmodule GoFishWeb.PageView do
  def uppercase(atom) when is_atom(atom), do: uppercase(to_string(atom))
  def uppercase(<<first::utf8, rest::binary>>), do: String.upcase(<<first::utf8>>) <> rest

  def suit_to_emoji(:spades), do: "♠️"
  def suit_to_emoji(:diamonds), do: "♦️"
  def suit_to_emoji(:clubs), do: "♣️"
  def suit_to_emoji(:hearts), do: "♥️"

  def suit_to_color(:spades), do: "black"
  def suit_to_color(:clubs), do: "black"
  def suit_to_color(:diamonds), do: "#c62020"
  def suit_to_color(:hearts), do: "#c62020"


  use GoFishWeb, :view
end
