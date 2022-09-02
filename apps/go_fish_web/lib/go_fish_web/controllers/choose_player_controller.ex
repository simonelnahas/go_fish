defmodule GoFishWeb.ChoosePlayerController do
  use GoFishWeb, :controller

  import GoFishWeb.GameView

  def index(conn, _) do

    render(conn, "index.html", players: GoFish.Controller.get_players())
  end
end
