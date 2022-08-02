defmodule GoFishWeb.PageController do
  use GoFishWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html",john: GoFish.Player.get_state(:john))
  end

  def draw_card(conn,%{"player" => player}) do
    GoFish.Player.draw_cards(String.to_existing_atom(player), 1)
    redirect(conn, to: "/")
  end
end
