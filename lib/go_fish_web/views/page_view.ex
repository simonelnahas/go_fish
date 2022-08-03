defmodule GoFishWeb.PageView do
  def uppercase(atom) when is_atom(atom), do: uppercase(to_string(atom))
  def uppercase(<<first::utf8, rest::binary>>), do: String.upcase(<<first::utf8>>) <> rest


  use GoFishWeb, :view
end
