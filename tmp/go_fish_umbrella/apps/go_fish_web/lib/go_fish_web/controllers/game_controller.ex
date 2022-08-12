defmodule GoFishWeb.GameController do
  use GoFishWeb, :controller

  def index(conn, _params) do
    render(conn,
      "index.html",
      player_states: %{:john => GoFish.Player.get_state(:john),
                      :simon => GoFish.Player.get_state(:simon)})
  end

  def string_to_atom_list(s) do
    s
    |> String.downcase()
    |> String.split(", ")
    |> Enum.map(& String.to_atom(&1))
  end

  def start_game(conn, _params) do
    %{"players_raw" => players_raw} = conn.query_params
    players = string_to_atom_list(players_raw)
    GoFish.Controller.start_game(players)
    redirect(conn, to: "/")
  end

  def draw_card(conn,%{"player" => player}) do
    GoFish.Player.draw_cards(String.to_existing_atom(player), 1)
    redirect(conn, to: "/")
  end

  def ask_for_card(conn, _params) do
    %{"taker" => taker, "giver" => giver, "value" => value_string} = conn.query_params
    # values are fine
    { value, _ } = Integer.parse(value_string)
    IO.puts("value: #{value}")
    GoFish.Player.take_all_your(value, String.to_existing_atom(taker), String.to_existing_atom(giver)) #TODO consider if we can make this more concise.
    redirect(conn, to: "/")
  end
end
