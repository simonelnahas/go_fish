defmodule GoFishWeb.WelcomeController do
  use GoFishWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html",[])
  end

  def start_card(conn, _) do
    %{"players" => players} = conn.query_params
    GoFish.Controller.start_game(players)
    GoFish.DynamicGameSupervisor.start_link()
    redirect(conn, to: "/")
  end

  # def draw_card(conn,%{"player" => player}) do
  #   GoFish.Player.draw_cards(String.to_existing_atom(player), 1)
  #   redirect(conn, to: "/")
  # end

  # def ask_for_card(conn, params) do
  #   %{"taker" => taker, "giver" => giver, "value" => value_string} = conn.query_params
  #   # values are fine
  #   { value, _ } = Integer.parse(value_string)
  #   IO.puts("value: #{value}")
  #   GoFish.Player.take_all_your(value, String.to_existing_atom(taker), String.to_existing_atom(giver)) #TODO consider if we can make this more concise.
  #   redirect(conn, to: "/")
  # end


end
